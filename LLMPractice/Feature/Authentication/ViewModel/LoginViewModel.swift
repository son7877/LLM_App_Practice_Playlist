//
//  LoginViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingSignUp: Bool = false
    @Published var isShowingPlayList: Bool = false
    
    func handleLogin() {
        // 입력값 검증
        guard !email.isEmpty else {
            alertMessage = "이메일을 입력해주세요."
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertMessage = "비밀번호를 입력해주세요."
            showAlert = true
            return
        }
        
        // TODO: 실제 로그인 로직 구현
        // 여기에 API 호출 등의 로그인 처리 로직을 추가
        
        // 임시 로그인 성공 처리 후 플레이리스트 화면으로 이동
        isShowingPlayList = true
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
    
    func handleGoogleLogin() {
        // TODO: 구글 로그인 구현
        alertMessage = "구글 로그인 준비 중입니다."
        showAlert = true
    }
} 