//
//  MusicMonitor.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation

class MusicMonitor {
    static let shared = MusicMonitor()
    
    var getMusicInfo: ((CurrentMusic) -> Void)? = nil

    private init() {}
    
    func startMonitoring() {
        let center = DistributedNotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(handlePlayerInfo(notification:)),
            name: NSNotification.Name("com.apple.iTunes.playerInfo"),
            object: nil
        )
    }
    
    @objc private func handlePlayerInfo(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            Logger.standard.error("!! Can't get userInfo from Notification")
            return
        }
        
        let trackTitle = userInfo["Name"] as? String ?? "No Song"
        let artist = userInfo["Artist"] as? String ?? "Unknown Artist"
        let isPlaying = (userInfo["Player State"] as? String == "Playing")
        
        let currentMusic = CurrentMusic(isPlaying: isPlaying, songName: trackTitle, artistName: artist)
        
        getMusicInfo?(currentMusic)
    }
}
