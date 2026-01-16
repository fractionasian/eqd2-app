import SwiftUI

struct ReverseEQD2View: View {
    @AppStorage("reverseTargetEQD2") private var targetEQD2: String = ""
    @AppStorage("reverseNumberOfFractions") private var numberOfFractions: String = ""
    @AppStorage("reverseAlphaBeta") private var alphaBeta: String = "10"
    @FocusState private var focusedField: Field?
    @State private var lastSavedResult: Double?
    @EnvironmentObject var calculationHistory: CalculationHistory
    @State private var debounceTask: DispatchWorkItem?

    enum Field {
        case targetEQD2, fractions, alphaBeta
    }

    var totalDose: Double? {
        guard let eqd2 = Double(targetEQD2),
            let fractions = Double(numberOfFractions),
            let ab = Double(alphaBeta)
        else {
            return nil
        }
        return EQD2Calculator.calculateReverse(
            targetEQD2: eqd2, numberOfFractions: fractions, alphaBeta: ab)
    }

    var dosePerFraction: Double? {
        guard let total = totalDose,
            let fractions = Double(numberOfFractions),
            fractions > 0
        else {
            return nil
        }
        return total / fractions
    }

    var inputValidationMessage: String? {
        // Only show errors for non-empty invalid inputs
        if !targetEQD2.isEmpty {
            if Double(targetEQD2) == nil {
                return "Target EQD2 must be a valid number"
            }
            if let eqd2 = Double(targetEQD2), eqd2 <= 0 {
                return "Target EQD2 must be positive"
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
                        label: "Target EQD2", placeholder: "60", unit: "Gy",
                        text: $targetEQD2, focusField: .targetEQD2, focusedField: $focusedField)

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

                if let total = totalDose, let dpf = dosePerFraction {
                    Section {
                        HStack {
                            Text("Total Dose")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(String(format: "%.2f Gy", total))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(
                            "Calculated total dose: \(String(format: "%.2f", total)) Gray"
                        )
                        .accessibilityHint(
                            "This is the required total dose to achieve the target EQD2"
                        )
                        .accessibilityAddTraits(.isStaticText)

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

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Solves: EQD2 = D × [(d + α/β) / (2 + α/β)]")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)

                        Text("For D (total dose) given target EQD2")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Reverse EQD2")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                focusedField = nil
            }
            .onDisappear {
                focusedField = nil
                debounceTask?.cancel()
            }
            .onChange(of: totalDose) { oldValue, newValue in
                if let result = newValue, result != lastSavedResult {
                    lastSavedResult = result

                    // Capture all state at the moment of calculation to prevent race conditions
                    let capturedInputs =
                        "EQD2=\(targetEQD2) Gy, n=\(numberOfFractions), α/β=\(alphaBeta)"
                    let capturedResult = String(format: "%.2f Gy", result)
                    let capturedType = "Reverse"

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
    ReverseEQD2View()
}
