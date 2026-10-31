//
//  SwiftDataModel.swift
//  RingoPasswordManager
//  
//  Created by keeki-fami on 2026/10/31
//  
//

import SwiftData
import SwiftUI

// MARK: パスワードの型
struct PasswordDataModel: Identifiable {
    var id: String
    var name: String
    var user: String
    var password: String
    var comment: String
    
    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.user = ""
        self.password = ""
        self.comment = ""
    }
    
    init(name: String, user: String, password: String, comment: String) {
        self.id = UUID().uuidString
        self.name = name
        self.user = user
        self.password = password
        self.comment = comment
    }
}

// MARK: 同じnameは同一のパスワードとする。
extension PasswordDataModel: Equatable {
    static func == (lhs: PasswordDataModel, rhs: PasswordDataModel) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: sealedBoxをDataにキャストしてストレージに保存するためのクラス
@Model
class PasswordModel {
    var passwordDataModel: Data
    init(passwordDataModel: Data) {
        self.passwordDataModel = passwordDataModel
    }
}
