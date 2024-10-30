//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import SwiftUI

#if DEBUG
  struct LogRow: View {
    let model: LogStore.Entry

    var body: some View {
      VStack(alignment: .leading) {
        Text(model.message)

        HStack {
          Text(model.date.formatted(date: .abbreviated, time: .standard))
          Text(model.category)
          Text(model.level.rawValue)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
      .listRowBackground(Color.clear.overlay(backgroundColor.secondary))
    }

    private var backgroundColor: Color {
      switch model.level {
        case .debug: .clear
        case .info: .green
        case .notice: .yellow
        case .error: .red
        case .fault: .red
        case .undefined: .gray
      }
    }
  }

  #Preview {
    List(Seeds.LogEntry.levels) { entry in
      LogRow(model: entry)
    }
  }
#endif
