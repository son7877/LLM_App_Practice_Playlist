//
//  LLMPracticeApp.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

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

        // 빌드 실행 시 데이터 초기화
        #if DEBUG
        Self.wipeSwiftDataStoreIfNeeded()
        #endif
        // 저장된 사용자 이메일 복원
        UserDataManager.shared.loadPersistedUserEmail()
        UserDataManager.shared.loadPersistedUserId()
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

private extension LLMPracticeApp {
    static func wipeSwiftDataStoreIfNeeded() {
        // SwiftData 기본 경로의 SQLite 파일들을 제거합니다: default.store, default.store-wal, default.store-shm
        do {
            let appSupportDir = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let baseName = "default.store"
            let targets = [
                appSupportDir.appendingPathComponent(baseName),
                appSupportDir.appendingPathComponent("\(baseName)-wal"),
                appSupportDir.appendingPathComponent("\(baseName)-shm")
            ]
            for url in targets {
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            Logger.shared.log("SwiftData store wiped for DEBUG run")
        } catch {
            Logger.shared.log("SwiftData store wipe failed: \(error.localizedDescription)")
        }
    }
}
