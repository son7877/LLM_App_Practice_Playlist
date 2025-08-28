//
//  LoginViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingPlayList: Bool = false
    @Published var isLoginSuccess: Bool = false
    
    func handleAlertDismiss() {
        if isLoginSuccess {
            isShowingPlayList = true
            isLoginSuccess = false
        }
    }
    
    func handleKakaoLogin() {
        // TODO: 카카오 로그인 구현
        alertMessage = "카카오 로그인 준비 중입니다."
        showAlert = true
    }
    
    func handleAppleLogin() {
        // TODO: 애플 로그인 구현
        alertMessage = "애플 로그인 준비 중입니다."
        showAlert = true
    }
    
    // 이메일/비밀번호 및 구글 로그인 제거
} 