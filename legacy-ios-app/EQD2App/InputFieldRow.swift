import SwiftUI

/// Lightweight reusable input field with automatic select-all on focus
struct InputFieldRow<F: Hashable>: View {
    let label: String
    let placeholder: String
    let unit: String?
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let focusField: F
    @FocusState.Binding var focusedField: F?

    init(
        label: String,
        placeholder: String,
        unit: String? = nil,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .decimalPad,
        focusField: F,
        focusedField: FocusState<F?>.Binding
    ) {
        self.label = label
        self.placeholder = placeholder
        self.unit = unit
        self._text = text
        self.keyboardType = keyboardType
        self.focusField = focusField
        self._focusedField = focusedField
    }

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 110, alignment: .leading)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: focusField)
            if let unit = unit {
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = focusField
            if !text.isEmpty {
                // Single delayed select-all - simpler than dual gesture pattern
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}
