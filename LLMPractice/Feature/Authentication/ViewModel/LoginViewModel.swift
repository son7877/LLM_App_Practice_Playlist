//
//  LoginViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI
import AuthenticationServices 
#if canImport(UIKit)
import UIKit
#endif
#if canImport(KakaoSDKUser)
import KakaoSDKUser
import KakaoSDKAuth
#endif
import SwiftData

@MainActor
class LoginViewModel: NSObject, ObservableObject { 
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isShowingPlayList: Bool = false
    @Published var isLoginSuccess: Bool = false

    func handleAlertDismiss() {
        if isLoginSuccess {
            isShowingPlayList = true
            isLoginSuccess = false  // 상태 초기화
        }
    }

    func handleKakaoLogin() {
        #if canImport(KakaoSDKUser)
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                guard let self else { return }
                if let error {
                    self.alertMessage = "카카오 로그인 실패: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                self.fetchKakaoProfile()
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                guard let self else { return }
                if let error {
                    self.alertMessage = "카카오 계정 로그인 실패: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                self.fetchKakaoProfile()
            }
        }
        #else
        alertMessage = "카카오 SDK가 추가되지 않았습니다. SPM로 Kakao SDK를 먼저 추가하세요."
        showAlert = true
        #endif
    }

    private func fetchKakaoProfile() {
        #if canImport(KakaoSDKUser)
        UserApi.shared.me { [weak self] user, error in
            guard let self else { return }
            if let error {
                self.alertMessage = "프로필 조회 실패: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            _ = user?.kakaoAccount?.profile?.nickname // 닉네임은 현재 미사용
            let email = user?.kakaoAccount?.email
            let kakaoUserId = (user?.id).map { String($0) } ?? ""

            if email == nil {
                self.requestAdditionalAgreement(scopes: ["account_email"]) { [weak self] in
                    self?.fetchKakaoProfile()
                }
                return
            }

            // 사용자 ID/이메일 설정 (카카오: id, account_email)
            if !kakaoUserId.isEmpty {
                UserDataManager.shared.setCurrentUserId(kakaoUserId)
            }
            UserDataManager.shared.setCurrentUserEmail(email!)
            
            self.isLoginSuccess = true
            self.alertMessage = "카카오 로그인에 성공했습니다!)"
            self.showAlert = true
        }
        #endif
    }

    private func requestAdditionalAgreement(scopes: [String], completion: @escaping () -> Void) {
        #if canImport(KakaoSDKUser)
        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { _, error in
            if let error {
                self.alertMessage = "추가 동의 요청 실패: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            completion()
        }
        #endif
    }

    func handleAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]  // 이름과 이메일 요청

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self  // 델리게이트 설정
        authorizationController.presentationContextProvider = self  // UI 표시를 위한 컨텍스트 제공자 설정
        authorizationController.performRequests()  // 로그인 요청 시작
    }
}

// MARK: - ASAuthorizationControllerDelegate (로그인 결과 처리)
extension LoginViewModel: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
            alertMessage = "Apple 로그인에 실패했습니다."
            showAlert = true
            return
        }

        // --- 로그인 성공 시 ---
        // 1. 고유 사용자 식별자 (서버에 저장할 값)
        let userIdentifier = appleIDCredential.user
        print("Apple User Identifier: \(userIdentifier)")
        UserDataManager.shared.setCurrentUserId(userIdentifier)

        // 2. Identity Token (서버로 보내 유효성 검증에 사용할 값)
        guard let identityToken = appleIDCredential.identityToken,
            let tokenString = String(data: identityToken, encoding: .utf8)
        else {
            alertMessage = "Identity Token을 가져오는 데 실패했습니다."
            showAlert = true
            return
        }
        print("Apple Identity Token: \(tokenString)")

        // 3. 사용자 정보 (최초 로그인 시에만 받을 수 있음)
        if let fullName = appleIDCredential.fullName {
            let name = (fullName.familyName ?? "") + (fullName.givenName ?? "")
            print("User Name: \(name)")
        }
        if let email = appleIDCredential.email {
            print("User Email: \(email)")
        } else if let persisted = UserDataManager.shared.getPersistedUserEmail() {
            // 재인증 등으로 이메일이 내려오지 않는 경우, 이전에 저장한 이메일을 복구해 사용
            UserDataManager.shared.setCurrentUserEmail(persisted)
        }

        // TODO: 여기서 userIdentifier와 tokenString을 백엔드 서버로 전송해야 합니다.
        // 서버 통신이 성공했다고 가정하고 다음 화면으로 넘어갑니다.
        
        // 사용자 이메일 설정 (애플: email). 최초 로그인 때만 제공되므로, 없으면 기존 저장값 사용
        if let email = appleIDCredential.email {
            UserDataManager.shared.setCurrentUserEmail(email)
        }

        isLoginSuccess = true
        alertMessage = "Apple 로그인에 성공했습니다!"
        showAlert = true
    }

    /// 로그인 실패 시
    func authorizationController(
        controller: ASAuthorizationController, didCompleteWithError error: Error
    ) {
        // 사용자가 로그인을 취소한 경우 (ASAuthorizationError.canceled)는 흔한 케이스이므로
        // 별도의 에러 메시지를 표시하지 않을 수 있습니다.
        print("Apple 로그인에 실패했습니다: \(error.localizedDescription)")
        alertMessage = "Apple 로그인 과정에 오류가 발생했습니다."
        showAlert = true
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding (로그인 UI 표시 위치 설정)
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    /// Apple 로그인 창을 어떤 화면 위에 띄울지 지정
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if canImport(UIKit)
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }

        if let anyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return anyWindow
        }
        #endif

        return ASPresentationAnchor()
    }
}
