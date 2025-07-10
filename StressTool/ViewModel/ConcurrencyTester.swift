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

    // 优化：批量刷新日志，减少UI刷新频率
    private var pendingLogs: [UUID: RequestLog] = [:]
    private var logUpdateTimer: Timer?

    // 优化：用于增量计算平均值的辅助变量
    private var totalDuration: Double = 0.0
    private var completedCount: Int = 0

    /// Starts a load‑test with the given url & concurrency level
    func startTesting(url: String, concurrency: Int, method: String = "GET", body: String = "") {
        guard let target = URL(string: url) else { return }

        // Reset state
        logs.removeAll()
        pendingLogs.removeAll()
        metrics = Metrics()
        totalDuration = 0.0
        completedCount = 0
        startTimestamp = Date()
        isTesting = true

        // 启动定时器，定期批量刷新日志 - 降低刷新频率以避免UI卡顿
        logUpdateTimer?.invalidate()
        logUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { await self?.flushPendingLogs() }
        }

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
        
        // Mark unfinished logs as failed in both logs and pendingLogs
        for i in logs.indices where logs[i].status == .pending {
            logs[i].status = .failed
        }
        for (id, var log) in pendingLogs where log.status == .pending {
            log.status = .failed
            pendingLogs[id] = log
        }
        
        isTesting = false
        finalizeTesting()
        logUpdateTimer?.invalidate()
        Task { await flushPendingLogs() }
    }

    private func flushPendingLogs() async {
        await MainActor.run {
            guard !pendingLogs.isEmpty else { return }
            
            // 批量更新，减少单独的数组操作
            let pendingLogArray = Array(pendingLogs.values)
            pendingLogs.removeAll()
            
            // 使用更高效的批量插入
            for log in pendingLogArray {
                if let idx = logs.firstIndex(where: { $0.id == log.id }) {
                    logs[idx] = log
                } else {
                    logs.append(log)
                }
            }
            
            // 移除重新计算平均值，因为使用增量更新
            // recalcAverage()
        }
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
            self?.logUpdateTimer?.invalidate()
        }
        await flushPendingLogs()
    }

    private func executeSingleRequest(url: URL, method: String, body: String) async {
        guard !Task.isCancelled else { return }

        let logId = UUID()
        let newLog = RequestLog(id: logId, startTime: Date(), url: url.absoluteString, method: method)
        await MainActor.run {
            pendingLogs[logId] = newLog
            metrics.totalRequests += 1
        }
        
        // 移除立即刷新，让定时器处理批量更新
        // await flushPendingLogs()

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
                // 先在 pendingLogs 中查找，如果没有则在 logs 中查找
                if var log = pendingLogs[logId] {
                    log.endTime = end
                    log.duration = duration
                    log.status = .success
                    log.url = url.absoluteString
                    log.method = method
                    log.statusCode = statusCode
                    log.responseBody = responseBody
                    log.errorMessage = nil
                    pendingLogs[logId] = log
                } else if let idx = logs.firstIndex(where: { $0.id == logId }) {
                    logs[idx].endTime = end
                    logs[idx].duration = duration
                    logs[idx].status = .success
                    logs[idx].statusCode = statusCode
                    logs[idx].responseBody = responseBody
                    logs[idx].errorMessage = nil
                }
                metrics.succeeded += 1
                // 使用增量计算更新平均值，避免遍历所有数据
                updateAverageIncremental(newDuration: duration)
            }
            // 不立即刷新，让定时器处理批量更新
            // await flushPendingLogs()
        } catch {
            await MainActor.run {
                // 先在 pendingLogs 中查找，如果没有则在 logs 中查找
                if var log = pendingLogs[logId] {
                    log.status = .failed
                    log.errorMessage = error.localizedDescription
                    pendingLogs[logId] = log
                } else if let idx = logs.firstIndex(where: { $0.id == logId }) {
                    logs[idx].status = .failed
                    logs[idx].errorMessage = error.localizedDescription
                }
                metrics.failed += 1
            }
            // 请求失败后也立即刷新UI
            await flushPendingLogs()
        }
    }

    private func recalcAverage() {
        // 高效的批量重新计算 - 只在刷新时调用
        let logsFinished = logs.compactMap { $0.duration }
        let pendingFinished = pendingLogs.values.compactMap { $0.duration }
        let allFinished = logsFinished + pendingFinished
        
        if !allFinished.isEmpty {
            metrics.avgDuration = allFinished.reduce(0, +) / Double(allFinished.count)
        } else {
            metrics.avgDuration = 0.0
        }
    }
    
    // 新增：增量更新平均值的方法，用于单个请求完成时
    private func updateAverageIncremental(newDuration: Double) {
        totalDuration += newDuration
        completedCount += 1
        metrics.avgDuration = totalDuration / Double(completedCount)
    }

    private func finalizeTesting() {
        if let start = startTimestamp {
            metrics.totalTestingTime = Date().timeIntervalSince(start)
        }
    }
}
