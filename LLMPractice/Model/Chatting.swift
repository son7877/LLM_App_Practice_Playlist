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
    var request: RequestMessage?

    init(content: String, request: RequestMessage? = nil, createdAt: Date = Date()) {
        self.content = content
        self.request = request
        self.createdAt = createdAt
    }
}

@Model
final class RequestMessage: Identifiable {
    private(set) var id: UUID = UUID()
    var content: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var response: ResponseMessage? // deleteRule: .cascade : 부모 데이터가 삭제되면 자식 데이터도 삭제됨

    init(content: String, createdAt: Date = Date()) {
        self.content = content
        self.createdAt = createdAt
    }
}