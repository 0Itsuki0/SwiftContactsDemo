//
//  CNContact+Utils.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/30.
//

import Contacts

extension CNContact {
    var fullName: String {
        CNContactFormatter.string(from: self, style: .fullName) ??
        (CNContactFormatter.nameOrder(for: self) == .familyNameFirst ? "\(familyName) \(givenName)" :"\(givenName) \(familyName)")
    }
    
    var initials: String {
        CNContactFormatter.nameOrder(for: self) == .familyNameFirst ?
        "\(self.familyName.prefix(1))\(self.givenName.prefix(1))" :"\(self.givenName.prefix(1))\(self.familyName.prefix(1))"
    }
}
