import SwiftUI

struct AboutView: View {
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @State private var showingFullDisclaimer = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("EQD2 Calculator")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This calculator computes the Equivalent Dose in 2 Gy fractions (EQD2) using the linear-quadratic (LQ) model.")
                            .font(.body)

                        Text("The LQ model describes the biological effect of radiation based on the dose per fraction and tissue-specific radiosensitivity (α/β ratio).")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Formula")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EQD2 = D × [(d + α/β) / (2 + α/β)]")
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(6)

                        Text("Where:")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("• D = total dose (Gy)")
                            Text("• d = dose per fraction (Gy)")
                            Text("• α/β = tissue-specific ratio")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Important Limitations")) {
                    VStack(alignment: .leading, spacing: 12) {
                        LimitationRow(
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            title: "Dose Per Fraction Range",
                            description: "The linear-quadratic model is most accurate for doses of 1-6 Gy per fraction. Use with caution outside this range, particularly for stereotactic ablative radiotherapy (SABR/SBRT) where doses exceed 6 Gy per fraction."
                        )

                        LimitationRow(
                            icon: "clock.fill",
                            color: .blue,
                            title: "Time Factor",
                            description: "The basic LQ model does not account for overall treatment time, tumor repopulation, or interfraction repair."
                        )

                        LimitationRow(
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple,
                            title: "High Dose Limitations",
                            description: "At very high doses per fraction (>10 Gy), the LQ model may overestimate biological effect. Alternative models should be considered for SBRT."
                        )
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Common α/β Values")) {
                    VStack(alignment: .leading, spacing: 8) {
                        AlphaBetaRow(tissue: "Early-reacting tissues (acute effects)", value: "10 Gy")
                        AlphaBetaRow(tissue: "Late-reacting tissues (CNS, lung)", value: "3 Gy")
                        AlphaBetaRow(tissue: "Prostate cancer", value: "1.5 Gy")
                        AlphaBetaRow(tissue: "Melanoma", value: "0.6 Gy")
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Medical Disclaimer")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)

                        Text("This tool is for educational purposes only and does not constitute medical advice.")
                            .font(.body)
                            .fontWeight(.semibold)

                        Text("All calculations must be independently verified. Treatment planning decisions should only be made by qualified radiation oncology professionals.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: {
                            showingFullDisclaimer = true
                        }) {
                            HStack {
                                Text("View Full Disclaimer")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("References")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Fowler JF. The linear-quadratic formula and progress in fractionated radiotherapy. Br J Radiol. 1989;62(740):679-694.")
                            .font(.caption)

                        Text("2. Joiner MC, van der Kogel AJ. Basic Clinical Radiobiology. 4th ed. CRC Press; 2009.")
                            .font(.caption)

                        Text("3. AAPM TG-101: Stereotactic Body Radiation Therapy. Med Phys. 2010.")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFullDisclaimer) {
                DisclaimerView(hasSeenDisclaimer: $hasSeenDisclaimer)
            }
        }
    }
}

struct LimitationRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct AlphaBetaRow: View {
    let tissue: String
    let value: String

    var body: some View {
        HStack {
            Text(tissue)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    AboutView()
}
