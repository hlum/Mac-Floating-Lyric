//
//  MusicMonitor.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation
import AppKit
import MediaPlayer

class MusicMonitor {
    static let shared = MusicMonitor()
    var lastTimeUpdate:Date = .now + 0.5
    var timeBetweenUpdate:TimeInterval = 0.5
    var getMusicInfo: ((CurrentMusic) -> Void)?

    private init() {}
    
    deinit { stopMonitoring() }

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

        if Date().timeIntervalSince(lastTimeUpdate) > timeBetweenUpdate {
            lastTimeUpdate = Date()
            
            let currentMusic = CurrentMusic(
                isPlaying: isPlaying,
                songName: trackTitle,
                artistName: artist
            )
            getMusicInfo?(currentMusic)
        }
        
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }

    func getMusicPlaybackTime() -> TimeInterval {
        let task = Process()
        let pipe = Pipe()
        
        // Run command via bash to ensure it works like Terminal
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        
        // Pass the osascript command as a shell command
        task.arguments = ["-c", "osascript -e 'tell application \"Music\" to player position'"]
        
        task.standardOutput = pipe
        
        do {
            try task.run()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let timeInterval = Double(output){
                return Double(timeInterval)
            }
        } catch {
            Logger.standard.error("Error executing script: \(error.localizedDescription)")
            return 0
        }
        Logger.standard.error("Failed to retrieve playback time")
        return 0
    }
    
}
