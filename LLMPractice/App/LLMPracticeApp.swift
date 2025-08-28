//
//  LLMPracticeApp.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import KakaoSDKCommon
import SwiftData
import SwiftUI

@main
struct LLMPracticeApp: App {
    let modelContainer: ModelContainer

    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppKey ?? "")
        Logger.shared.log(
            "KakaoSDK initialized with appKey: \(Bundle.main.kakaoAppKey ?? "키를 찾을 수 없습니다")")
        let schema: Schema = Schema([
            User.self,
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
