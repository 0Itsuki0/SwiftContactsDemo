//
//  CustomEditView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/05.
//

import SwiftUI
import Contacts

struct ContactEntryFormView: View {
    var contact: CNContact?
    var onContactDelete: (() -> Void)?
    @Environment(ContactManager.self) private var manager

    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var url: String
    
    var body: some View {
        Form {
            Section {
                if let error = self.manager.error {
                    Text(error.message)
                        .foregroundStyle(.red)
                }
            }

            Section {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
            }
            .autocorrectionDisabled()
            
            Section {
                TextField("Phone", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            
            Section {
                TextField("Homepage", text: $url)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
            }
            
            if let contact = contact {
                Section {
                    Button(action: {
                        Task {
                            await self.manager.deleteContact(contact)
                            if self.manager.error == nil {
                                self.onContactDelete?()
                            }
                        }
                    }, label: {
                        Text("Delete")
                            .foregroundStyle(.red)
                    })
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            if let contact {
                firstName = contact.givenName
                lastName = contact.familyName
                email = contact.emailAddresses.first?.value as? String ?? ""
                phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                url = contact.urlAddresses.first?.value as? String ?? ""
            }
        }
    }
}
