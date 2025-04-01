//
//  ContactViewRepresentable.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/04/01.
//


import SwiftUI
import Contacts
import ContactsUI


// to override setEditing to set the binding
private class ContactViewController: CNContactViewController {
    var onEditChange: (Bool) -> Void = { _ in }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        onEditChange(editing)
    }
}

struct ContactViewRepresentable: UIViewRepresentable {
    @Environment(\.dismiss) private var dismiss

    private let controller: ContactViewController
    private let onNewContactComplete: ((String?) -> Void)?
    
    init(_ contact: CNContact, allowEditing: Bool = true, allowActions: Bool = true, shouldShowLinkedContacts: Bool = false, onEditChange: @escaping (Bool) -> Void) {
        let controller = ContactViewController(for: contact)
       
        controller.onEditChange = onEditChange
        controller.allowsEditing = allowEditing
        controller.allowsActions = allowActions
        controller.shouldShowLinkedContacts = shouldShowLinkedContacts
                
        self.controller = controller
        self.onNewContactComplete = nil
    }
    
    init(_ newContact: CNContact? = nil, contactStore: CNContactStore, onNewContactSave: @escaping (String?) -> Void) {
        
        let controller = ContactViewController(forNewContact: newContact)
        controller.onEditChange = { _ in }
        
//        contact store where the contact was fetched from or will be saved to
//        If not this property is not set, than adding the contact to the user’s contacts is disabled.
//        Does not affect the ability to edit
        controller.contactStore = contactStore

        self.controller = controller
        self.onNewContactComplete = onNewContactSave
    }
    
    func makeUIView(context: Context) -> UIView {
        // to show tool bar buttons
        let navigationController = UINavigationController(rootViewController: self.controller)
        self.controller.delegate = context.coordinator
        return navigationController.view
    }

    func updateUIView(_: UIView, context _: Context) {    }

    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactViewControllerDelegate {
 
        var parent: ContactViewRepresentable
        
        init(_ parent: ContactViewRepresentable) {
            self.parent = parent
        }
        
        // Called when the user selects a property.
        // Implement this method to determine the resulting behavior when a property is selected.
        // Return false if you do not want anything to be done or if you are handling the actions yourself.
        func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
            print("shouldPerformDefaultActionFor: \(property)")
            return true
        }
        
        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            print("didCompleteWith: \(String(describing: contact))")
            parent.onNewContactComplete?(contact?.identifier)

        }
    }
}

