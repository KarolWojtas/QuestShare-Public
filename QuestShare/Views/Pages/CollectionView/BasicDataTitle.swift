//
//  BasicDataTitle.swift
//  QuestShare
//
//  Created by Karol Wojtas on 08/07/2021.
//

import SwiftUI

struct BasicDataTitle: View {
    @Binding var name: String
    @Binding var desc: String
    var editMode: Bool
    @State private var basicDataEdit = false
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                Text(name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .background(TextHighlight())
                Spacer()
                if editMode {
                    Button("change"){
                        basicDataEdit.toggle()
                    }
                }
            }
            Divider()
            VStack {
                Text(desc)
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
        .sheet(isPresented: $basicDataEdit, content: {
            BasicObjectDataForm(disabled: !editMode, name: $name, desc: $desc)
                .padding()
                .padding(.bottom, 16)
        })
    }
}

struct BasicDataTitle_Previews: PreviewProvider {
    @State static var name = "Gdynia"
    @State static var desc = "Miasto"
    static var previews: some View {
        BasicDataTitle(name: $name, desc: $desc, editMode: true)
    }
}
