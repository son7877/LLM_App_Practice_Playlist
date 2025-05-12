//
//  PlayList.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftData

@Model
final class PlayList {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var isPublic: Bool
    var isDeleted: Bool

    init(
        id: UUID, 
        name: String, 
        createdAt: Date, 
        updatedAt: Date, 
        isPublic: Bool, 
        isDeleted: Bool
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPublic = isPublic
        self.isDeleted = isDeleted
    }
}