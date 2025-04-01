//
//  ContactManager.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/29.
//

import SwiftUI
import Contacts
import ContactsUI

@MainActor
@Observable
class ContactManager {
    
    enum Error: Swift.Error {
        case requestAccessError(String)
        case fetchRequestError(String)

    }
    
    var error: Error? {
        didSet {
            if let error {
                print("Error: \(error)")
            }
        }
    }
    
    var contacts: [CNContact] = []
    var authorizationStatus: CNAuthorizationStatus = .notDetermined
    
    let store = CNContactStore()
    
    private let fetchKeyDescriptors: [CNKeyDescriptor] = [
        
        // fetches all the keys required for displaying  the contact on CNContactViewController
        // basically everything needed
        // Not: will only fetch notes if entitlement exists
        CNContactViewController.descriptorForRequiredKeys()

        
        /* for customizing keys to fetch */
        
//         full name
//        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),

//         keys required for the contact sort comparator
//        CNContact.descriptorForAllComparatorKeys(),
        
//         some other info
//         Contact keys available: https://developer.apple.com/documentation/contacts/contact-keys

//        CNContactThumbnailImageDataKey as any CNKeyDescriptor,
//        CNContactPhoneNumbersKey as any CNKeyDescriptor,
//        CNContactEmailAddressesKey as any CNKeyDescriptor,
//        CNContactBirthdayKey as any CNKeyDescriptor,
        
//         `com.apple.developer.contacts.notes` entitlement is required to fetch notes
//        CNContactNoteKey as any CNKeyDescriptor
    ]
    
    init() {
        getAuthorizationStatus()
        Task {
            await listenToContactStoreChange()
        }
    }
    

    

}

// MARK: - Listen to Changes
extension ContactManager {
    func fetchContacts(_ identifiers: [String]? = nil) async {
        let request = CNContactFetchRequest(keysToFetch: self.fetchKeyDescriptors)
        request.sortOrder = .userDefault
        
        if let identifiers {
            request.predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
        }
        let results = await executeFetchRequest(request)
        if identifiers != nil {
            self.contacts = (self.contacts + results).sortedContacts(by: .userDefault)
        } else {
            self.contacts = results
        }
    }
    
    nonisolated private func executeFetchRequest(_ fetchRequest: CNContactFetchRequest) async -> [CNContact] {
        var results: [CNContact] = []
        do {
            try await store.enumerateContacts(with: fetchRequest) { contact, stop in
                results.append(contact)
            }
        } catch(let error) {
            DispatchQueue.main.async {
                self.error = Error.fetchRequestError("Failed to fetch contacts: \(error)")
            }
        }

        return results

    }
}


// MARK: - Authorization
extension ContactManager {
    private func getAuthorizationStatus() {
        self.authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess() async {
        guard authorizationStatus == .notDetermined else { return }
        do {
            try await store.requestAccess(for: .contacts)
            getAuthorizationStatus()
        } catch {
            getAuthorizationStatus()
            self.error = .requestAccessError("Requesting Contacts access failed: \(error)")
        }
    }
}


// MARK: - Listen to Changes
extension ContactManager {
    func listenToContactStoreChange() async {
        
        let notifications = NotificationCenter.default.notifications(named: .CNContactStoreDidChange)
        
        for await notification in notifications {
            print("notification received: \(notification)")
            if notification.name == .CNContactStoreDidChange {
                await self.fetchContacts()
            }
//            guard let userInfo = notification.userInfo else { continue }
            // keys:
            // - CNNotificationSaveIdentifiersKey: NSArray
            // - CNNotificationSourcesKey: NSArray
            // - CNNotificationOriginationExternally: 0 or 1

        }
    }
}
