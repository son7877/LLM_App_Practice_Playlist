// 
//  AiManager.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/20.
//

import Foundation

final class AiManager {
    static let shared = AiManager()
    private init() {}

    // OpenAI API 호출
    func fetchMusicRecommendation(userInput: String) async throws -> String {
        // 2초 딜레이 추가
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2초

        // 1. 로컬 키워드 필터링
        if !KeywordManager.shared.isMusicRelatedQuestion(userInput) {
            return KeywordManager.shared.guidanceMessage
        }

        // 2. OpenAI 프롬프트
        let systemPrompt = """
        당신은 친근하고 음악에 열정적인 음악 추천 챗봇입니다. 
        사용자와 대화할 때는 친구처럼 자연스럽게 대화하되, 음악에 대한 전문적인 지식도 함께 전달해주세요.
        
        음악과 관련 없는 질문에는 '음악 추천만 도와드릴 수 있어요. 어떤 음악을 찾고 계신가요?'라고 답변해주세요.
        
        음악 추천을 할 때는 다음과 같은 형식으로 답변해주세요:
        1. 먼저 사용자의 취향이나 상황에 맞는 공감대를 형성해주세요.
        2. 이전 대화에서 언급된 사용자의 취향이나 선호도를 참고하여 추천해주세요.
        3. 그 다음 '추천 곡: [곡명1], [곡명2], [곡명3]' 형식으로 곡을 추천해주세요.
        4. 마지막으로 추천한 곡들에 대한 간단한 설명이나 특징을 덧붙여주세요.
        
        예시 답변:
        "비 오는 날이면 이런 감성적인 곡들이 좋죠! 
        추천 곡: Rain, November Rain, Purple Rain
        이 곡들은 비라는 소재를 다루면서도 각각 다른 감정을 담고 있어요. 특히 Purple Rain은 프린스의 명곡으로, 비를 통해 정화와 치유를 표현한 곡이에요."
        """
        
        let apiKey = Bundle.main.openAiAPIKey
        let urlString = "https://" + Bundle.main.openAiURL!
        Logger.shared.debug("API Key: \(apiKey ?? "API Key 없음")")
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
            "model": "gpt-4o-mini",
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
        
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return result.choices.first?.message.content ?? "추천 결과가 없습니다."
    }
}
