//
//  RingoPasswordManagerApp.swift
//  RingoPasswordManager
//  
//  Created by keeki-fami on 2026/10/22
//  
//

import SwiftUI
import SwiftData

@main
struct RingoPasswordManagerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State var isAvailable = false
    
    var body: some Scene {
        WindowGroup {
            if isAvailable {
                ContentView()
                    .onChange(of: scenePhase) {old, new in
                        if old == .background {
                            isAvailable = false
                        }
                    }
            } else {
                AuthView(isAvailable: $isAvailable)
            }
//            TestView()
//            testView()
        }
        .modelContainer(for: PasswordModel.self)
    }
}

struct AuthView: View {
    @Binding var isAvailable: Bool
    var body: some View {
        Button("please auth") {
            Task {
                let auth = await SecureEnclaveHelper.auth()
                print(auth)
                if auth {
                    isAvailable = true
                }
            }
        }
    }
}
