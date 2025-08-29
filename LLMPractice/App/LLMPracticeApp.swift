//
//  LLMPracticeApp.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

// Kakao SDK는 SPM로 추가 후 빌드 타깃에서만 임포트됩니다.
#if canImport(KakaoSDKCommon)
import KakaoSDKCommon
#endif
import SwiftData
import SwiftUI

@main
struct LLMPracticeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let modelContainer: ModelContainer

    init() {
        #if canImport(KakaoSDKCommon)
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppKey ?? "")
        Logger.shared.log("KakaoSDK initialized")
        #endif
        let schema: Schema = Schema([
            AppleUser.self,
            KakaoUser.self,
            PlayList.self,
            Song.self,
            RequestMessage.self,
            ResponseMessage.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("모델 컨테이너 생성 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .environment(\.modelContext, modelContainer.mainContext)
    }
}
