//
//  LoginView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftData
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("LLMPlayList")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    VStack(spacing: 14) {
                        Button(action: { viewModel.handleKakaoLogin() }) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.black)
                                Text("카카오톡으로 계속하기")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                        }

                        Button(action: { viewModel.handleAppleLogin() }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .foregroundColor(.white)
                                Text("Apple로 계속하기")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .alert("알림", isPresented: $viewModel.showAlert) {
                Button("확인", role: .cancel) {
                    viewModel.handleAlertDismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .navigationDestination(isPresented: $viewModel.isShowingPlayList) {
                PlayListView(modelContext: modelContext)
            }
        }
    }
}
