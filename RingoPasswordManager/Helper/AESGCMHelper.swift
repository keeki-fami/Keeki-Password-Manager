//
//  AESGCMHelper.swift
//  RingoPasswordManager
//  
//  Created by keeki-fami on 2026/10/31
//  
//
import SwiftUI
import CryptoKit

struct AESGCMHelper {
    
    static func encryptText(text: String, using key: SymmetricKey) -> AES.GCM.SealedBox? {
        let data = text.data(using: .utf8)!
        do {
            let sealedBoxData = try AES.GCM.seal(data, using: key)
            return sealedBoxData
        } catch {
            print("error: \(error)")
            return nil
        }
    }
    
    static func decrypt(sealedBox: AES.GCM.SealedBox, using key: SymmetricKey) -> String {
        do {
            let data = try AES.GCM.open(sealedBox, using: key)
            let text = String(data: data, encoding: .utf8) ?? ""
            return text
        } catch {
            print("error: \(error)")
        }
        return ""
    }
}
