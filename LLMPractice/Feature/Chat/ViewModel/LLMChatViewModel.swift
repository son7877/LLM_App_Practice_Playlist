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
import OSLog

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
        Logger.shared.info("새로운 메시지 전송 시작: \(text)")
        
        // 사용자 메시지 저장
        let requestMessage = RequestMessage(content: text)
        modelContext.insert(requestMessage)
        Logger.shared.info("RequestMessage 생성됨: \(requestMessage.id.uuidString)")
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: LLM API 호출 구현
        // 임시 응답
        let response = "추천 곡: Dynamite - BTS, Butter - BTS, Permission to Dance - BTS"
        Logger.shared.info("LLM 응답 생성: \(response)")
        
        // 응답 메시지 저장 및 연결
        let responseMessage = ResponseMessage(content: response, request: requestMessage)
        requestMessage.response = responseMessage
        modelContext.insert(responseMessage)
        Logger.shared.info("ResponseMessage 생성됨: \(responseMessage.id.uuidString)")
        
        do {
            try modelContext.save()
            Logger.shared.info("SwiftData 저장 완료")
        } catch {
            Logger.shared.error("SwiftData 저장 실패: \(error.localizedDescription)")
        }
        
        // 추천된 곡들 검색
        // await : 메인 스레드(화면 UI) 멈추게 하지 않고 비동기적으로 실행
        await searchRecommendedSongs(from: response)

        // 저장된 메시지 확인
        Logger.shared.info("저장된 메시지 확인")
        do {
            // 혹시 반영이 늦을 수 있으니 잠깐 대기
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2초
            let requestMessages = try modelContext.fetch(FetchDescriptor<RequestMessage>())
            Logger.shared.info("requestMessages count: \(requestMessages.count)")
            for request in requestMessages {
                if let response = request.response {
                    Logger.shared.info("질문: \(request.content), 응답: \(response.content)")
                } else {
                    Logger.shared.info("질문: \(request.content), 응답: (없음)")
                }
            }
        } catch {
            Logger.shared.error("채팅 내역 조회 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 추천 곡 검색
    private func searchRecommendedSongs(from text: String) async {
        Logger.shared.info("곡 검색 시작: \(text)")
        
        let songTitles = text.components(separatedBy: ", ")
            .map { $0.replacingOccurrences(of: "추천 곡: ", with: "") }
        
        for title in songTitles {
            do {
                Logger.shared.info("곡 검색 중: \(title)")
                let songs = try await MusicKitManager.shared.fetchMusic(title)
                if let firstSong = songs.first {
                    recommendedSongs.append(firstSong)
                    Logger.shared.info("곡 검색 성공: \(firstSong.title)")
                }
            } catch {
                // errorMessage가 nil일 때만 할당하여 Alert가 여러 번 뜨지 않도록 함
                if errorMessage == nil {
                    errorMessage = ErrorMessage("곡 검색 중 에러 발생: \(error.localizedDescription)")
                }
            }
        }
    }
}
