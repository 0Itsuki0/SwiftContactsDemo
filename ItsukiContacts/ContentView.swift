//
//  ContentView.swift
//  ItsukiContacts
//
//  Created by Itsuki on 2025/03/29.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = ContactManager()

    var body: some View {
        Group {

            switch manager.authorizationStatus {
            case .notDetermined:
                ContentUnavailableView(label: {
                    Label("Unknown Access", systemImage: "questionmark.app")
                }, description: {
                    Text("The app requires access to the contacts.")
                        .multilineTextAlignment(.center)
                }, actions: {
                    Button(action: {
                        Task {
                            await manager.requestAccess()
                        }
                    }, label: {
                        Text("request access")
                    })
                })

            case .restricted:
                ContentUnavailableView(label: {
                    Label("Restricted Access", systemImage: "lock.square")
                }, description: {
                    Text("This device doesn't allow access to Contacts. Please update the permission in Settings.")
                        .multilineTextAlignment(.center)
                })
            case .denied:
                ContentUnavailableView(label: {
                    Label("Access Denied", systemImage: "xmark.square")
                }, description: {
                    Text("The app doesn't have permission to access contacts. Please grant the app access in Settings.")
                        .multilineTextAlignment(.center)
                })

            case .authorized, .limited:
                ContactView()
           
            @unknown default:
                ContentUnavailableView(label: {
                    Label("Unknown", systemImage: "ellipsis.rectangle")
                }, description: {
                    Text("Unknown authorization status.")
                        .multilineTextAlignment(.center)
                })
            }
        }
        .environment(manager)

    }
}

#Preview {
    ContentView()
}
