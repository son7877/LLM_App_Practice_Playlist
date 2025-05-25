//
//  MusicKitManager.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import Foundation
import MusicKit
import OSLog

class MusicKitManager {
    static let shared = MusicKitManager()
    private init() {}

    // MARK: - 음악 검색
    func fetchMusic(_ txt: String) async throws -> [Song] {
        let status = await MusicAuthorization.request() // 음악 권한 요청

        switch status {
            case .authorized:
                do {
                    var request = MusicCatalogSearchRequest(term: txt, types: [MusicKit.Song.self])
                    request.limit = 10 // 검색 결과 10개
                    request.offset = 0 // 검색 결과 0번째 결과부터 가져옴

                    let result = try await request.response() // 검색 결과 가져옴
                    
                    // MusicKit의 Song을 앱의 Song 모델로 변환
                    let songs = result.songs.map { musicKitSong in
                        Song.from(musicKitSong: musicKitSong)
                    }
            
                    return songs
                } catch {
                    Logger.shared.error("음악 검색 중 오류 발생: \(error.localizedDescription)")
                    throw error
                }
            default:
                Logger.shared.error("음악 라이브러리 접근 권한이 없습니다")
                throw NSError(domain: "MusicKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "음악 라이브러리 접근 권한이 없습니다"])
        }
    }   
}
