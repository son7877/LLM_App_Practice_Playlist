//
//  UserDataManager.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/08/29.
//

import Foundation
import SwiftData

class UserDataManager {
    static let shared = UserDataManager()
    
    private init() {}
    
    private let persistedEmailKey = "UserDataManager.currentUserEmail"
    private let persistedUserIdKey = "UserDataManager.currentUserId"
    
    // 현재 로그인된 사용자의 이메일을 저장
    private var currentUserEmail: String?
    private var currentUserId: String?
    
    // 사용자 이메일 설정
    func setCurrentUserEmail(_ email: String) {
        currentUserEmail = email
        // 영속 저장
        UserDefaults.standard.set(email, forKey: persistedEmailKey)
        Logger.shared.log("현재 사용자 이메일 설정: \(email)")
    }
    
    // 사용자 ID 설정 (안정적 식별자)
    func setCurrentUserId(_ id: String) {
        currentUserId = id
        UserDefaults.standard.set(id, forKey: persistedUserIdKey)
        Logger.shared.log("현재 사용자 ID 설정: \(id)")
    }
    
    // 현재 사용자 이메일 가져오기
    func getCurrentUserEmail() -> String? {
        return currentUserEmail
    }
    
    func getCurrentUserId() -> String? {
        return currentUserId
    }
    
    // 저장된 사용자 이메일 복원 (앱 시작 시 호출)
    func loadPersistedUserEmail() {
        if let email = UserDefaults.standard.string(forKey: persistedEmailKey) {
            currentUserEmail = email
            Logger.shared.log("저장된 사용자 이메일 복원: \(email)")
        }
    }
    
    func loadPersistedUserId() {
        if let id = UserDefaults.standard.string(forKey: persistedUserIdKey) {
            currentUserId = id
            Logger.shared.log("저장된 사용자 ID 복원: \(id)")
        }
    }
    
    // 저장된 사용자 이메일 직접 조회
    func getPersistedUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: persistedEmailKey)
    }
    
    func getPersistedUserId() -> String? {
        return UserDefaults.standard.string(forKey: persistedUserIdKey)
    }
    
    // 사용자별 플레이리스트 조회
    func fetchUserPlayLists(context: ModelContext) throws -> [PlayList] {
        guard let userId = currentUserId else {
            throw UserDataError.noUserEmail
        }
        let descriptor = FetchDescriptor<PlayList>(
            predicate: #Predicate<PlayList> { playList in
                playList.userId == userId && playList.isDeleted == false
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    // 사용자별 채팅 메시지 조회
    func fetchUserChatMessages(context: ModelContext) throws -> [RequestMessage] {
        guard let userId = currentUserId else {
            throw UserDataError.noUserEmail
        }
        let descriptor = FetchDescriptor<RequestMessage>(
            predicate: #Predicate<RequestMessage> { request in
                request.userId == userId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try context.fetch(descriptor)
    }
    
    // 플레이리스트 생성
    func createPlayList(title: String, context: ModelContext) throws -> PlayList {
        guard let userId = currentUserId else {
            throw UserDataError.noUserEmail
        }
        let playList = PlayList(title: title, userId: userId, userEmail: currentUserEmail ?? "")
        context.insert(playList)
        try context.save()
        
        Logger.shared.log("플레이리스트 생성: \(title) for userId: \(userId), email: \(currentUserEmail ?? "")")
        return playList
    }
    
    // 채팅 메시지 생성
    func createChatMessage(content: String, context: ModelContext) throws -> RequestMessage {
        guard let userId = currentUserId else {
            throw UserDataError.noUserEmail
        }
        let requestMessage = RequestMessage(content: content, userEmail: currentUserEmail ?? "")
        requestMessage.userId = userId
        context.insert(requestMessage)
        try context.save()
        
        Logger.shared.log("채팅 메시지 생성 for userId: \(userId), email: \(currentUserEmail ?? "")")
        return requestMessage
    }
    
    // 응답 메시지 생성
    func createResponseMessage(content: String, request: RequestMessage, context: ModelContext) throws -> ResponseMessage {
        guard let userId = currentUserId else {
            throw UserDataError.noUserEmail
        }
        let responseMessage = ResponseMessage(content: content, userEmail: currentUserEmail ?? "", request: request)
        responseMessage.userId = userId
        request.response = responseMessage
        context.insert(responseMessage)
        try context.save()
        
        Logger.shared.log("응답 메시지 생성 for userId: \(userId), email: \(currentUserEmail ?? "")")
        return responseMessage
    }
    
    // 사용자 데이터 삭제 (로그아웃 시)
    func clearCurrentUser() {
        currentUserEmail = nil
        currentUserId = nil
        UserDefaults.standard.removeObject(forKey: persistedEmailKey)
        UserDefaults.standard.removeObject(forKey: persistedUserIdKey)
        Logger.shared.log("현재 사용자 정보 초기화")
    }
}

// 사용자 데이터 관련 에러
enum UserDataError: Error, LocalizedError {
    case noUserEmail
    
    var errorDescription: String? {
        switch self {
        case .noUserEmail:
            return "사용자 이메일이 설정되지 않았습니다."
        }
    }
}
