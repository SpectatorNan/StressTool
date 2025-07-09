//
//  ContentView.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @StateObject private var tester = ConcurrencyTester()
        @State private var targetURL: String = "http://198.19.249.2:21080"
        @State private var concurrencyText: String = "5"
        @State private var httpMethod: String = "GET"
        @State private var requestBody: String = ""
    var concurrencyValue: Int {
            Int(concurrencyText) ?? 1
        }
    
    var minConcurrency: Int = 1
    var maxConcurrency: Int = 10000
    /// Allowed range 1…100
        var isValidConcurrency: Bool {
            (minConcurrency...maxConcurrency).contains(concurrencyValue)
        }

        var validationMessage: String? {
            if concurrencyText.isEmpty {
                return "请输入 \(minConcurrency)‑\(maxConcurrency) 的数字"
            }
            if concurrencyText.contains(where: { !$0.isNumber }) {
                return "只能输入数字"
            }
            if !isValidConcurrency {
                return "合法范围 \(minConcurrency)‑\(maxConcurrency)"
            }
            return nil
        }
    // https://reg.localharbor.com/
    var body: some View {
        VStack(spacing: 16) {
            // Input area
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text("请求地址")
                    TextField("https://example.com", text: $targetURL)
                        .textFieldStyle(.roundedBorder)
                        .disabled(tester.isTesting)
                    VStack {
                        HStack(alignment: .center, spacing: 8) {
                            
                            Text("并发数量")
                            TextField("并发数 (1‑100)", text: $concurrencyText)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                                .disabled(tester.isTesting)
                                .onChange(of: concurrencyText, {
//                                    concurrencyText = concurrencyText.filter { $0.isNumber }.prefix(3).description
                                    let filteredValue = concurrencyText.filter { $0.isNumber } // 过滤数字
                                    let limitedValue = filteredValue

                                    if let concurrencyValue = Int(limitedValue), concurrencyValue > maxConcurrency {
                                        concurrencyText = "\(maxConcurrency)" // 如果超过 maxConcurrency，设置为 maxConcurrency
                                    } else {
                                        concurrencyText = limitedValue.description // 否则保留原值
                                    }

                                })
                            
                        }
                        if let msg = validationMessage {
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                }
                
                Picker("请求方式", selection: $httpMethod) {
                    Text("GET").tag("GET")
                    Text("POST").tag("POST")
                }
                .pickerStyle(.segmented)
                .disabled(tester.isTesting)
                .padding(.vertical, 2)
                if httpMethod == "POST" {
                    TextField("请求参数(JSON)", text: $requestBody, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 60, maxHeight: 120)
                        .disabled(tester.isTesting)
                        .padding(.bottom, 2)
                }
                
            }

                // Control buttons
                HStack {
                    Button(action: { tester.startTesting(url: targetURL, concurrency: concurrencyValue, method: httpMethod, body: requestBody) }) {
                        Label("开始测试", systemImage: "play.fill")
                    }
                    .disabled(tester.isTesting || !isValidConcurrency)

                    Button(action: { tester.stopTesting() }) {
                        Label("停止", systemImage: "stop.fill")
                    }
                    .disabled(!tester.isTesting)
                }
                .buttonStyle(.borderedProminent)

                // Dashboard
                DashboardView(metrics: tester.metrics)
                    .padding(.vertical)

                // Request list
                List(tester.logs) { log in
                    RequestRow(log: log)
                }
                .listStyle(.plain)
            }
            .padding()
        }
    
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//            .toolbar {
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
