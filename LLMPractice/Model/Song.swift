//
//  Song.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftData

@Model
final class Song: Identifiable {
    let id: UUID
    var title: String
    var artist: String
    var albumArt: String?
    var duration: TimeInterval
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        albumArt: String? = nil,
        duration: TimeInterval,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumArt = albumArt
        self.duration = duration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 