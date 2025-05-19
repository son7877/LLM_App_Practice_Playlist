//
//  PlayList.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI
import SwiftData

struct PlayListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = PlayListViewModel()
    @State private var showingCreatePlayList = false
    @State private var newPlayListTitle = ""
    @State private var showingChat = false
    @State private var showingShare = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if viewModel.playList.isEmpty {
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
                        // 플레이리스트 목록
                        List {
                            ForEach(viewModel.playList) { playlist in
                                NavigationLink(destination: PlayListDetailView(playlist: playlist)) {
                                    HStack {
                                        // 플레이리스트 썸네일
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
                            showingShare = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
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
                    Button(action: {
                        showingCreatePlayList = true
                    }) {
                        Image(systemName: "plus")
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
            .sheet(isPresented: $showingChat) {
                NavigationStack {
                    LLMChatView(viewModel: LLMChatViewModel(modelContext: modelContext))
                }
            }
            .sheet(isPresented: $showingShare) {
                // TODO: 공유 기능 구현
                // ShareView()
                Text("플레이리스트 공유")
            }
        }
    }
}

#Preview {
    PlayListView()
}


