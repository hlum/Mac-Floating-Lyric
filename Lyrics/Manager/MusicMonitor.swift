//
//  MusicMonitor.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation
import AppKit

class MusicMonitor {
    static let shared = MusicMonitor()
    var lastTimePlayState: Bool? // Start as nil to force first update
     var lastTrackTitle: String? // Track the last song to detect song change
    var getMusicInfo: ((CurrentMusic) -> Void)?

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

    func stopMonitoring() {
        let center = DistributedNotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil)
    }

    @objc private func handlePlayerInfo(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            print("!! Can't get userInfo from Notification")
            return
        }

        let trackTitle = userInfo["Name"] as? String ?? "No Song"
        let artist = userInfo["Artist"] as? String ?? "Unknown Artist"
        let isPlaying = (userInfo["Player State"] as? String == "Playing")

        // Check if the song has changed or if the player state changed
        if lastTrackTitle != trackTitle || lastTimePlayState == nil || isPlaying != lastTimePlayState {
            lastTrackTitle = trackTitle
            lastTimePlayState = isPlaying
            
            let currentMusic = CurrentMusic(
                isPlaying: isPlaying,
                songName: trackTitle,
                artistName: artist
            )
            getMusicInfo?(currentMusic)
        }
    }
}
