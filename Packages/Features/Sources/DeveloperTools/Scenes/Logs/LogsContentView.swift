//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import SwiftUI

#if DEBUG
  struct LogsContentView: View {
    let entries: [LogStore.Entry]

    @Binding
    var isInReversedOrder: Bool

    @Binding
    var period: LogPeriod

    @Binding
    var category: LogCategory?

    var body: some View {
      List {
        Section("Filters") {
          Picker("Order", selection: $isInReversedOrder) {
            Text("Direct").tag(false)
            Text("Reversed").tag(true)
          }

          Picker("Period", selection: $period) {
            ForEach(LogPeriod.allCases, id: \.self) { period in
              let title: LocalizedStringKey =
                switch period {
                  case .last10Minutes: "Last 10 minutes"
                  case .last24Hours: "Last 24 hours"
                }
              Text(title).tag(period)
            }
          }

          Picker("Category", selection: $category) {
            Text("All").tag(nil as LogCategory?)
            ForEach(LogCategory.allCases, id: \.self) { category in
              Text(category.rawValue).tag(category)
            }
          }
        }

        ForEach(isInReversedOrder ? entries.reversed() : entries) { entry in
          LogRow(model: entry)
        }
      }
    }
  }

  #Preview {
    LogsContentView(
      entries: Seeds.LogEntry.levels,
      isInReversedOrder: .constant(false),
      period: .constant(.last10Minutes),
      category: .constant(nil)
    )
  }
#endif
