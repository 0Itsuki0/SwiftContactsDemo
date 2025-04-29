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
        case saveRequestError(String)
        
        var message: String {
            switch self {
            case .requestAccessError(let message):
                return message
            case .fetchRequestError(let message):
                return message
            case .saveRequestError(let message):
                return message
            }
        }
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
        
        // fetches all the keys required for displaying the contact on CNContactViewController
        // basically everything needed
        // Not: will only fetch notes if entitlement exists
        CNContactViewController.descriptorForRequiredKeys(),

        /* for customizing keys to fetch */
        
//         full name
//        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),

//         keys required for the contact sort comparator
//        CNContact.descriptorForAllComparatorKeys(),
        
//         some other info
//         Contact keys available: https://developer.apple.com/documentation/contacts/contact-keys

//        CNContactThumbnailImageDataKey as CNKeyDescriptor,
//        CNContactPhoneNumbersKey as CNKeyDescriptor,
//        CNContactEmailAddressesKey as CNKeyDescriptor,
//        CNContactBirthdayKey as CNKeyDescriptor,
        
//         `com.apple.developer.contacts.notes` entitlement is required to fetch notes
//        CNContactNoteKey as CNKeyDescriptor
    ]
    
    init() {
        getAuthorizationStatus()
        Task {
            await listenToContactStoreChange()
        }
    }
}

// MARK: - Fetch Contacts
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

// MARK: - Save Contacts Changes
extension ContactManager {
    
    
    func createNewContact(/*givenName: String, familyName: String, homeEmail: String, workEmail: String, phoneNumber: String, address: String*/) async {
        let contact = CNMutableContact()

        contact.givenName = "itsuki"
        contact.familyName = "ppp"

        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "john@example.com" as NSString)
        let workEmail = CNLabeledValue(label: CNLabelWork, value: "j.appleseed@icloud.com" as NSString)
        contact.emailAddresses = [homeEmail, workEmail]

        contact.phoneNumbers = [CNLabeledValue(
            label: CNLabelPhoneNumberiPhone,
            value: CNPhoneNumber(stringValue: "(408) 555-0126"))
        ]

        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "One Apple Park Way"
        homeAddress.city = "Cupertino"
        homeAddress.state = "CA"
        homeAddress.postalCode = "95014"
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: homeAddress)]

        contact.note = "some notes"

        var birthday = DateComponents()
        birthday.day = 1
        birthday.month = 4
        // (Optional) Omit the year value for a year-less birthday.
        birthday.year = 1988
        contact.birthday = birthday
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        await self.executeSaveRequest(saveRequest)
    }


    // contact = nil to create a new contact, otherwise updating an existing one fetched previously
    func saveContact(contact: CNContact?, givenName: String, familyName: String, email: String, phoneNumber: String, url: String) async {
       
        let mutableContact = contact?.mutableCopy() as? CNMutableContact ?? CNMutableContact()

        mutableContact.givenName = givenName
        mutableContact.familyName = familyName

        let homeEmail = CNLabeledValue(label: CNLabelHome, value: email as NSString)
        mutableContact.emailAddresses = [homeEmail]

        mutableContact.phoneNumbers = [CNLabeledValue(
            label: CNLabelPhoneNumberMain,
            value: CNPhoneNumber(stringValue: phoneNumber))
        ]
        
        mutableContact.urlAddresses = [CNLabeledValue(label: CNLabelURLAddressHomePage, value: url as NSString)]

        // to add/edit address
//        let homeAddress = CNMutablePostalAddress()
//        homeAddress.street = "123 main street"
//        homeAddress.city = "itsuki city"
//        homeAddress.state = "IK"
//        homeAddress.postalCode = "itsuki000"
//        mutableContact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: homeAddress)]

        // to add/edit notes
//        mutableContact.note = "some notes"

        // to add/edit birthday
//        var birthday = DateComponents()
//        birthday.day = 1
//        birthday.month = 1
//        // (Optional) Omit the year value for a year-less birthday.
//        birthday.year = 1111
//        mutableContact.birthday = birthday
        
        let saveRequest = CNSaveRequest()
        if contact != nil {
            // Update an existing contact in the contact store.
            saveRequest.update(mutableContact)
        } else {
            // Add a new contact to the contact store
            saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        }
        await self.executeSaveRequest(saveRequest)
    }
    
    // Delete a contact from the contact store.
    func deleteContact(_ contact: CNContact) async {
        guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutableContact)
        await self.executeSaveRequest(saveRequest)
    }
    
    nonisolated private func executeSaveRequest(_ saveRequest: CNSaveRequest) async {
        do {
            try await store.execute(saveRequest)
        } catch(let error) {
            DispatchQueue.main.async {
                self.error = Error.saveRequestError("Failed to save contacts: \(error)")
            }
        }
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
            if notification.name == .CNContactStoreDidChange {
                await self.fetchContacts()
            }
            // keys in notification.userInfo:
            // - CNNotificationSaveIdentifiersKey: NSArray
            // - CNNotificationSourcesKey: NSArray
            // - CNNotificationOriginationExternally: 0 or 1

        }
    }
}
