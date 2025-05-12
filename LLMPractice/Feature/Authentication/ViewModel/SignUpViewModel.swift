//
//  SignUpViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 이메일 유효성 검사
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred: NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // 비밀번호 유효성 검사
    private func isValidPassword(_ password: String) -> Bool {
        // 최소 8자, 최소 하나의 문자, 하나의 숫자, 하나의 특수문자
        let passwordRegEx: String = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        let passwordPred: NSPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    // 입력값 검증
    func validateInputs() -> Bool {
        // 이메일 검증
        guard !email.isEmpty else {
            alertMessage = "이메일을 입력해주세요."
            showAlert = true
            return false
        }
        
        guard isValidEmail(email) else {
            alertMessage = "올바른 이메일 형식이 아닙니다."
            showAlert = true
            return false
        }
        
        // 비밀번호 검증
        guard !password.isEmpty else {
            alertMessage = "비밀번호를 입력해주세요."
            showAlert = true
            return false
        }
        
        guard isValidPassword(password) else {
            alertMessage = "비밀번호는 8자 이상이며, 문자, 숫자, 특수문자를 포함해야 합니다."
            showAlert = true
            return false
        }
        
        // 비밀번호 확인 검증
        guard password == confirmPassword else {
            alertMessage = "비밀번호가 일치하지 않습니다."
            showAlert = true
            return false
        }
        
        return true
    }
    
    // 회원가입 처리
    func signUp() async {
        guard validateInputs() else { return }
        
        do {
            // TODO: 실제 API 호출 구현
            // let response = try await AuthService.shared.signUp(email: email, password: password)
            
            // 임시 성공 처리
            DispatchQueue.main.async {
                self.alertMessage = "회원가입이 완료되었습니다!"
                self.showAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "회원가입 중 오류가 발생했습니다."
                self.showAlert = true
            }
        }
    }
} 