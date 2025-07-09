//
//  RequestRow.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import SwiftUI

struct RequestRow: View {
    let log: RequestLog
    
    @State private var showBody: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss.SSS"
        return df
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(log.startTime, formatter: dateFormatter)
                            .monospacedDigit()
                        if let method = log.method {
                            Text(method)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        if let url = log.url {
                            Text(url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    if let errorMessage = log.errorMessage, log.status == .failed {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                if let statusCode = log.statusCode {
                    Text("\(statusCode)")
                        .font(.caption)
                        .foregroundColor(log.statusCode == 200 ? .green : .orange)
                }
                if let duration = log.duration {
                    Text(String(format: "%.2f s", duration))
                        .monospacedDigit()
                } else {
                    Text("‑‑‑")
                }
                statusCircle
            }
            if let body = log.responseBody, !body.isEmpty {
                Button(action: { showBody.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: showBody ? "chevron.down" : "chevron.right")
                            .font(.caption)
                        Text(showBody ? "收起Body" : "展开Body")
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                if showBody {
                    ScrollView(.horizontal) {
                        Text(body)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(6)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusCircle: some View {
        Circle()
            .fill(color(for: log.status))
            .frame(width: 10, height: 10)
    }

    private func color(for status: RequestStatus) -> Color {
        switch status {
        case .pending: return .gray
        case .success: return .green
        case .failed:  return .red
        }
    }
}
