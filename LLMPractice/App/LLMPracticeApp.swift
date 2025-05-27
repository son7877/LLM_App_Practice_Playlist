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
    let modelContainer: ModelContainer

    init() {
        let schema: Schema = Schema([
            User.self,
            PlayList.self,
            Song.self,
            RequestMessage.self,
            ResponseMessage.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .environment(\.modelContext, modelContainer.mainContext)
    }
}
