//
//  PlayList.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftData

@Model
final class PlayList: Identifiable {
    private(set) var id: UUID = UUID()
    var title: String
    var songs: [Song]
    var createdAt: Date
    var updatedAt: Date
    var isPublic: Bool
    var isDeleted: Bool
    var userId: String = "" // 안정적 식별자 (Apple userIdentifier / Kakao user.id)
    var userEmail: String // 사용자 이메일 (Apple: email, Kakao: account_email)

    init(
        title: String,
        songs: [Song] = [], 
        createdAt: Date = Date(), 
        updatedAt: Date = Date(), 
        isPublic: Bool = true, 
        isDeleted: Bool = false,
        userId: String,
        userEmail: String
    ) {
        self.title = title
        self.songs = songs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPublic = isPublic
        self.isDeleted = isDeleted
        self.userId = userId
        self.userEmail = userEmail
    }
}
