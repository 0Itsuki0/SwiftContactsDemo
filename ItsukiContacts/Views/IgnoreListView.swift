//
//  IgnoreListView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/01.
//

import SwiftUI

struct IgnoreListView: View {
    
    @Binding var ignoredEmails: Set<String>
    @Binding var ignoredPhoneNumbers: Set<String>
    
    @Environment(\.dismiss) private var dismiss
    

//    @State private var ignoredEmails: Set<String> = []
//    @State private var ignoredPhoneNumbers: Set<String> = []

    @AppStorage("ignoredEmails") var savedIgnoreEmails: String = ""
    @AppStorage("ignoredPhoneNumbers") var savedIgnoredPhoneNumbers: String = ""

    @State private var showAddNewIgnoreSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    Button(action: {
                        showAddNewIgnoreSheet = true
                    }, label: {
                        Text("Add an email or phone number")
                    })
                }
                
                Section {
                    ForEach(Array(ignoredEmails), id: \.self) { email in
                        Text(email)
                    }
                    .onDelete { indexSet in
                        self.ignoredEmails = self.onDelete(ignoredEmails, indexSet: indexSet)
                    }
                    if ignoredEmails.isEmpty {
                        Text("No Email added")
                            .foregroundStyle(.gray)
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Text("Ignored Email")
                        Text("Emails on this list will not show up as `ContactAccessButton` query result.")
                            .textCase(nil)

                    }
                }
                
                
                Section {
                    ForEach(Array(ignoredPhoneNumbers), id: \.self) { phone in
                        Text(phone)
                    }
                    .onDelete { indexSet in
                        self.ignoredPhoneNumbers = self.onDelete(ignoredPhoneNumbers, indexSet: indexSet)
                    }
                    if ignoredPhoneNumbers.isEmpty {
                        Text("No Phone number added")
                            .foregroundStyle(.gray)
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Text("Ignored Phone number")
                        Text("Phone numbers on this list will not show up as `ContactAccessButton` query result.")
                            .textCase(nil)

                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 8)
            .sheet(isPresented: $showAddNewIgnoreSheet, content: {
                AddNewIgnoreItemSheet(ignoredEmails: $ignoredEmails, ignoredPhoneNumbers: $ignoredPhoneNumbers)
            })
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Dismiss")
                    })

                })
                
                ToolbarItem(placement: .principal, content: {
                            Text("Ignore List")
                                .fontWeight(.semibold)

                })
                
                ToolbarItem(placement: .topBarTrailing, content: {
                    if !ignoredEmails.isEmpty || !ignoredPhoneNumbers.isEmpty {
                        EditButton()
                    }
                })
            })
        }
    
    }
    
    func onDelete(_ items: Set<String>, indexSet: IndexSet) -> Set<String> {
        var new = Array(items)
        for index in indexSet {
            new.remove(at: index)
        }
        return Set(new)
    }
}

private struct AddNewIgnoreItemSheet: View {
    @Binding var ignoredEmails: Set<String>
    @Binding var ignoredPhoneNumbers: Set<String>

    @State private var selectedType: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    @State private var text: String = ""
    @State private var message: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                if let message {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
                Section {
                    Picker(selection: $selectedType, content: {
                        Text("Email")
                            .tag(0)
                        Text("Phone Number")
                            .tag(1)
                    }, label: {
                        Text("Ignore Type")
                    })
                }
                
                ClearableTextField(selectedType == 0 ? "Email" : "Phone Number", text: $text)
                    .keyboardType(selectedType == 0 ? .emailAddress : .phonePad)
                    .textContentType(selectedType == 0 ? .emailAddress : .telephoneNumber)
                    .autocorrectionDisabled(true)

            }
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 8)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })

                })
                
                ToolbarItem(placement: .principal, content: {
                    Text("Add New Ignore Item")
                        .fontWeight(.semibold)
                })
                
                ToolbarItem(placement: .confirmationAction, content: {
                    Button(action: {
                        if text.isEmpty {
                            self.message = "Please enter \(selectedType == 0 ? "an email" : "a phone number")."
                            return
                        }
                        if selectedType == 0  {
                            if ignoredEmails.contains(text) {
                                self.message = "Email exists."
                            } else {
                                self.ignoredEmails.insert(text)
                                dismiss()
                            }
                            return
                        }
                        
                        if selectedType == 1 {
                            if ignoredPhoneNumbers.contains(text) {
                                self.message = "Phone number exists."
                            } else {
                                self.ignoredPhoneNumbers.insert(text)
                                dismiss()
                            }
                            return
                        }
                        
                    }, label: {
                        Text("Save")
                    })
                })
            })
            .onChange(of: text, {
                message = nil
            })
            .onChange(of: selectedType, {
                message = nil
            })
        }
       
    }
}


#Preview {
    NavigationStack {
        ContactView()
            .environment(ContactManager())
    }
}
