//
//  OpenAIResponse.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/20.
//

import Foundation

// OpenAI 응답 모델
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
        let finish_reason: String?
        let index: Int
    }
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
    
    struct Usage: Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
} 