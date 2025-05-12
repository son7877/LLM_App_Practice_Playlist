//
//  LoginView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 로고 또는 앱 이름
                Text("LLMPractice")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
                
                // 이메일 입력 필드
                TextField("이메일", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                    .focused($isFocused)
                
                // 비밀번호 입력 필드
                SecureField("비밀번호", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                    .padding(.horizontal)
                    .focused($isFocused)
                
                // 로그인 버튼
                Button(action: { viewModel.handleLogin() }) {
                    Text("로그인")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 회원가입 버튼
                Button(action: { viewModel.isShowingSignUp = true }) {
                    Text("회원가입")
                        .foregroundColor(.blue)
                }
                
                // 소셜 로그인 구분선
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("또는")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.vertical)
                
                // 소셜 로그인 버튼들
                HStack(spacing: 20) {
                    // 카카오 로그인
                    Button(action: { viewModel.handleKakaoLogin() }) {
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(Color.yellow)
                            .clipShape(Circle())
                    }
                    
                    // 애플 로그인
                    Button(action: { viewModel.handleAppleLogin() }) {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    
                    // 구글 로그인
                    Button(action: { viewModel.handleGoogleLogin() }) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                isFocused = false
            }
            .alert("알림", isPresented: $viewModel.showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .sheet(isPresented: $viewModel.isShowingSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
}
