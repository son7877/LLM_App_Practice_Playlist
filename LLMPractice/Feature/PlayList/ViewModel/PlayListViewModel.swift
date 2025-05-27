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
            // SwiftData에서 PlayList 전체 불러오기
            let descriptor = FetchDescriptor<PlayList>(sortBy: [SortDescriptor(\.createdAt)])
            if let result = try? modelContext.fetch(descriptor) {
                playLists = result
            }
            isLoading = false
        }
    }
    
    func createPlayList(title: String) {
        let newPlayList = PlayList(title: title)
        modelContext.insert(newPlayList)
        try? modelContext.save()
        loadPlayLists() // 새로고침
    }
    
    func deletePlayList(at indexSet: IndexSet) {
        for index in indexSet {
            let playlist = playLists[index]
            modelContext.delete(playlist)
        }
        try? modelContext.save()
        loadPlayLists() // 새로고침
    }
}

