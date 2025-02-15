//
//  MainViewModle.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation
import Combine

@Observable
final class MainViewModel {
    var songName = "Night Changes"
    var artistName = "One Direction"
    var currentTime: TimeInterval = 0
    var currentLyrics: String = ""
    var lyrics: [SyncedLyric] = []
    
    @ObservationIgnored let apiCaller = ApiCaller()
    
    @ObservationIgnored private var timer: AnyCancellable? = nil
    
    init() {
        Task {
            let plainLyrics = await apiCaller.fetchLyrics(
                songName: songName,
                artistName: artistName
            )
            
            let syncedLyrics = LyricsManager.shared.getSyncedLyrics(plainLyrics: plainLyrics)
            
            lyrics = syncedLyrics.sorted { $0.timestamp < $1.timestamp }
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                
                guard let self else { return }
                
                self.currentTime += 0.1
                self.updateLyrics()
            })
    }
    
    func updateLyrics() {
        if let lyric = lyrics.last(where: { $0.timestamp <= currentTime }) {
            currentLyrics = lyric.lyric
        }
    }
    
    func stopTimer() {
        timer?.cancel()
    }
    
}
