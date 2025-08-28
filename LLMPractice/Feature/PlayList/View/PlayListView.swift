//
//  PlayList.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import SwiftData
import SwiftUI

struct PlayListView: View {
    private let modelContext: ModelContext
    @StateObject private var viewModel: PlayListViewModel
    @State private var showingCreatePlayList = false
    @State private var newPlayListTitle = ""
    @State private var showingChat = false
    @State private var showingShare = false
    @State private var selectedPlaylistForShare: PlayList?
    @State private var isSelectionMode = false
    @State private var selectedPlaylists: Set<PlayList> = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: PlayListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if viewModel.playLists.isEmpty {
                        // 플레이리스트가 없을 경우 표시할 뷰
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "music.note.list")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)

                            Text("플레이리스트가 없습니다")
                                .font(.title2)
                                .foregroundColor(.gray)

                            Button(action: {
                                showingCreatePlayList = true
                            }) {
                                Text("플레이리스트 추가하기")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }

                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.playLists) { playlist in
                                HStack {
                                    if isSelectionMode {
                                        Image(
                                            systemName: selectedPlaylists.contains(playlist)
                                                ? "checkmark.circle.fill" : "circle"
                                        )
                                        .foregroundColor(
                                            selectedPlaylists.contains(playlist) ? .blue : .gray
                                        )
                                        .onTapGesture {
                                            if selectedPlaylists.contains(playlist) {
                                                selectedPlaylists.remove(playlist)
                                            } else {
                                                selectedPlaylists.insert(playlist)
                                            }
                                        }
                                    }

                                    NavigationLink(
                                        destination: PlayListDetailView(playlist: playlist)
                                    ) {
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
                                                Text("\(playlist.songs.count)곡")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .disabled(isSelectionMode)
                                }
                            }
                            .onDelete { indexSet in
                                viewModel.deletePlayList(at: indexSet)
                            }
                        }
                    }
                }

                // 하단 버튼들
                VStack {
                    Spacer()
                    HStack {
                        // 공유 버튼
                        Button(action: {
                            if isSelectionMode {
                                if let selectedPlaylist = selectedPlaylists.first {
                                    selectedPlaylistForShare = selectedPlaylist
                                    showingShare = true
                                }
                                isSelectionMode = false
                                selectedPlaylists.removeAll()
                            } else {
                                isSelectionMode = true
                            }
                        }) {
                            Image(
                                systemName: isSelectionMode
                                    ? "checkmark.circle.fill" : "square.and.arrow.up"
                            )
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(isSelectionMode ? Color.blue : Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                        }
                        .padding()

                        Spacer()

                        // LLM Chat 버튼
                        Button(action: {
                            showingChat = true
                        }) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            // 네비게이션 타이틀 및 버튼 설정
            .navigationTitle("나의 플레이리스트")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        Button("취소") {
                            isSelectionMode = false
                            selectedPlaylists.removeAll()
                        }
                    } else {
                        Button(action: {
                            showingCreatePlayList = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
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
                                viewModel.createPlayList(title: newPlayListTitle)
                                newPlayListTitle = ""
                                showingCreatePlayList = false
                            }
                        }
                    )
                }
                .presentationDetents([.height(200)])
            }
            .sheet(
                isPresented: $showingChat,
                onDismiss: {
                    viewModel.loadPlayLists()
                }
            ) {
                NavigationStack {
                    LLMChatView(viewModel: LLMChatViewModel(modelContext: modelContext))
                }
            }
            .sheet(isPresented: $showingShare) {
                if let playlist = selectedPlaylistForShare {
                    ShareView(playlist: playlist)
                }
            }
        }
    }
}

struct ShareView: View {
    let playlist: PlayList
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("플레이리스트 공유")
                    .font(.title2)
                    .padding(.top)

                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text(playlist.title)
                    .font(.headline)

                Text("\(playlist.songs.count)곡")
                    .foregroundColor(.gray)

                Button(action: {
//                    shareToKakaoTalk()
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                            .background(Color.yellow)
                            .clipShape(Circle())
                        Text("카카오톡으로 공유하기")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }

//    private func shareToKakaoTalk() {
//        // 템플릿 메시지 생성
//        let template = FeedTemplate(
//            content: Content(
//                title: playlist.title,
//                description: "\(playlist.songs.count)곡이 포함된 플레이리스트",
//                imageURL: URL(string: "https://example.com/playlist_image.jpg")!,  // 실제 이미지 URL로 변경 필요
//                link: Link(
//                    webURL: URL(string: "https://example.com/playlist/\(playlist.id)")!,  // 실제 웹 URL로 변경 필요
//                    mobileWebURL: URL(string: "https://example.com/playlist/\(playlist.id)")!
//                )
//            )
//        )
//
//        // 카카오톡 공유
//        if ShareApi.isKakaoTalkSharingAvailable() {
//            ShareApi.shared.shareDefault(templatable: template) { (sharingResult, error) in
//                if let error = error {
//                    print("카카오톡 공유 실패: \(error)")
//                } else {
//                    print("카카오톡 공유 성공")
//                }
//            }
//        } else {
//            // 카카오톡이 설치되어 있지 않은 경우 웹 공유
//            ShareApi.shared.shareDefault(templatable: template) { (sharingResult, error) in
//                if let error = error {
//                    print("웹 공유 실패: \(error)")
//                } else {
//                    print("웹 공유 성공")
//                }
//            }
//        }
//    }
}
