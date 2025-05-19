//
//  LLMPracticeApp.swift
//  LLMPractice
//
//  Created by 안홍범 on 4/19/25.
//

import SwiftUI
import SwiftData

@main
struct LLMPracticeApp: App {
    var sharedModelContainer: ModelContainer = { 
        let schema: Schema = Schema([ // 데이터베이스에 저장될 모델들 정의
            User.self,
            PlayList.self,
            Song.self,
            RequestMessage.self,
            ResponseMessage.self
        ])

        // 데이터를 기기에 저장할지 아닐지 결정
        // isStoredInMemoryOnly: false -> 앱이 종료되어도 기기에 저장, true -> 앱이 종료되면 데이터 삭제
        let modelConfiguration: ModelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) 

        do { // 에러 처리
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(sharedModelContainer)
    }
}
