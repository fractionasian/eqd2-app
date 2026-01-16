import SwiftUI

@main
struct EQD2AppApp: App {
    @StateObject private var calculationHistory = CalculationHistory()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calculationHistory)
        }
    }
}
