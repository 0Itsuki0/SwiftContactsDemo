//
//  InterfacePicker.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/04.
//


import SwiftUI

// 0: Using [`ContactsUI`](https://developer.apple.com/documentation/ContactsUI) for View/Edit/Add contact -> No need to manage data store by ourselves
// 1: Using custom UI for View/Edit/Add contact -> manage datastore access by ourselves
struct InterfacePicker: View {
    @Binding var selectedInterface: Int

    var body: some View {
        Picker(selection: $selectedInterface, content: {
            Text("ContactsUI")
                .tag(0)
            Text("Custom Interface")
                .tag(1)
        }, label: {
            Text("Interface Picker")
        })
        .labelsHidden()
    }
}
