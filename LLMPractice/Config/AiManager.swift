// 
//  AiManager.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/20.
//

import Foundation
import SwiftData

final class AiManager {
    static let shared = AiManager()
    private(set) static var modelContext: ModelContext?
    
    static func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // OpenAI API 호출
    func fetchMusicRecommendation(userInput: String) async throws -> String {        
        // 1. 로컬 키워드 필터링
        if !KeywordManager.shared.isMusicRelatedQuestion(userInput) {
            return KeywordManager.shared.guidanceMessage
        }
        
        // 2. OpenAI 프롬프트
        let systemPrompt = """
        당신은 Apple Music 데이터베이스에 등록된 곡만 추천하는 음악 챗봇입니다.
        반드시 Apple Music(또는 MusicKit)에서 실제로 검색 가능한 **정확한 곡명과 아티스트명**을 사용해서 추천해주세요.
        곡명과 아티스트명은 공식 표기(영문, 대소문자, 특수문자 포함)를 그대로 사용해야 하며, 오타나 임의의 변형 없이 작성해야 합니다.

        반드시 아래 형식을 지켜서 답변하세요:
        추천 곡: 곡명1 (아티스트1), 곡명2 (아티스트2), 곡명3 (아티스트3)

        예시:
        추천 곡: Pink Venom (BLACKPINK), Seven (Jung Kook feat. Latto), Maniac (Stray Kids)

        각 곡에 대한 간단한 설명도 덧붙여주세요.

        음악과 전혀 무관한 질문(예: 수학 문제, 날씨 등)에만 '음악 추천만 도와드릴 수 있어요. 어떤 음악을 찾고 계신가요?'라고 답변해주세요.
        """
        
        let apiKey = Bundle.main.openAiAPIKey
        let urlString = "https://" + Bundle.main.openAiURL!
        Logger.shared.debug("API Key: \(apiKey.map { "****" + String($0.suffix(4)) } ?? "API Key 없음")")
        Logger.shared.debug("URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            Logger.shared.error("잘못된 URL 형식: \(urlString)")
            return "OpenAI URL 오류"
        }
        
        // 이전 대화 내용을 포함한 메시지 구성
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // 이전 대화 내용 추가 (최근 3개 대화만)
        if let previousMessages = try? await fetchPreviousMessages(limit: 3) {
            for message in previousMessages {
                messages.append(["role": "user", "content": message.content])
                if let response = message.response {
                    messages.append(["role": "assistant", "content": response.content])
                }
            }
        }
        
        // 현재 사용자 입력 추가
        messages.append(["role": "user", "content": userInput])
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 500
        ]
        
        // 3. OpenAI API 호출
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // API 키 설정 부분 수정
        if let apiKey = apiKey?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) { // 큰따옴표 제거
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            Logger.shared.debug("Authorization Header: Bearer \(apiKey)")
        } else {
            Logger.shared.error("API Key가 nil입니다")
            return "API Key 오류"
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 응답 데이터 디버깅
        if let jsonString = String(data: data, encoding: .utf8) {
            Logger.shared.debug("API Response: \(jsonString)")
        }
        
        // HTTP 상태 코드 확인
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.shared.error("Invalid response received from the server.")
            return "서버 응답 오류"
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            Logger.shared.error("HTTP Error: \(httpResponse.statusCode)")
            if let errorMessage = String(data: data, encoding: .utf8) {
                Logger.shared.error("Error Response Body: \(errorMessage)")
            }
            return "API 호출 실패: HTTP \(httpResponse.statusCode)"
        }
        
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return result.choices.first?.message.content ?? "추천 결과가 없습니다."
    }
    
    private func fetchPreviousMessages(limit: Int) async throws -> [RequestMessage] {
        guard let modelContext = AiManager.modelContext else { return [] }
        // 최근 3개 대화만 조회
        // 임시로 빈 배열 반환
        // 추후 데이터베이스 조회 로직 추가 -> 최근 메시지 limit 개수만큼 조회
        return []
    }
}
