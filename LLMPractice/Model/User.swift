//
//  User.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import Foundation
import SwiftData

// 공통 사용자 프로토콜
protocol UserProtocol {
    var userEmail: String { get }
}

@Model
final class AppleUser: UserProtocol {
    private(set) var id: UUID = UUID()
    var email: String
    var password: String

    var userEmail: String {
        return email
    }

    init(
        email: String,
        password: String,
    ) {
        self.email = email
        self.password = password
    }
}

@Model
final class KakaoUser: UserProtocol {
    private(set) var id: UUID = UUID()
    var profile_nickname: String
    var account_email: String

    var userEmail: String {
        return account_email
    }

    init(
        profile_nickname: String,
        account_email: String
    ) {
        self.profile_nickname = profile_nickname
        self.account_email = account_email
    }
}

