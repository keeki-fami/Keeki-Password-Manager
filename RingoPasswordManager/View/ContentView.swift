//
//  ContentView.swift
//  RingoPasswordManager
//  
//  Created by keeki-fami on 2026/10/22
//  
//

import SwiftUI
import SwiftData
import CryptoKit

struct ContentView: View {
    @State private var text: String = ""
    @State private var sealedBox: AES.GCM.SealedBox? = nil
    @State private var isModal: Bool = false
    @Query var password: [PasswordModel]
    
    var key: [SymmetricKey] = [
        .init(size: .bits256),
        .init(size: .bits256),
        .init(size: .bits256)
    ]
    var body: some View {
        VStack {
            ScrollView {
                // TODO: 復号化 → ForEachで列挙
            }
            Button("追加") {
                isModal.toggle()
            }
        }
        .sheet(isPresented: $isModal, content: {
            AddNewPassword()
        })
    }
}

struct AddNewPassword: View {
    @Environment(\.dismiss) var dismiss
    @State private var addData: PasswordDataModel = .init()
    var body: some View {
        TextField("Name", text: $addData.name)
        TextField("user", text: $addData.user)
        TextField("Password", text: $addData.password)
        TextField("comment", text: $addData.comment)
        
        Button("add password") {
            // TODO: パスワードを暗号化、追加処理
            dismiss()
        }
    }
}

#Preview {
    ContentView()
}
