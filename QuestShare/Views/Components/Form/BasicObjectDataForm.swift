//
//  BasicObjectDataForm.swift
//  QuestShare
//
//  Created by Karol Wojtas on 27/05/2021.
//

import SwiftUI

struct BasicObjectDataForm: View {
    var disabled: Bool = false
    @Binding var name: String
    @Binding var desc: String
    var namePrompt: String? = nil
    
    var body: some View {
        RoundedRectangleContainer {
            HStack {
                Spacer()
                Text("form-basic-data")
                    .font(.title3)
                Spacer()
            }.padding(.vertical)
            FormInputField(name: "form-name", value: $name, disabled: disabled, prompt: namePrompt)
            Divider()
            FormInputField(name: "form-desc", value: $desc, disabled: disabled, type: .editor)
        }
        
    }
}

struct BasicObjectDataForm_Previews: PreviewProvider {
    @State static var name: String = ""
    @State static var desc: String = ""
    static var previews: some View {
        BasicObjectDataForm(name: $name, desc: $desc, namePrompt: "*required")
    }
}
