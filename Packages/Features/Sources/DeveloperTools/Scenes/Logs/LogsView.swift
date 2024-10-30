//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import OSLog
import SwiftUI

#if DEBUG
  struct LogsView: View {
    @Injected(\.logStore)
    private var logStore

    @State
    private var entries: [LogStore.Entry]?
    @State
    private var contentForShare: String?
    @State
    private var isLoading = false

    @AppStorage("LogsView.isInReversedOrder")
    private var isInReversedOrder = false
    @AppStorage("LogsView.period")
    private var period: LogPeriod = .last10Minutes
    @AppStorage("LogsView.category")
    private var category: LogCategory?

    var body: some View {
      Group {
        if let entries {
          LogsContentView(
            entries: entries,
            isInReversedOrder: $isInReversedOrder,
            period: $period,
            category: $category
          )
          .refreshable {
            await loadData()
          }
        } else {
          ProgressView()
        }
      }
      .onChange(of: period) {
        reload()
      }
      .onChange(of: category) {
        reload()
      }
      .task(priority: .userInitiated) {
        await loadData()
      }
      .navigationTitle("Logs")
      .toolbar {
        #if os(macOS)
          Button("Refresh", systemImage: "arrow.clockwise") {
            Task {
              await loadData()
            }
          }
        #endif

        ShareLink(item: contentForShare ?? "")
          .disabled(contentForShare == nil)
      }
      .disabled(isLoading)
    }

    private func loadData() async {
      isLoading = true
      let entries = await logStore.getLogEntries(period: TimeInterval(period.rawValue), category: category)
      self.entries = entries
      isLoading = false

      contentForShare = LogStore.EntriesFormatter.format(entries: entries)
    }

    private func reload() {
      Task(priority: .userInitiated) {
        entries = []
        contentForShare = nil
        await loadData()
      }
    }
  }

  #Preview {
    NavigationStack {
      LogsView()
    }
  }
#endif
