//
//  KeywordManager.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/20.
//

import Foundation
import OSLog

final class KeywordManager {
    static let shared = KeywordManager()
    private init() {}
    
    // MARK: - 키워드 카테고리 정의
    struct KeywordCategory {
        let keywords: [String]
        let weight: Int
    }
    
    // MARK: - 키워드 카테고리 설정
    private let keywordCategories: [KeywordCategory] = [
        KeywordCategory(keywords: ["음악", "노래", "곡", "뮤직", "music", "song"], weight: 3),  // 기본 음악 관련
        KeywordCategory(keywords: ["추천", "recommend", "suggestion"], weight: 2),             // 추천 관련
        KeywordCategory(keywords: ["차트", "chart", "ranking", "순위"], weight: 2),           // 차트 관련
        KeywordCategory(keywords: ["K-pop", "케이팝", "아이돌", "idol"], weight: 2),          // K-pop 관련
        KeywordCategory(keywords: ["artist", "가수", "singer", "밴드", "band"], weight: 1),    // 아티스트 관련
        KeywordCategory(keywords: ["장르", "genre", "락", "rock", "팝", "pop"], weight: 1)     // 장르 관련
    ]
    
    // MARK: - 키워드 매칭 점수 계산
    func calculateKeywordScore(_ input: String) -> Int {
        let words = input.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.lowercased() }
            .filter { !$0.isEmpty }
        
        var totalScore = 0
        
        for category in keywordCategories {
            for keyword in category.keywords {
                if words.contains(where: { $0.contains(keyword.lowercased()) }) {
                    totalScore += category.weight
                }
            }
        }
        
        return totalScore
    }
    
    // MARK: - 음악 관련 질문 여부 확인
    func isMusicRelatedQuestion(_ input: String) -> Bool {
        let score = calculateKeywordScore(input)
        Logger.shared.debug("키워드 점수: \(score)")
        return score >= 2
    }
    
    // MARK: - 안내 메시지
    var guidanceMessage: String {
        return "음악 추천 관련 질문만 해주세요. (예: '요즘 인기있는 K-pop 노래 추천해줘', '락 음악 차트 알려줘')"
    }
} 