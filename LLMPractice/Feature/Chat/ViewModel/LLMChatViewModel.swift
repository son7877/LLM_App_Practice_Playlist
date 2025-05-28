//
//  LLMChatViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import Foundation
import SwiftUI
import SwiftData
import MusicKit

@MainActor
final class LLMChatViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var recommendedSongs: [Song] = []
    @Published var errorMessage: ErrorMessage? = nil
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 메시지 전송
    func sendMessage(_ text: String) async {
        recommendedSongs = []
        isLoading = true
        defer { isLoading = false }

        // OpenAI로부터 답변 받기
        let response: String
        do {
            response = try await AiManager.shared.fetchMusicRecommendation(userInput: text)
        } catch {
            response = "OpenAI 호출 실패: \(error.localizedDescription)"
        }

        // 이후 기존 로직대로 메시지 저장 및 추천 곡 검색
        let requestMessage = RequestMessage(content: text)
        modelContext.insert(requestMessage)
        let responseMessage = ResponseMessage(content: response, request: requestMessage)
        requestMessage.response = responseMessage
        modelContext.insert(responseMessage)
        do { 
            try modelContext.save() 
        } catch {
            // errorMessage가 nil일 때만 할당하여 Alert가 여러 번 뜨지 않도록 함
            if errorMessage == nil {
                errorMessage = ErrorMessage("데이터 저장 중 에러 발생: \(error.localizedDescription)")
            }
        }

        // 음악 관련 질문인 경우에만 추천 곡 검색
        if isMusicRelatedQuestion(response) {
            await searchRecommendedSongs(from: response)
        }
    }
    
    // MARK: - 음악 관련 질문 확인
    private func isMusicRelatedQuestion(_ response: String) -> Bool {
        // "추천 곡:" 문자열이 포함되어 있고, 그 뒤에 실제 곡명이 있는지 확인
        let components = response.components(separatedBy: "추천 곡:")
        guard components.count > 1 else { return false }
        let songPart = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return !songPart.isEmpty
    }
    
    // MARK: - 추천 곡 검색
    private func searchRecommendedSongs(from text: String) async {
        // "추천 곡:" 이후의 텍스트 추출
        guard let songPart = text.components(separatedBy: "추천 곡:").last else { return }
        let songItems = songPart
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for item in songItems {
            // "곡명 (아티스트)" 형태에서 곡명과 아티스트 분리
            let regex = try! NSRegularExpression(pattern: #"^(.+?)\s*\((.+?)\)$"#, options: [])
            if let match = regex.firstMatch(in: item, range: NSRange(item.startIndex..., in: item)),
               let titleRange = Range(match.range(at: 1), in: item),
               let artistRange = Range(match.range(at: 2), in: item) {
                let title = String(item[titleRange])
                let artist = String(item[artistRange])
                await fetchAndAppendSong(title: title, artist: artist)
            } else {
                // 괄호 없는 경우 곡명만 검색
                await fetchAndAppendSong(title: item, artist: nil)
            }
        }
    }
    
    private func fetchAndAppendSong(title: String, artist: String?) async {
        do {
            let query = artist != nil ? "\(title) \(artist!)" : title
            let songs = try await MusicKitManager.shared.fetchMusic(query)
            if let firstSong = songs.first {
                recommendedSongs.append(firstSong)
            }
        } catch {
            if errorMessage == nil {
                errorMessage = ErrorMessage("곡 검색 중 에러 발생: \(error.localizedDescription)")
            }
        }
    }
}
