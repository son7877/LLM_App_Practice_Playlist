//
//  User.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import Foundation
import SwiftData

@Model
final class AppleUser {
    private(set) var id: UUID = UUID()
    var email: String
    var password: String
    var createdAt: Date
    var updatedAt: Date

    init(
        email: String,
        password: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.email = email
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class KakaoUser {
    private(set) var id: UUID = UUID()
    var profile_nickname: String
    var account_email: String

    init(
        profile_nickname: String,
        account_email: String
    ) {
        self.profile_nickname = profile_nickname
        self.account_email = account_email
    }
}

