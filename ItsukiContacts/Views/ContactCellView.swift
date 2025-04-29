//
//  ContactCellView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/30.
//

import SwiftUI
import Contacts

struct ContactCellView: View {
    var contact: CNContact
    
    var body: some View {
        HStack(spacing: 16) {
            IconView(contact: contact)
            Text(contact.fullName)
        }
    }
}



#Preview {
    var contact: CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = "Itsuki"
        contact.familyName = "Itsuki"
        return contact
    }

    return List {
        ContactCellView(contact: contact as CNContact)
    }
}
