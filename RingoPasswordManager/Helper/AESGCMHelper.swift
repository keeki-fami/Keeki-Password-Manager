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
    static func encryptText(text: PasswordDataModel, using key: SymmetricKey) -> Data {
        do {
            let data = try JSONEncoder().encode(text)
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let sealedBoxData = sealedBox.combined else {
                fatalError("Data型に変更ができませんでした。")
            }
            return sealedBoxData
        } catch {
            fatalError("エラー:\(error)")
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
