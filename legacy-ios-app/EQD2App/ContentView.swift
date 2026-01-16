import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @State private var showingDisclaimer = false
    @EnvironmentObject var calculationHistory: CalculationHistory

    var body: some View {
        TabView {
            ForwardEQD2View()
                .tabItem {
                    Label("EQD2", systemImage: "arrow.right.circle")
                }

            ReverseEQD2View()
                .tabItem {
                    Label("Reverse", systemImage: "arrow.left.circle")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .sheet(isPresented: $showingDisclaimer) {
            DisclaimerView(hasSeenDisclaimer: $hasSeenDisclaimer)
        }
        .onAppear {
            if !hasSeenDisclaimer {
                showingDisclaimer = true
            }
        }
    }
}

struct ForwardEQD2View: View {
    @AppStorage("forwardTotalDose") private var totalDose: String = ""
    @AppStorage("forwardNumberOfFractions") private var numberOfFractions: String = ""
    @AppStorage("forwardAlphaBeta") private var alphaBeta: String = "10"
    @FocusState private var focusedField: Field?
    @State private var lastSavedResult: Double?
    @EnvironmentObject var calculationHistory: CalculationHistory
    @State private var debounceTask: DispatchWorkItem?

    enum Field {
        case totalDose, fractions, alphaBeta
    }

    var dosePerFraction: Double? {
        guard let total = Double(totalDose),
            let fractions = Double(numberOfFractions),
            total > 0, fractions > 0
        else {
            return nil
        }
        return total / fractions
    }

    var eqd2Result: Double? {
        guard let D = Double(totalDose),
            let fractions = Double(numberOfFractions),
            let ab = Double(alphaBeta)
        else {
            return nil
        }
        return EQD2Calculator.calculateForward(
            totalDose: D, numberOfFractions: fractions, alphaBeta: ab)
    }

    var inputValidationMessage: String? {
        // Only show errors for non-empty invalid inputs
        if !totalDose.isEmpty {
            if Double(totalDose) == nil {
                return "Total dose must be a valid number"
            }
            if let d = Double(totalDose), d <= 0 {
                return "Total dose must be positive"
            }
        }

        if !numberOfFractions.isEmpty {
            if Double(numberOfFractions) == nil {
                return "Number of fractions must be a valid number"
            }
            if let n = Double(numberOfFractions), n <= 0 {
                return "Number of fractions must be positive"
            }
        }

        if !alphaBeta.isEmpty {
            if Double(alphaBeta) == nil {
                return "α/β ratio must be a valid number"
            }
            if let ab = Double(alphaBeta), ab <= 0 {
                return "α/β ratio must be positive"
            }
        }

        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    InputFieldRow(
                        label: "Total Dose", placeholder: "50", unit: "Gy",
                        text: $totalDose, focusField: .totalDose, focusedField: $focusedField)

                    InputFieldRow(
                        label: "Fractions", placeholder: "25",
                        text: $numberOfFractions, keyboardType: .numberPad,
                        focusField: .fractions, focusedField: $focusedField)

                    InputFieldRow(
                        label: "α/β Ratio", placeholder: "10",
                        text: $alphaBeta, focusField: .alphaBeta, focusedField: $focusedField)
                }

                if let message = inputValidationMessage {
                    Section {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.body)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if let result = eqd2Result {
                    Section {
                        HStack {
                            Text("EQD2")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(String(format: "%.2f Gy", result))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(
                            "Calculated EQD2: \(String(format: "%.2f", result)) Gray"
                        )
                        .accessibilityHint("This is the equivalent dose in 2 Gray fractions")
                        .accessibilityAddTraits(.isStaticText)

                        if let dpf = dosePerFraction {
                            HStack {
                                Text("Dose/fraction")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.2f Gy", dpf))
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(
                                "Dose per fraction: \(String(format: "%.2f", dpf)) Gray")

                            if dpf < 1 || dpf > 6 {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.body)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Outside Typical Range")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                        Text(
                                            "The linear-quadratic model is most accurate for doses of 1-6 Gy per fraction. Use with caution outside this range."
                                        )
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.vertical, 4)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel(
                                    "Warning: Dose per fraction is \(String(format: "%.2f", dpf)) Gray, which is outside the typical range"
                                )
                                .accessibilityHint(
                                    "The linear-quadratic model is most accurate for doses between 1 and 6 Gray per fraction. Use results with caution outside this range."
                                )
                                .accessibilityAddTraits([.isStaticText])
                            }
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EQD2 = D × [(d + α/β) / (2 + α/β)]")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)

                        Text("D = total dose, d = dose per fraction")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("EQD2")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                focusedField = nil
            }
            .onDisappear {
                focusedField = nil
                debounceTask?.cancel()
            }
            .onChange(of: eqd2Result) { oldValue, newValue in
                if let result = newValue, result != lastSavedResult {
                    lastSavedResult = result

                    // Capture all state at the moment of calculation to prevent race conditions
                    let capturedInputs =
                        "D=\(totalDose) Gy, n=\(numberOfFractions), α/β=\(alphaBeta)"
                    let capturedResult = String(format: "%.2f Gy", result)
                    let capturedType = "EQD2"

                    // Debounce history saving - only save after stable result
                    debounceTask?.cancel()
                    let task = DispatchWorkItem {
                        calculationHistory.addEntry(
                            type: capturedType,
                            inputs: capturedInputs,
                            result: capturedResult
                        )
                    }
                    debounceTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
                }
            }
        }
    }

}

#Preview {
    ForwardEQD2View()
}
