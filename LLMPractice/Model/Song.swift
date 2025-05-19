//
//  Song.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftData
import MusicKit

@Model
final class Song: Identifiable {
    private(set) var id: UUID = UUID()
    var title: String
    var artist: String
    var albumArt: String?
    var duration: TimeInterval
    var createdAt: Date
    var updatedAt: Date
    var musicKitID: String?  // MusicKit의 노래 ID를 저장
    
    init(
        title: String,
        artist: String,
        albumArt: String? = nil,
        duration: TimeInterval,
        musicKitID: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.title = title
        self.artist = artist
        self.albumArt = albumArt
        self.duration = duration
        self.musicKitID = musicKitID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MusicKit의 Song을 해당 앱의 Song 모델로 변환하는 확장
extension Song {
    static func from(musicKitSong: MusicKit.Song) -> Song {
        return Song(
            title: musicKitSong.title,
            artist: musicKitSong.artistName,
            albumArt: musicKitSong.artwork?.url(width: 300, height: 300)?.absoluteString,
            duration: musicKitSong.duration ?? 0,
            musicKitID: musicKitSong.id.rawValue 
        )
    }
} 
