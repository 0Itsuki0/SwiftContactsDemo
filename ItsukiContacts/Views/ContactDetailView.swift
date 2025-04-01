//
//  ContactDetailView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/01.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactDetailView: View {
    var contact: CNContact
    
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    
    var body: some View {
        ContactViewRepresentable(contact, onEditChange: { isEditing in
            self.isEditing = isEditing
        })
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .top, alignment: .leading, content: {
            if !isEditing {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .padding(.all, 8)
                        .foregroundStyle(.white)
                        .background(Circle().fill(.gray.opacity(0.5)))
                })
                .padding(.leading, 8)
            }
        })
    }
}
