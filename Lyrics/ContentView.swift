//
//  ContentView.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import SwiftUI

struct ContentView: View {
    @State var isPlaying: Bool = false
    @State var artistName = "Unknown"
    @State var songName = "Unknown"
    var body: some View {
        VStack {
            Text(isPlaying ? "Playing" : "Not Playing")
            Text(songName)
            Text(artistName)
        }
        .onAppear {
            MusicMonitor.shared.startMonitoring()
            MusicMonitor.shared.getMusicInfo = { currentMusic in
                DispatchQueue.main.async {
                    isPlaying = currentMusic.isPlaying
                    songName = currentMusic.songName
                    artistName = currentMusic.artistName
                }
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
