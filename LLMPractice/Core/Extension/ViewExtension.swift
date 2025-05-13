//
//  ViewExtension.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}