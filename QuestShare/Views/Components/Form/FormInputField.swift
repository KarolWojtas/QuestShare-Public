//
//  FormInputField.swift
//  QuestShare
//
//  Created by Karol Wojtas on 06/07/2021.
//

import SwiftUI

struct FormInputField: View {
    var name: String? = nil
    @Binding var value: String
    var disabled = false
    var prompt: String? = nil
    var type = FormInputFieldType.input
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack (alignment: .leading){
            if let safeName = name {
                Text(LocalizedStringKey(safeName))
            }
            VStack {
                switch type {
                case .editor:
                    TextEditor(text: $value)
                        .disabled(disabled)
                case .input:
                    TextField("", text: $value)
                        .keyboardType(keyboardType)
                        .disabled(disabled)
                case .secure:
                    SecureField("", text: $value)
                        .disabled(disabled)
                }
            }
            .padding(4.0)
            .background(
                RoundedRectangle(cornerRadius: 6.0)
                    .fill(inputBackgroundColor)
            )
            if let safePrompt = prompt {
                Text(LocalizedStringKey(safePrompt))
                    .font(.caption)
            }
        }
    }
    
    var inputBackgroundColor: Color {
        disabled ? Color.black.opacity(0.0) : Color(UIColor.systemGray5)
    }
}

struct FormInputField_Previews: PreviewProvider {
    @State static var value = "value"
    static var previews: some View {
        FormInputField(value: $value)
    }
}

enum FormInputFieldType {
    case input
    case editor
    case secure
}
