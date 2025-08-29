//
//  ChatMessage.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import Foundation
import SwiftData

@Model
final class ResponseMessage: Identifiable {
    private(set) var id: UUID = UUID()
    var content: String
    var createdAt: Date
    var userEmail: String = "" // 사용자 이메일 (Apple: email, Kakao: account_email) — 기본값으로 경량 마이그레이션 허용
    var userId: String = "" // 안정적 식별자 (Apple userIdentifier / Kakao user.id)
    var request: RequestMessage?

    init(content: String, userEmail: String, request: RequestMessage? = nil, createdAt: Date = Date()) {
        self.content = content
        self.userEmail = userEmail
        self.request = request
        self.createdAt = createdAt
    }
}

@Model
final class RequestMessage: Identifiable {
    private(set) var id: UUID = UUID()
    var content: String
    var createdAt: Date
    var userEmail: String = "" // 사용자 이메일 (Apple: email, Kakao: account_email) — 기본값으로 경량 마이그레이션 허용
    var userId: String = "" // 안정적 식별자 (Apple userIdentifier / Kakao user.id)
    @Relationship(deleteRule: .cascade) var response: ResponseMessage? // deleteRule: .cascade : 부모 데이터가 삭제되면 자식 데이터도 삭제됨

    init(content: String, userEmail: String, createdAt: Date = Date()) {
        self.content = content
        self.userEmail = userEmail
        self.createdAt = createdAt
    }
}