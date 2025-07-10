//
//  DashboardView.swift
//  StressTool
//
//  Created by spectator on 2025/7/10.
//

import SwiftUI

struct DashboardView: View {

  let metrics: Metrics

  var body: some View {
    VStack(spacing: 8) {
      HStack {
        metricBox(title: "总请求", value: String(metrics.totalRequests))
        metricBox(title: "成功", value: String(metrics.succeeded))
        metricBox(title: "失败", value: String(metrics.failed))
      }
      HStack {
        metricBox(title: "平均耗时(s)", value: String(format: "%.2f", metrics.avgDuration))
        metricBox(title: "总耗时(s)", value: String(format: "%.2f", metrics.totalTestingTime))
      }
    }
  }

  @ViewBuilder
  private func metricBox(title: String, value: String) -> some View {
    VStack {
      Text(value).font(.title3).bold()
      Text(title).font(.footnote)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color(.secondarySystemFill))
    .cornerRadius(8)
  }
}
