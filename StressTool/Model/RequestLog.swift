//
//  RequestLog.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import Foundation

struct RequestLog: Identifiable, Equatable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var duration: Double?
    var status: RequestStatus = .pending
    var url: String?
    var method: String?
    var statusCode: Int?
    var responseBody: String?
    var errorMessage: String?
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, duration: Double? = nil, status: RequestStatus = .pending, url: String? = nil, method: String? = nil, statusCode: Int? = nil, responseBody: String? = nil, errorMessage: String? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.status = status
        self.url = url
        self.method = method
        self.statusCode = statusCode
        self.responseBody = responseBody
        self.errorMessage = errorMessage
    }
}
