import SwiftUI

struct DisclaimerView: View {
    @Binding var hasSeenDisclaimer: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.top)

                    Text("Medical Disclaimer")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("This EQD2 calculator is provided for educational and informational purposes only.")
                            .font(.body)

                        Text("Important Notice:")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 12) {
                            DisclaimerPoint("This tool does NOT constitute medical advice")
                            DisclaimerPoint("All calculations should be independently verified")
                            DisclaimerPoint("Treatment decisions should be made by qualified healthcare professionals")
                            DisclaimerPoint("The developers assume no liability for clinical use")
                            DisclaimerPoint("This calculator uses the linear-quadratic model which has limitations")
                        }

                        Text("By using this application, you acknowledge that:")
                            .font(.headline)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 12) {
                            DisclaimerPoint("You understand the limitations of the linear-quadratic model")
                            DisclaimerPoint("You will verify all calculations independently")
                            DisclaimerPoint("You will not use this as the sole basis for treatment planning")
                            DisclaimerPoint("You accept full responsibility for any clinical decisions")
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)

                    Button(action: {
                        hasSeenDisclaimer = true
                        dismiss()
                    }) {
                        Text("I Understand and Agree")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
}

struct DisclaimerPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
                .font(.body)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    DisclaimerView(hasSeenDisclaimer: .constant(false))
}
