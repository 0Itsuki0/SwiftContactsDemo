//
//  CustomNewContactView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/05.
//

import SwiftUI
import Contacts

struct CustomNewContactView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ContactManager.self) private var manager

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var url: String = ""

    var body: some View {
        NavigationStack {
            ContactEntryFormView(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, url: $url)
                .contentMargins(.top, 20)
                .safeAreaInset(edge: .top, content: {
                    HStack(content:  {
                        Button(action: {
                            self.dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                        .frame(width: 60)

                        Spacer()
                        
                        Text("New Contact")
                            .fontWeight(.semibold)

                        Spacer()
                        
                        Button(action: {
                            Task {
                                await self.manager.saveContact(contact: nil, givenName: firstName, familyName: lastName, email: email, phoneNumber: phoneNumber, url: url)
                                
                                if self.manager.error == nil {
                                    self.dismiss()
                                }
                            }
                            
                        }, label: {
                            Text("Done")
                                .fontWeight(.medium)
                        })
                        .frame(width: 60)

                    })
                    .padding(.all, 16)

                })
        }
        
    }
}


#Preview {
    VStack{
        Text("base")
    }
    .sheet(isPresented: .constant(true), content: {
        CustomNewContactView()
            .environment(ContactManager())

    })
}
