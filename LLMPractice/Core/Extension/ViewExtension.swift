//
//  ViewExtension.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

extension View {
    // 키보드 내리기
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
