//
//  PlayListViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftUI

@MainActor
class PlayListViewModel: ObservableObject {
    @Published var playList: [PlayList] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    init() {
        loadPlayLists()
    }
    
    func loadPlayLists() {
        isLoading = true
        
        // TODO: API 호출로 실제 플레이리스트 데이터 가져오기
        // 임시 데이터로 테스트
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            playList = [
                // PlayList(title: "운동할 때 듣기 좋은 노래"),
                // PlayList(title: "잠잘 때 듣기 좋은 노래"),
                // PlayList(title: "드라이브할 때 듣기 좋은 노래")
            ]
            isLoading = false
        }
    }
    
    func createPlayList(title: String) {
        let newPlayList = PlayList(title: title)
        playList.append(newPlayList)
        
        // TODO: API 호출로 서버에 플레이리스트 생성 요청
    }
    
    func deletePlayList(at indexSet: IndexSet) {
        playList.remove(atOffsets: indexSet)
        
        // TODO: API 호출로 서버에서 플레이리스트 삭제 요청
    }
}

