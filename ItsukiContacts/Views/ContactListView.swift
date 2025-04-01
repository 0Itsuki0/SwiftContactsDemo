//
//  ContactView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/30.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactView: View {
    @Environment(ContactManager.self) var manager
    
    @State private var searchText: String = ""
    @State private var lastFetchedIdentifiers: [String] = []

    @State private var showContactAccessPicker: Bool = false
    @State private var showNewContactSheet: Bool = false
    @State private var showIgnoreListSheet: Bool = false
    
    @AppStorage("accessButtonCaption") var accessButtonCaption: ContactAccessButton.Caption = .defaultText
    
    @State private var ignoredEmails: Set<String> = []
    @State private var ignoredPhoneNumbers: Set<String> = []

    @AppStorage("ignoredEmails") var savedIgnoreEmails: String = ""
    @AppStorage("ignoredPhoneNumbers") var savedIgnoredPhoneNumbers: String = ""


    var body: some View {
        let filteredContacts: [CNContact] = searchText.isEmpty ? manager.contacts :  manager.contacts.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText)
        }
        let newContacts = filteredContacts.filter { lastFetchedIdentifiers.contains($0.identifier) }
        
        let otherContacts = filteredContacts.filter { !lastFetchedIdentifiers.contains($0.identifier) }
        
        
        List {
            Section {
                ClearableTextField("Search", text: $searchText)
                    .autocorrectionDisabled(true)

            }
            
            if !searchText.isEmpty {
                Section("Other contacts to add") {
                    ContactAccessButton(queryString: searchText, ignoredEmails: self.ignoredEmails, ignoredPhoneNumbers: self.ignoredPhoneNumbers, approvalCallback: { identifiers in
                        
                        self.lastFetchedIdentifiers = identifiers
                        
                        Task {
                            await self.manager.fetchContacts(identifiers)
                        }
                    })
                    .contactAccessButtonStyle(.init(imageTrailingEdgePadding: 16, imageWidth: 40, imageColor: .pink.opacity(0.3)))
                    .contactAccessButtonCaption(accessButtonCaption)
                }
            }
            
            if !lastFetchedIdentifiers.isEmpty {
                Section("New") {
                    ForEach(newContacts) { contact in
                        NavigationLink(destination: {
                            ContactDetailView(contact: contact)
                        }, label: {
                            ContactCellView(contact: contact)
                        })
                    }
                }
            }

            
            Section {
                ForEach(otherContacts) { contact in
                    NavigationLink(destination: {
                        ContactDetailView(contact: contact)
                    }, label: {
                        ContactCellView(contact: contact)
                    })

                }
            }
        }
        .buttonStyle(.plain)
        .navigationTitle("Contacts")
        .overlay(content: {
            if manager.contacts.isEmpty {
                ContentUnavailableView("No Contacts Available", systemImage: "person.crop.circle")
            }
        })
        // for choosing which contact the app can access to
        .contactAccessPicker(isPresented: $showContactAccessPicker, completionHandler: { _ in
            Task {
                await self.manager.fetchContacts()
            }
        })
        // for creating new contacts
        .sheet(isPresented: $showNewContactSheet, content: {
            ContactViewRepresentable(nil, contactStore: self.manager.store, onNewContactSave: { identifier in
                self.showNewContactSheet = false
                if let identifier {
                    self.lastFetchedIdentifiers = [identifier]
                    Task {
                        await self.manager.fetchContacts([identifier])
                    }
                }
            })
            .ignoresSafeArea()
        })
        // for editing ignore list of the access button
        .sheet(isPresented: $showIgnoreListSheet, content: {
            IgnoreListView(ignoredEmails: $ignoredEmails, ignoredPhoneNumbers: $ignoredPhoneNumbers)
        })
        .toolbar(content: {
            Button(action: {
                showNewContactSheet = true
            }, label: {
                Label("New Contact", systemImage: "plus")
                    .labelStyle(.iconOnly)
            })
            
            Menu(content: {
                Button(action: {
                    showContactAccessPicker = true
                }, label: {
                    Text("Access List")
                })
             
                Button(action: {
                    showIgnoreListSheet = true
                    }, label: {
                        Text("Ignore List")
                    })
                
                Menu("Access Button Caption") {
                    AccessButtonCaptionPicker(accessButtonCaption: $accessButtonCaption)
                }
//                .menuActionDismissBehavior(.disabled)


//                Menu("Interfact") {
//                    Picker(selection: .constant(0), content: {
//                        Text("ContactsUI")
//                            .tag(0)
//                        
//                        Text("Custom")
//                            .tag(1)
//                        
//                    }, label: {
//                        Text("Picker")
//                    })
//                }

            }, label: {
                Image(systemName: "gearshape")
            })

        })
        .task {
            await manager.fetchContacts()
        }
        .onChange(of: ignoredEmails, {
            savedIgnoreEmails = ignoredEmails.joined(separator: ",")
        })
        .onChange(of: ignoredPhoneNumbers, {
            savedIgnoredPhoneNumbers = ignoredPhoneNumbers.joined(separator: ",")
        })
        .onAppear {
            ignoredEmails = Set(savedIgnoreEmails.split(separator: ",").map({String($0)}))
            ignoredPhoneNumbers = Set(savedIgnoredPhoneNumbers.split(separator: ",").map({String($0)}))
            print(ignoredPhoneNumbers)
        }
    }
}


#Preview {
    NavigationStack {
        ContactView()
            .environment(ContactManager())
    }
}
