import XCTest

@testable import EQD2App

@MainActor
final class CalculationHistoryTests: XCTestCase {

    var history: CalculationHistory!
    let testStorageKey = "calculationHistory"

    override func setUp() async throws {
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: testStorageKey)
        history = CalculationHistory()
        // Give async init time to complete
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testStorageKey)
        history = nil
    }

    // MARK: - Basic Functionality Tests

    func testAddEntry() {
        XCTAssertEqual(history.entries.count, 0, "History should start empty")

        history.addEntry(type: "EQD2", inputs: "D=50 Gy", result: "50.00 Gy")

        XCTAssertEqual(history.entries.count, 1)
        XCTAssertEqual(history.entries[0].type, "EQD2")
        XCTAssertEqual(history.entries[0].inputs, "D=50 Gy")
        XCTAssertEqual(history.entries[0].result, "50.00 Gy")
    }

    func testAddMultipleEntries() {
        history.addEntry(type: "EQD2", inputs: "D=50 Gy", result: "50.00 Gy")
        history.addEntry(type: "Reverse", inputs: "EQD2=60 Gy", result: "62.00 Gy")
        history.addEntry(type: "EQD2", inputs: "D=70 Gy", result: "70.00 Gy")

        XCTAssertEqual(history.entries.count, 3)
    }

    // MARK: - Maximum Entry Limit Tests

    func testMaxEntriesLimit() {
        // Add 150 entries to exceed the 100 entry limit
        for i in 0..<150 {
            history.addEntry(
                type: "Test",
                inputs: "Input \(i)",
                result: "Result \(i)"
            )
        }

        // Should cap at 100
        XCTAssertEqual(history.entries.count, 100, "History should cap at 100 entries")

        // Should keep most recent entries (entries 50-149 were kept, 0-49 were removed)
        XCTAssertEqual(
            history.entries.first?.inputs, "Input 149", "Most recent entry should be first")
        XCTAssertEqual(
            history.entries.last?.inputs, "Input 50", "50th most recent entry should be last")
    }

    func testMaxEntriesLimitBoundary() {
        // Add exactly 100 entries
        for i in 0..<100 {
            history.addEntry(type: "Test", inputs: "Input \(i)", result: "Result \(i)")
        }

        XCTAssertEqual(history.entries.count, 100)

        // Add one more
        history.addEntry(type: "Test", inputs: "Input 100", result: "Result 100")

        // Should still be 100
        XCTAssertEqual(history.entries.count, 100)
        XCTAssertEqual(history.entries.first?.inputs, "Input 100")
        XCTAssertEqual(history.entries.last?.inputs, "Input 1")
    }

    // MARK: - Deletion Tests

    func testDeleteEntry() {
        history.addEntry(type: "A", inputs: "1", result: "1")
        history.addEntry(type: "B", inputs: "2", result: "2")
        history.addEntry(type: "C", inputs: "3", result: "3")

        XCTAssertEqual(history.entries.count, 3)

        // Delete middle entry (B)
        history.deleteEntry(at: IndexSet(integer: 1))

        XCTAssertEqual(history.entries.count, 2)
        XCTAssertEqual(history.entries[0].type, "C", "First entry should be C")
        XCTAssertEqual(history.entries[1].type, "A", "Second entry should be A")
    }

    func testDeleteMultipleEntries() {
        for i in 0..<5 {
            history.addEntry(type: "Test \(i)", inputs: "\(i)", result: "\(i)")
        }

        // Delete entries at indices 1 and 3
        history.deleteEntry(at: IndexSet([1, 3]))

        XCTAssertEqual(history.entries.count, 3)
        XCTAssertEqual(history.entries[0].type, "Test 4")
        XCTAssertEqual(history.entries[1].type, "Test 2")
        XCTAssertEqual(history.entries[2].type, "Test 0")
    }

    func testClearAll() {
        for i in 0..<10 {
            history.addEntry(type: "Test", inputs: "\(i)", result: "\(i)")
        }

        XCTAssertEqual(history.entries.count, 10)

        history.clearAll()

        XCTAssertEqual(history.entries.count, 0, "All entries should be cleared")
    }

    // MARK: - Persistence Tests

    func testSaveAndLoad() async throws {
        // Add some entries
        history.addEntry(type: "EQD2", inputs: "D=50 Gy, n=25, α/β=10", result: "50.00 Gy")
        history.addEntry(type: "Reverse", inputs: "EQD2=60 Gy, n=30, α/β=3", result: "62.50 Gy")

        // Wait for async save to complete
        try await Task.sleep(nanoseconds: 200_000_000)  // 0.2s

        // Create new instance (simulates app restart)
        let newHistory = CalculationHistory()

        // Wait for async load to complete
        try await Task.sleep(nanoseconds: 200_000_000)  // 0.2s

        // Should have loaded previous entries
        XCTAssertEqual(newHistory.entries.count, 2, "Should load saved entries")
        XCTAssertEqual(newHistory.entries[0].type, "Reverse", "Most recent entry should be first")
        XCTAssertEqual(newHistory.entries[1].type, "EQD2", "Oldest entry should be last")
        XCTAssertEqual(newHistory.entries[0].inputs, "EQD2=60 Gy, n=30, α/β=3")
        XCTAssertEqual(newHistory.entries[1].result, "50.00 Gy")
    }

    func testPersistenceAfterDeletion() async throws {
        // Add entries
        history.addEntry(type: "A", inputs: "1", result: "1")
        history.addEntry(type: "B", inputs: "2", result: "2")
        history.addEntry(type: "C", inputs: "3", result: "3")

        // Delete one
        history.deleteEntry(at: IndexSet(integer: 1))

        // Wait for save
        try await Task.sleep(nanoseconds: 200_000_000)

        // Load in new instance
        let newHistory = CalculationHistory()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(newHistory.entries.count, 2)
        XCTAssertEqual(newHistory.entries[0].type, "C")
        XCTAssertEqual(newHistory.entries[1].type, "A")
    }

    func testPersistenceAfterClearAll() async throws {
        // Add entries
        for i in 0..<5 {
            history.addEntry(type: "Test", inputs: "\(i)", result: "\(i)")
        }

        // Clear all
        history.clearAll()

        // Wait for save
        try await Task.sleep(nanoseconds: 200_000_000)

        // Load in new instance
        let newHistory = CalculationHistory()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(newHistory.entries.count, 0, "Cleared history should persist")
    }

    // MARK: - Corrupted Data Handling Tests

    func testLoadCorruptedData() async throws {
        // Write corrupted JSON to UserDefaults
        let corruptedData = "not valid json".data(using: .utf8)!
        UserDefaults.standard.set(corruptedData, forKey: testStorageKey)

        let newHistory = CalculationHistory()

        // Wait for load attempt
        try await Task.sleep(nanoseconds: 200_000_000)

        // Should gracefully handle corruption by starting with empty array
        XCTAssertEqual(newHistory.entries.count, 0, "Should handle corrupted data gracefully")
    }

    func testLoadInvalidStructure() async throws {
        // Write valid JSON but wrong structure
        let invalidJSON = "[{\"wrong\": \"structure\"}]".data(using: .utf8)!
        UserDefaults.standard.set(invalidJSON, forKey: testStorageKey)

        let newHistory = CalculationHistory()

        // Wait for load attempt
        try await Task.sleep(nanoseconds: 200_000_000)

        // Should handle invalid structure gracefully
        XCTAssertEqual(newHistory.entries.count, 0)
    }

    // MARK: - Entry Ordering Tests

    func testEntryOrdering() async throws {
        history.addEntry(type: "First", inputs: "1", result: "1")
        try await Task.sleep(nanoseconds: 50_000_000)  // 0.05s

        history.addEntry(type: "Second", inputs: "2", result: "2")
        try await Task.sleep(nanoseconds: 50_000_000)

        history.addEntry(type: "Third", inputs: "3", result: "3")

        // Most recent should be first
        XCTAssertEqual(history.entries[0].type, "Third")
        XCTAssertEqual(history.entries[1].type, "Second")
        XCTAssertEqual(history.entries[2].type, "First")

        // Verify timestamps are descending
        XCTAssertGreaterThan(
            history.entries[0].timestamp,
            history.entries[1].timestamp,
            "Newer entries should have later timestamps"
        )
        XCTAssertGreaterThan(
            history.entries[1].timestamp,
            history.entries[2].timestamp,
            "Newer entries should have later timestamps"
        )
    }

    // MARK: - Data Integrity Tests

    func testEntryHasUniqueID() {
        history.addEntry(type: "A", inputs: "1", result: "1")
        history.addEntry(type: "B", inputs: "2", result: "2")

        let id1 = history.entries[0].id
        let id2 = history.entries[1].id

        XCTAssertNotEqual(id1, id2, "Each entry should have a unique ID")
    }

    func testEntryTimestampIsRecent() {
        let beforeTime = Date()
        history.addEntry(type: "Test", inputs: "input", result: "result")
        let afterTime = Date()

        let entryTime = history.entries[0].timestamp

        XCTAssertGreaterThanOrEqual(entryTime, beforeTime)
        XCTAssertLessThanOrEqual(entryTime, afterTime)
    }

    // MARK: - Edge Cases

    func testEmptyHistory() async throws {
        // Don't add any entries
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(history.entries.count, 0)

        // Should be able to load empty history
        let newHistory = CalculationHistory()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(newHistory.entries.count, 0)
    }

    func testAddEntryWithEmptyStrings() {
        history.addEntry(type: "", inputs: "", result: "")

        XCTAssertEqual(history.entries.count, 1)
        XCTAssertEqual(history.entries[0].type, "")
        XCTAssertEqual(history.entries[0].inputs, "")
        XCTAssertEqual(history.entries[0].result, "")
    }

    func testAddEntryWithSpecialCharacters() {
        let specialInputs = "α/β=10, D=50±2 Gy, \"quoted\", 'single'"
        history.addEntry(type: "Special", inputs: specialInputs, result: "50.00 Gy")

        XCTAssertEqual(history.entries.count, 1)
        XCTAssertEqual(history.entries[0].inputs, specialInputs)
    }

    func testAddEntryWithVeryLongStrings() async throws {
        let longString = String(repeating: "A", count: 1000)
        history.addEntry(type: "Long", inputs: longString, result: longString)

        XCTAssertEqual(history.entries.count, 1)
        XCTAssertEqual(history.entries[0].inputs.count, 1000)

        // Should persist long strings
        try await Task.sleep(nanoseconds: 200_000_000)
        let newHistory = CalculationHistory()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(newHistory.entries[0].inputs.count, 1000)
    }
}
