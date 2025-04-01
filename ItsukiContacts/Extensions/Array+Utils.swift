//
//  Array.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/30.
//

import SwiftUI
import Contacts

extension Array {

    func sortedContacts(by sortOrder: CNContactSortOrder = .userDefault) -> [CNContact] {
        guard let self = self as? [CNContact] else {
            return []
        }
        let comparator = CNContact.comparator(forNameSortOrder: sortOrder)
        return self.sorted(by: { (first: CNContact, second: CNContact) in
            return comparator(first, second) == .orderedAscending
            //            return first.familyName.localizedCaseInsensitiveCompare(second.familyName) == .orderedAscending
        })
    }
}
