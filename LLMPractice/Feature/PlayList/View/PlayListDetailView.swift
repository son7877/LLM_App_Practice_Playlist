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
                .onTapGesture {  // 노래 클릭 시 애플 뮤직 플레이어로 이동
                    if let musicKitID = song.musicKitID {
                        let musicURL = URL(
                            string: "music://music.apple.com/song/\(musicKitID)")!
                        let webURL = URL(string: "https://music.apple.com/song/\(musicKitID)")!

                        if UIApplication.shared.canOpenURL(musicURL) {
                            UIApplication.shared.open(musicURL)
                        } else {
                            UIApplication.shared.open(webURL)
                        }
                    }
                }
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
