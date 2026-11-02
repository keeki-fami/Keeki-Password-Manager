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
import AppKit

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
        if !SecureEnclave.isAvailable {
            Text("このデバイスではSecure Enclaveへのアクセスがサポートされていません。")
        } else {
            LazyVStack {
                ScrollView {
                    ForEach(password) { pass in
                        Button(action: {
                            do {
                                let key = try KeyChainHelper.fetchKey(id: pass.id)
                                let sealedBox = try AES.GCM.SealedBox(combined: pass.passwordDataModel)
                                let password = AESGCMHelper.decrypt(sealedBox: sealedBox, using: key)
                                let pasteboard = NSPasteboard.general
                                print(password)
                                pasteboard.clearContents()
                                pasteboard.setString(password.password , forType: .string)
                            } catch {
                                print("error: \(error)")
                            }
                        }, label: {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 400, height: 100)
                                .shadow(
                                    color: .black.opacity(0.5),
                                    radius: 10,
                                    x: 0,
                                    y: 4
                                )
                                .overlay() {
                                    Text(String(describing: pass))
                                }
                        })
                    }
                    // TODO: 復号化 → ForEachで列挙
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(.red)
                Button("追加") {
                    isModal.toggle()
                }
                .padding()
            }
            .sheet(isPresented: $isModal, content: {
                AddNewPassword()
            })
        }
    }
}

struct AddNewPassword: View {
    @Environment(\.dismiss) var dismiss
    @State private var addData: PasswordDataModel = .init()
    @Environment(\.modelContext) var context
    @State private var isAlert = false
    var body: some View {
        TextField("Name", text: $addData.name)
        TextField("user", text: $addData.user)
        TextField("Password", text: $addData.password)
        TextField("comment", text: $addData.comment)
        
        Button("add password") {
            // TODO: パスワードを暗号化、追加処理
            var key = SymmetricKey(size: .bits256)
            let encryptedData = AESGCMHelper.encryptText(text: addData, using: key)
            do {
                try KeyChainHelper.saveKey(key: key, id: addData.id)
                context.insert(
                    PasswordModel(
                        id: addData.id,
                        passwordDataModel: encryptedData
                    )
                )
                dismiss()
            } catch {
                print("error: \(error.localizedDescription)")
                print("error: \(error)")
                isAlert.toggle()
            }
        }
        .alert("Error", isPresented: $isAlert, actions: {
            Button(role: .confirm, action: {
                isAlert.toggle()
                dismiss()
            }) {
                Text("OK")
            }
        }) {
            Text("エラーが発生しました。")
        }
    }
}

#Preview {
    ContentView()
}
