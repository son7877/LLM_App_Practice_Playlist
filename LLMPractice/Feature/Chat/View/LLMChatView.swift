//
//  LLMChatView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import SwiftUI
import SwiftData

struct LLMChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RequestMessage.createdAt) private var requestMessages: [RequestMessage]
    @ObservedObject var viewModel: LLMChatViewModel
    @State private var messageText = ""
    @State private var showingCreatePlayList = false 
    @State private var showingPlayListAlert = false
    @State private var selectedSong: Song?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // 채팅 메시지 영역
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(requestMessages) { request in
                            // 사용자 메시지
                            HStack {
                                Spacer()
                                ChatBubble(text: request.content, isUser: true)
                            }
                            // AI 메시지
                            if viewModel.isLoading && request == requestMessages.last {
                                // 답변이 아직 없는 마지막 메시지에만 로딩 말풍선 표시
                                HStack {
                                    ChatBubbleLoading()
                                    Spacer()
                                }
                            } else if let response = request.response {
                                HStack {
                                    ChatBubble(text: response.content, isUser: false)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 추천 트랙 리스트
                if !viewModel.recommendedSongs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("추천 곡")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                        ForEach(viewModel.recommendedSongs) { song in
                            TrackRow(song: song)
                        }
                    }
                    .background(Color(.systemGray6).opacity(0.1))
                }

                // 입력창
                HStack {
                    TextField("챗봇에게 질문하세요", text: $messageText)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                        .foregroundColor(.black)
                    Button(action: { 
                        endTextEditing()
                        Task {
                            await viewModel.sendMessage(messageText)
                            messageText = ""
                        }
                     }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.2))
            }
        }
        .navigationTitle("음악 추천 채팅")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $viewModel.errorMessage) { errorMessage in
            Alert(title: Text("오류"), message: Text(errorMessage.message), dismissButton: .default(Text("확인")))
        }
    }
}

// 말풍선 뷰
struct ChatBubble: View {
    let text: String
    let isUser: Bool
    var body: some View {
        Text(text)
            .padding()
            .background(isUser ? Color.blue : Color(.systemGray4))
            .foregroundColor(isUser ? .white : .black)
            .cornerRadius(16)
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
    }
}

// 트랙 리스트 뷰
struct TrackRow: View {
    let song: Song
    @Environment(\.modelContext) private var modelContext
    @Query private var playLists: [PlayList]
    @State private var showingCreatePlayList = false
    @State private var showingPlayListAlert = false
    @State private var newPlayListTitle = ""
    @State private var showingPlayListSelection = false
    
    var body: some View {
        HStack {
            if let albumArt = song.albumArt, let url = URL(string: albumArt) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 48, height: 48)
                .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(song.title).foregroundColor(.black)
                Text(song.artist).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                if playLists.isEmpty {
                    showingPlayListAlert = true
                } else {
                    showingPlayListSelection = true
                }
            }) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .alert("플레이리스트 없음", isPresented: $showingPlayListAlert) {
            Button("플레이리스트 만들기") {
                showingCreatePlayList = true
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("곡을 추가할 플레이리스트가 없습니다. 새 플레이리스트를 만들어주세요.")
        }
        .sheet(isPresented: $showingCreatePlayList) {
            NavigationStack {
                Form {
                    TextField("플레이리스트 제목", text: $newPlayListTitle)
                }
                .navigationTitle("새 플레이리스트 생성")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("취소") {
                        showingCreatePlayList = false
                    },
                    trailing: Button("만들기") {
                        if !newPlayListTitle.isEmpty {
                            let newPlayList = PlayList(title: newPlayListTitle)
                            newPlayList.songs.append(song)
                            modelContext.insert(newPlayList)
                            try? modelContext.save()
                            newPlayListTitle = ""
                            showingCreatePlayList = false
                        }
                    }
                )
            }
            .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $showingPlayListSelection) {
            NavigationStack {
                List(playLists) { playlist in
                    Button(action: {
                        playlist.songs.append(song)
                        try? modelContext.save()
                        showingPlayListSelection = false
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.title)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading) {
                                Text(playlist.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(playlist.songs.count)곡")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("플레이리스트 선택")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("취소") {
                        showingPlayListSelection = false
                    }
                )
            }
            .presentationDetents([.medium])
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
                .foregroundColor(.black)
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
                        if let response = request.response {
                            HStack {
                                Text(response.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                Spacer()
                            }
                        } else if isLoading && request == requestMessages.last {
                            // 답변이 아직 없는 마지막 메시지에만 로딩 말풍선 표시
                            HStack {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("응답 생성 중...")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct ChatBubbleLoading: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text("응답 생성 중...")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray4))
        .foregroundColor(.black)
        .cornerRadius(16)
        .frame(maxWidth: 280, alignment: .leading)
    }
}
