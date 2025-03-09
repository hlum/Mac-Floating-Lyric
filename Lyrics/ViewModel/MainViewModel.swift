//
//  MainViewModle.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation
import Combine
import MediaPlayer
import AppleScriptObjC

@Observable
final class MainViewModel {
    var currentTime: TimeInterval = 0
    var currentLyrics: String = ""
    var lyrics: [SyncedLyric] = []
    
    @ObservationIgnored let apiCaller = ApiCaller()
    
    @ObservationIgnored private var lastTimeLyrics: String? = nil
    
    @ObservationIgnored private var timer: AnyCancellable? = nil
    
    @ObservationIgnored private var lastTimeSongName: String? = nil
    
    @ObservationIgnored private var lastTimeArtistName: String? = nil
    
    @ObservationIgnored private var lastUpdatedTime: Date = Date() + 3
    @ObservationIgnored private var timeBetweenUpdate: TimeInterval = 2
    
    @ObservationIgnored private var currentTimeFixDelta: TimeInterval = 1
    
    init() {
        getCurrentPlayingSongInfoAndSearchLyrics()
    }
    
    deinit {
        MusicMonitor.shared.stopMonitoring()
    }
    
    func getCurrentPlayingSongInfoAndSearchLyrics() {
        MusicMonitor.shared.startMonitoring()
        MusicMonitor.shared.getMusicInfo = { [weak self] currentMusic in
            guard let self = self else {
                Logger.standard.error("!! Can't get self")
                return
            }
            if currentMusic.songName != self.lastTimeSongName ||
                currentMusic.artistName != self.lastTimeArtistName {
                // Current Song changed
                self.lastTimeSongName = currentMusic.songName
                self.lastTimeArtistName = currentMusic.artistName
                
                self.getLyrics(songName: currentMusic.songName, artistName: currentMusic.artistName)
            } else {
                // Same song but playback time changes
                self.updateLyrics()
            }
            
            self.startTimer()

        }
    }
    
    func getLyrics(songName: String, artistName: String) {
        lyrics = []
        currentLyrics = ""
        Task {
            let plainLyrics = await apiCaller.fetchLyrics(
                songName: songName,
                artistName: artistName
            )
            
            let syncedLyrics = LyricsManager.shared.getSyncedLyrics(plainLyrics: plainLyrics)
            
            lyrics = syncedLyrics.sorted { $0.timestamp < $1.timestamp }
            self.updateLyrics()
        }
    }
    
    func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                
                guard let self else { return }
                
                self.currentTime += 0.1
                self.updateLyrics()
            })
    }
    
    func updateLyrics() {
        if Date().timeIntervalSince(lastUpdatedTime) > timeBetweenUpdate {
            // check for playback duration for every 2sec
            lastUpdatedTime = Date()
            currentTime = MusicMonitor.shared.getMusicPlaybackTime()
        }
        if let lyric = lyrics.last(where: { $0.timestamp <= currentTime + currentTimeFixDelta }) {
            if currentLyrics != lastTimeLyrics {
                SerialManager2.shared.sendMessage(message: lyric.lyric)
                lastTimeLyrics = lyric.lyric
            }
            currentLyrics = lyric.lyric
        }
    }
    
    func stopTimer() {
        timer?.cancel()
    }
}
