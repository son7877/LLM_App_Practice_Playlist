//
//  PlayListDetailView.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import SwiftUI

struct PlayListDetailView: View {
    let playlist: PlayList
    
    var body: some View {
        List {
            ForEach(playlist.songs) { song in
                HStack {
                    // 노래 썸네일
                    if let albumArt = song.albumArt {
                        AsyncImage(url: URL(string: albumArt)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    } else {
                        Image(systemName: "music.note")
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(formatDuration(song.duration))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(playlist.title)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        PlayListDetailView(playlist: PlayList(
            title: "샘플 플레이리스트",
            songs: [
                Song(title: "샘플 노래 1", artist: "아티스트 1", duration: 180),
                Song(title: "샘플 노래 2", artist: "아티스트 2", duration: 240)
            ]
        ))
    }
} 