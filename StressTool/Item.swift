//
//  Item.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
