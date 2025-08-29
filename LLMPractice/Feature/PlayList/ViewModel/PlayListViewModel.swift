//
//  PlayListViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class PlayListViewModel: ObservableObject {
    @Published var playLists: [PlayList] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPlayLists()
    }
    
    func loadPlayLists() {
        isLoading = true
        Task {
            do {
                // UserDataManager를 사용하여 현재 사용자의 플레이리스트만 불러오기
                playLists = try UserDataManager.shared.fetchUserPlayLists(context: modelContext)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                Logger.shared.log("플레이리스트 로드 실패: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    func createPlayList(title: String) {
        Task {
            do {
                // UserDataManager를 사용하여 사용자별 플레이리스트 생성
                _ = try UserDataManager.shared.createPlayList(title: title, context: modelContext)
                loadPlayLists() // 새로고침
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                Logger.shared.log("플레이리스트 생성 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePlayList(at indexSet: IndexSet) {
        for index in indexSet {
            let playlist = playLists[index]
            playlist.isDeleted = true // 실제 삭제 대신 삭제 표시
        }
        try? modelContext.save()
        loadPlayLists() // 새로고침
    }
}

