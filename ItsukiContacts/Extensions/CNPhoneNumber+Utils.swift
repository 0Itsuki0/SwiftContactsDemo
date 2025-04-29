//
//  CNPhoneNumber+Utils.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/05.
//

import Contacts

extension CNPhoneNumber {
    var digits: String? {
        return self.value(forKey: "digits") as? String
    }
}
