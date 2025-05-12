//
//  LLM.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import Foundation

extension Bundle {
    var openAiAPIKey: String? {
        return infoDictionary?["OPEN_AI_API_KEY"] as? String
    }
    
    var openAiURL: String? {
        return infoDictionary?["OPEN_AI_URL"] as? String
    }
}
