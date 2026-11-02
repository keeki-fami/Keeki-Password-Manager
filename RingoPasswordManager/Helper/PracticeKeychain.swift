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
import CryptoKit

// CryptoKit由来の鍵(X9.63を表現していないもの)に、データ表現を施す
protocol GenericPasswordConvertible: CustomStringConvertible {
    /// Creates a key from a generic key representation.
    init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes
    
    /// A generic representation of the key.
    var genericKeyRepresentation: SymmetricKey { get }
}

extension SymmetricKey: GenericPasswordConvertible {
    
    init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
        self.init(data: data)
    }
    
    var genericKeyRepresentation: SymmetricKey {
        self
    }
}

// @retroactive: 将来descriptionが実装される可能性を承知で書いていることを明示的にする。
extension SymmetricKey: @retroactive CustomStringConvertible {
    public var description: String {
        return String(self.bitCount)
    }
}

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
    
    static func saveKey(key: SymmetricKey, id: String) throws {
        let tag = id.data(using: .utf8)!
        
        // Treat the key data as a generic password.
        let keyData = key.withUnsafeBytes { Data($0) }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "keeki-password-manager",
            kSecAttrAccount: tag,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: keyData,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ] as [String: Any]
        
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
