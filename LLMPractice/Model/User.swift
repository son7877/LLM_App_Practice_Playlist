//
//  User.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var email: String
    var password: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        email: String,
        password: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

