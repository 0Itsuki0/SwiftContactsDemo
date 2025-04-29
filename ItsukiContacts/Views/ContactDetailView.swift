//
//  ContactDetailView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/01.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactDetailView: View {
    
    var contact: CNContact
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ContactManager.self) private var manager

    @State private var isEditing = false
    
    @AppStorage("interface") var interface: Int = 0

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var url: String = ""

    var body: some View {
        Group {
            if interface == 0 {
                ContactViewRepresentable(contact, onEditChange: { isEditing in
                    self.isEditing = isEditing
                })
                .ignoresSafeArea()
            } else {
                CustomDetailView(contact: contact, onContactDelete: {self.dismiss()}, isEditing: $isEditing, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, url: $url)
            }
        }
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .top, alignment: .leading, content: {
            if !isEditing {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .padding(.all, 8)
                            .foregroundStyle(.white)
                            .background(Circle().fill(.gray.opacity(0.5)))
                    })
                    
                    Spacer()
                    
                    if interface == 1 {
                        Button(action: {
                            isEditing = true
                        }, label: {
                            Text("Edit")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .foregroundStyle(.white)
                                .background(Capsule().fill(.gray.opacity(0.5)))
                        })
                    }

                }
                .padding(.horizontal, 8)

            } else {
                if interface == 1 {
                    HStack {
                        Button(action: {
                            isEditing = false
                        }, label: {
                            Text("Cancel")
                        })

                        Spacer()
                        
                        Button(action: {
                            Task {
                                await self.manager.saveContact(contact: contact, givenName: firstName, familyName: lastName, email: email, phoneNumber: phoneNumber, url: url)
                                if self.manager.error == nil {
                                    isEditing = false
                                }
                            }
                            
                        }, label: {
                            Text("Done")
                                .fontWeight(.semibold)
                        })
                        
                    }
                    .padding(.horizontal, 16)
                }
            }
        })
    }
}


private struct CustomDetailView: View {
    var contact: CNContact
    var onContactDelete: (() -> Void)

    @Binding var isEditing: Bool
    
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var url: String

    
    @Environment(ContactManager.self) private var manager


    var body: some View {
        Group {
            if isEditing {
                ContactEntryFormView(contact: contact, onContactDelete: self.onContactDelete, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, url: $url)
                    .safeAreaInset(edge: .top, alignment: .leading, content: {
                        Text("other info not editable")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 8)
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                    })
                
            } else {
                
                List {
                    Section {
                        if let error = self.manager.error {
                            Text(error.message)
                                .foregroundStyle(.red)
                        }
                    }
                    

                    Section {
                        ForEach(0..<contact.phoneNumbers.count, id: \.self) { index in
                            let labeledValue: CNLabeledValue<CNPhoneNumber> = contact.phoneNumbers[index]
                            if let label = labeledValue.label {
                                let number = labeledValue.value.digits ?? labeledValue.value.stringValue
                                
                                cellView(title: formatLabel(label), content: number)
                            }
                        }
                    }
                    
                    Section("email") {
                        ForEach(0..<contact.emailAddresses.count, id: \.self) { index in
                            let labeledValue: CNLabeledValue<NSString> = contact.emailAddresses[index]
                            
                            if let label = labeledValue.label {
                                let value = labeledValue.value as String
                                cellView(title: formatLabel(label), content: value )
                            }
                        }
                    }
                    
                    Section {
                        ForEach(0..<contact.urlAddresses.count, id: \.self) { index in
                            let labeledValue: CNLabeledValue<NSString> = contact.urlAddresses[index]
                            
                            if let label = labeledValue.label {
                                let value = labeledValue.value as String
                                cellView(title: formatLabel(label), content: value )
                            }
                        }
                    }
                    
                    Section {
                        ForEach(0..<contact.postalAddresses.count, id: \.self) { index in
                            let labeledValue: CNLabeledValue<CNPostalAddress> = contact.postalAddresses[index]
                            
                            if let label = labeledValue.label {
                                let address = formatAddress(labeledValue.value)
                                cellView(title: formatLabel(label), content: address)
                            }
                        }
                    }
                    
                    Section {
                        if let birthday = contact.birthday, let formatted = formatBirthday(birthday) {
                            cellView(title: "birthday", content: formatted)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            Task {
                                await self.manager.deleteContact(contact)
                                if self.manager.error == nil {
                                    self.onContactDelete()
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

        }
        .contentMargins(.top, 8)
        .safeAreaInset(edge: .top, content: {
            VStack(spacing: 16) {
                IconView(contact: contact, size: 64)
                Text(contact.fullName)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(.linearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            .background(.white)
        })
    }
    
    private func cellView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
            Text(content)
                .foregroundStyle(.gray)
        }
        .font(.system(size: 16))
    }
    
    private func formatAddress(_ address: CNPostalAddress) -> String {
        var string = ""
        if !address.postalCode.isEmpty {
            string = "\(address.postalCode)"
        }
        if !address.city.isEmpty {
            string += "\n\(address.city)"
        }
        if !address.state.isEmpty {
            string += ", \(address.state)"
        }
        if !address.street.isEmpty {
            string += "\n\(address.street)"
        }
        return string
    }
    
    private func formatBirthday(_ birthday: DateComponents) -> String? {
        var birthday = birthday
        birthday.calendar = Calendar.current
        guard let date = birthday.date else { return nil }
        let template = birthday.year == nil ? "MMMMd" : "yMMMMd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        return dateFormatter.string(from: date)
    }

    
    private func formatLabel(_ label: String) -> String {
        switch label {
        case CNLabelHome:
            return "home"
        case CNLabelWork:
            return "work"
        case CNLabelOther:
            return "other"
        case CNLabelSchool:
            return "school"
        case CNLabelEmailiCloud:
            return "iCloud"
        case CNLabelURLAddressHomePage:
            return "homepage"
        case CNLabelPhoneNumberiPhone:
            return "iPhone"
        case CNLabelPhoneNumberAppleWatch:
            return "Apple Watch"
        case CNLabelPhoneNumberMobile:
            return "mobile"
        case CNLabelPhoneNumberMain:
            return "main"
        case CNLabelPhoneNumberHomeFax:
            return "home fax"
        case CNLabelPhoneNumberWorkFax:
            return "work fax"
        case CNLabelPhoneNumberOtherFax:
            return "other fax"
        case CNLabelPhoneNumberPager:
            return "pager"
        default:
            return label
        }
    }
}



#Preview {
    var contact: CNContact {
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
//        birthday.year = 1988
        contact.birthday = birthday
        return contact as CNContact
    }
    
    NavigationStack {
        ContactDetailView(contact: contact)
//        CustomEditView(isEditing: .constant(true))
            .environment(ContactManager())
    }
}
