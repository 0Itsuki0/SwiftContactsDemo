//
//  ClearableTextField.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/31.
//

import SwiftUI

struct ClearableTextField: View {

    var title: String
    @Binding var text: String
    
//    var keyboardType: UIKeyboardType

    init(_ title: String, text: Binding<String> /*keyboardType: UIKeyboardType = .default*/) {
        self.title = title
        self._text = text
//        self.keyboardType = keyboardType
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(title, text: $text)
//                .keyboardType(keyboardType)
                .padding(.trailing, 32)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.8))
                })
            }
        }
    }
}

