//
//  IconView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/05.
//

import SwiftUI
import Contacts


struct IconView: View {
    var contact: CNContact
    var size: CGFloat = 44
    
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
        .frame(width: size, height: size)
        .background(.pink.opacity(0.3))
        .clipShape(Circle())
    }
}
