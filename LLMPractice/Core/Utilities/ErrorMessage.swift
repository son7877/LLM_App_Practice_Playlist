//
//  ErrorMessage.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/18.
//

import Foundation

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String

    init(_ message: String) {
        self.message = message
    }
}