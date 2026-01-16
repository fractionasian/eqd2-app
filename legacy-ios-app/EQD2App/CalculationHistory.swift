import Foundation
import os.log

private let logger = Logger(subsystem: "com.eqd2app", category: "CalculationHistory")

struct CalculationEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: String
    let inputs: String
    let result: String

    init(id: UUID = UUID(), timestamp: Date = Date(), type: String, inputs: String, result: String)
    {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.inputs = inputs
        self.result = result
    }
}

@MainActor
class CalculationHistory: ObservableObject {
    @Published var entries: [CalculationEntry] = []

    private let storageKey = "calculationHistory"
    private let maxEntries = 100

    init() {
        // Load history asynchronously to avoid blocking app launch
        Task {
            await loadHistory()
        }
    }

    func addEntry(type: String, inputs: String, result: String) {
        let entry = CalculationEntry(type: type, inputs: inputs, result: result)
        entries.insert(entry, at: 0)

        // Keep only the most recent entries
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }

        saveHistory()
    }

    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearAll() {
        entries.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        do {
            let encoded = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            logger.error("Failed to save calculation history: \(error.localizedDescription)")
        }
    }

    private func loadHistory() async {
        // Capture the storage key value to avoid capturing self in detached task
        let key = storageKey

        // Perform loading on background thread
        let data = await Task.detached {
            UserDefaults.standard.data(forKey: key)
        }.value

        guard let data = data else {
            logger.info("No saved history found")
            return
        }

        do {
            // Decode on background thread
            let decodedEntries = try await Task.detached {
                try JSONDecoder().decode([CalculationEntry].self, from: data)
            }.value

            // Update UI on main thread
            self.entries = decodedEntries
            logger.info("Successfully loaded \(self.entries.count) history entries")
        } catch {
            logger.error("Failed to decode calculation history: \(error.localizedDescription)")
            self.entries = []
        }
    }
}
