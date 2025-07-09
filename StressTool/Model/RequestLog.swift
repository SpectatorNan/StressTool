//
//  RequestLog.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import Foundation

struct RequestLog: Identifiable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var duration: Double?
    var status: RequestStatus = .pending
    var url: String?
    var method: String?
    var statusCode: Int?
    var responseBody: String?
    var errorMessage: String?
}
