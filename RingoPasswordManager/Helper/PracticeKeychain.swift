//
//  PracticeKeychain.swift
//  RingoPasswordManager
//  
//  Created by keeki-fami on 2026/11/01
//  
//
import Foundation
import Security
import SwiftUI

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

struct KeyChainHelper {
    
    static func add(username: String, password: String) throws {
        let account = username
        let password = password.data(using: .utf8)!
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: password
        ]
        
        // Add the item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
    }
    
    static func search(username: String) throws -> Credentials{
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        // initiate the search
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8),
              let account = existingItem[kSecAttrAccount as String] as? String
          else {
              throw KeychainError.unexpectedPasswordData
          }
        return Credentials(username: account, password: password)
    }
}

struct TestView: View {
    @State private var credentials = Credentials(username: "", password: "")
    var body: some View {
        TextField("username", text: $credentials.username)
        TextField("password", text: $credentials.password)
        
        Button("add") {
            do {
                try KeyChainHelper.add(
                    username: credentials.username,
                    password: credentials.password
                )
                credentials.username = ""
                credentials.password = ""
            } catch {
                print("error: \(error)")
            }
        }
        Button("search") {
            do {
                credentials = try KeyChainHelper.search(username: credentials.username)
            } catch {
                print("error: \(error)")
            }
        }
    }
}
