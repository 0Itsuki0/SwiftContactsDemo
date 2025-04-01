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


private struct IconView: View {
    var contact: CNContact
    
    var body: some View {
        Group {
            if let imageData = contact.thumbnailImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                
            } else {
                
                Text(contact.initials)
                    .fontWeight(.bold)
            }

        }
        .frame(width: 44, height: 44)
        .background(.pink.opacity(0.3))
        .clipShape(Circle())

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
