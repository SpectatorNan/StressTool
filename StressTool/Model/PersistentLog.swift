//
//  Untitled.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import Foundation
import SwiftData

@Model
class PersistentLog {
  var startTime: Date
  var duration: Double?
  var status: String

  init(startTime: Date, duration: Double?, status: String) {
    self.startTime = startTime
    self.duration = duration
    self.status = status
  }
}
