//
//  ConcurrencyTester.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import Foundation
import SwiftUI

@MainActor
class ConcurrencyTester: ObservableObject {
    // Published UI bindings
    @Published var logs: [RequestLog] = []
    @Published var metrics = Metrics()
    @Published var isTesting = false

    private var activeTasks = Set<Task<Void, Never>>()
    private var startTimestamp: Date?

    /// Starts a load‑test with the given url & concurrency level
    func startTesting(url: String, concurrency: Int, method: String = "GET", body: String = "") {
        guard let target = URL(string: url) else { return }

        // Reset state
        logs.removeAll()
        metrics = Metrics()
        startTimestamp = Date()
        isTesting = true

        // Parent supervision task
        let parentTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            await self.runGroup(target: target, concurrency: concurrency, method: method, body: body)
        }
        activeTasks.insert(parentTask)
    }

    /// Cancels all in‑flight requests & updates state
    func stopTesting() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        // Mark unfinished logs as failed
        for i in logs.indices where logs[i].status == .pending {
            logs[i].status = .failed
        }
        isTesting = false
        finalizeTesting()
    }

    // MARK: - Private helpers

    private func runGroup(target: URL, concurrency: Int, method: String, body: String) async {
        await withTaskGroup(of: Void.self) { group in
            // Spawn N child tasks
            for _ in 0..<concurrency {
                group.addTask { [weak self] in
                    await self?.executeSingleRequest(url: target, method: method, body: body)
                }
            }
            // Wait for all child tasks to finish
            await group.waitForAll()
        }

        // All child tasks finished or were cancelled
        await MainActor.run { [weak self] in
            self?.isTesting = false
            self?.finalizeTesting()
        }
    }

    private func executeSingleRequest(url: URL, method: String, body: String) async {
        guard !Task.isCancelled else { return }

        let logIndex: Int = await MainActor.run {
            let newLog = RequestLog(startTime: Date(), url: url.absoluteString, method: method)
            logs.append(newLog)
            metrics.totalRequests += 1
            return logs.count - 1
        }

        let session = URLSession.shared
        do {
            let start = Date()
            var request = URLRequest(url: url)
            request.httpMethod = method
            if method == "POST" {
                request.httpBody = body.data(using: .utf8)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            let (data, response) = try await session.data(for: request)
            let end = Date()
            let duration = end.timeIntervalSince(start)

            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            let responseBody = String(data: data, encoding: .utf8)

            await MainActor.run {
                logs[logIndex].endTime = end
                logs[logIndex].duration = duration
                logs[logIndex].status = .success
                logs[logIndex].url = url.absoluteString
                logs[logIndex].method = method
                logs[logIndex].statusCode = statusCode
                logs[logIndex].responseBody = responseBody
                logs[logIndex].errorMessage = nil
                metrics.succeeded += 1
                recalcAverage()
            }
        } catch {
            await MainActor.run {
                logs[logIndex].status = .failed
                logs[logIndex].errorMessage = error.localizedDescription
                metrics.failed += 1
            }
        }
    }

    private func recalcAverage() {
        let finished = logs.compactMap { $0.duration }
        guard !finished.isEmpty else { return }
        metrics.avgDuration = finished.reduce(0, +) / Double(finished.count)
    }

    private func finalizeTesting() {
        if let start = startTimestamp {
            metrics.totalTestingTime = Date().timeIntervalSince(start)
        }
    }
}
