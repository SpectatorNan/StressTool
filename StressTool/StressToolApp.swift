//
//  StressToolApp.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import SwiftData
import SwiftUI

@main
struct StressToolApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var sharedPersistentLogModelContainer: ModelContainer = {
    let schema = Schema([
      PersistentLog.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedPersistentLogModelContainer)
    //        .modelContainer(sharedModelContainer)
  }
}
