//
//  LLMChatView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import SwiftUI
import SwiftData

struct LLMChatView: View {
    @Environment(\.modelContext) private var modelContext // 
    @Query(sort: \RequestMessage.createdAt) private var requestMessages: [RequestMessage] // 메시지 목록 쿼리
    @ObservedObject var viewModel: LLMChatViewModel
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // 채팅 메시지 목록 뷰
            ChatMessagesView(requestMessages: requestMessages, isLoading: viewModel.isLoading)
            
            // 추천된 곡 목록
            if !viewModel.recommendedSongs.isEmpty {
                VStack(alignment: .leading) {
                    Text("추천된 곡")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(viewModel.recommendedSongs) { song in
                                SongCard(song: song)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // 메시지 입력 영역
            HStack {
                TextField("챗봇에게 물어보세요", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading)
                
                Button(action: { 
                    Task {
                        await viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("음악 추천 채팅")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $viewModel.errorMessage) { errorMessage in
            Alert(title: Text("오류"), message: Text(errorMessage.message), dismissButton: .default(Text("확인")))
        }
    }
}

struct SongCard: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading) {
            if let albumArt = song.albumArt,
               let url = URL(string: albumArt) { // 앨범 아트 URL
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 120, height: 120)
                .cornerRadius(8)
            }
            
            Text(song.title)
                .font(.subheadline)
                .lineLimit(1)
            
            Text(song.artist)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}

struct ChatMessagesView: View {
    let requestMessages: [RequestMessage]
    let isLoading: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(requestMessages) { request in
                    if let response = request.response {
                        VStack(spacing: 8) {
                            // 사용자 메시지
                            HStack {
                                Spacer()
                                Text(request.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            // 봇 응답
                            HStack {
                                Text(response.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                Spacer()
                            }
                        }
                        
                    }
                }
                // 로딩 중일 때 표시
                if isLoading {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("응답 생성 중...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// struct SendMessageView: View {
    
// }