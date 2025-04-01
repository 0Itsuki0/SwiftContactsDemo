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
        VStack {

            switch manager.authorizationStatus {
            case .notDetermined:
                Button(action: {
                    Task {
                        await manager.requestAccess()
                    }
                }, label: {
                    Text("request access")
                })
                Text("Not Determined")
                
            case .restricted:
                
                Text("restricted")
            case .denied:
                Text("denied")

            case .authorized:
                ContactView()

            case .limited:
                ContactView()
           
            @unknown default:
                Text("@unknown")
            }

        }
        .environment(manager)

    }
}

#Preview {
    ContentView()
}
