//
//  AccessButtonCaptionPicker.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/01.
//


import SwiftUI
import Contacts
import ContactsUI

struct AccessButtonCaptionPicker: View {
    @Binding var accessButtonCaption: ContactAccessButton.Caption

    var body: some View {
        Picker(selection: $accessButtonCaption, content: {
            let captions: [ContactAccessButton.Caption] = [.defaultText, .email, .phone]
            ForEach(captions, id: \.self) { caption in
                Text(caption.rawValue)
                .tag(caption)
            }
        }, label: {
            Text("Access Button Caption Picker")
        })
        .labelsHidden()
    }
}
