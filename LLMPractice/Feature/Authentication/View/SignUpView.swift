//
//  SignUpView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @StateObject private var viewModel: SignUpViewModel = SignUpViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 회원가입 제목
                Text("회원가입")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)
                
                // 이메일 입력 필드
                TextField("이메일", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                // 비밀번호 입력 필드
                SecureField("비밀번호", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                    .padding(.horizontal)
                
                // 비밀번호 확인 입력 필드
                SecureField("비밀번호 확인", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                    .padding(.horizontal)
                
                // 회원가입 버튼
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    Text("회원가입")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("취소") {
                dismiss()
            })
            .alert("알림", isPresented: $viewModel.showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    SignUpView()
} 