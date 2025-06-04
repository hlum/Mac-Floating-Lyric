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
class MainViewModel {
    var currentTime: TimeInterval = 0
    var currentLyrics: String = ""
    var lyrics: [SyncedLyric] = []
    
    private let btManager = BluetoothManager.shared
    
    var peripheralState: PeripheralState = .scanning


    @ObservationIgnored let apiCaller = ApiCaller()
        
    @ObservationIgnored private var timer: AnyCancellable? = nil
    
    @ObservationIgnored private var lastTimeSongName: String? = nil
    
    @ObservationIgnored private var lastTimeArtistName: String? = nil
    
    @ObservationIgnored private var lastUpdatedTime: Date = Date() + 3
    @ObservationIgnored private var timeBetweenUpdate: TimeInterval = 2
    
    @ObservationIgnored private var currentTimeFixDelta: TimeInterval = 1
    
    init() {
        getCurrentPlayingSongInfoAndSearchLyrics()
        
        btManager.peripheralStateChanged = { [weak self] state in
            self?.peripheralState = state
            Logger.standard.info("\(state.rawValue)")
        }
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
            
            guard currentMusic.isPlaying else {
                fadeTheLyrics()
                Logger.standard.error("Music is stopped")
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
    
    func fadeTheLyrics() {
        currentLyrics = ""
        stopTimer()
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
    
    func stopTimer() {
        timer?.cancel()
    }
    
    func updateLyrics() {
        if Date().timeIntervalSince(lastUpdatedTime) > timeBetweenUpdate {
            // check for playback duration for every 2sec
            lastUpdatedTime = Date()
            currentTime = MusicMonitor.shared.getMusicPlaybackTime()
        }
        if let lyric = lyrics.last(where: { $0.timestamp <= currentTime + currentTimeFixDelta }) {
            let unicodeLyrics = changeToUnicode(lyric.lyric)

            if currentLyrics != unicodeLyrics {
                SerialManager2.shared.sendMessage(message: unicodeLyrics)
                Logger.standard.info("\(unicodeLyrics)")
                sendDataThroughBTSerial(lyrics: unicodeLyrics)
                currentLyrics = unicodeLyrics
            }
        }
    }
    
    private func changeToUnicode(_ input: String) -> String {
        if Rabbit.isZawgyiV2(input) {
            return Rabbit.zg2uni(input)
        } else {
            return input
        }
    }
}

extension MainViewModel {
    private func sendDataThroughBTSerial(lyrics: String) {
        guard let char = btManager.esp32Characteristic,
              let data = lyrics.data(using: .utf8)
        else {
            Logger.standard.warning("Characteristic not found")
            return
        }
        
        guard self.peripheralState == .connected else {
            Logger.standard.warning("Device is not connected. Please connect the device first.")
            return
        }
        btManager.esp32?.writeValue(data, for: char, type: .withResponse)

    }
}
