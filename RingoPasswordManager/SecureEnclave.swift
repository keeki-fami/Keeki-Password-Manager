//
//  Untitled.swift
//  RingoPasswordManager
//
//  Created by keeki-fami on 2026/11/01
//
//

// MARK: SecureEnclave Test
import Security
import LocalAuthentication

struct SecureEnclaveHelper {
    static func genKey() throws {
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .privateKeyUsage,
            nil
        )! // Ignore errors.
    }
    
    static func auth() async -> Bool{
        let access = SecAccessControlCreateWithFlags(
            nil, // Use the default allocator.
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .userPresence,
            nil
        ) // Ignore any error.
        
        let context = LAContext()
        context.localizedReason = "Access your password on the keychain"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")


            // Fall back to a asking for username and password.
            // ...
            return false
        }
        
        
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
                print("ログイン成功")
                return true
            } catch let error {
                print(error.localizedDescription)
                // Fall back to a asking for username and password.
                // ...
            }
        return false
    }
    
}
