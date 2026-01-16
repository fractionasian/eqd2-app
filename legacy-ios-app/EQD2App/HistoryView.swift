import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: CalculationHistory

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No calculations yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Your calculation history will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(history.entries) { entry in
                            HistoryEntryRow(entry: entry)
                        }
                        .onDelete(perform: history.deleteEntry)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !history.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(
                                role: .destructive,
                                action: {
                                    withAnimation {
                                        history.clearAll()
                                    }
                                }
                            ) {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

struct HistoryEntryRow: View {
    let entry: CalculationEntry

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.timestamp, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.type)
                    .font(.headline)
                    .foregroundColor(entry.type == "EQD2" ? .blue : .purple)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(entry.inputs)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("Result:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(entry.result)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(entry.type) calculation, \(formattedDate), inputs: \(entry.inputs), result: \(entry.result)"
        )
    }
}

#Preview {
    HistoryView()
}
