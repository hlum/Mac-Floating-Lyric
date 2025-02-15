//
//  LyricsManager.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation

class LyricsManager {
    static let shared = LyricsManager()
    
    func getSyncedLyrics(plainLyrics: String) -> [SyncedLyric] {
        
        let lines = plainLyrics.components(separatedBy: "\n")
        var lyrics: [SyncedLyric] = []
        
        let timeRegex = #"\[(\d+):(\d+\.\d+)\]\s*(.*)"#  // Matches [MM:SS.ss] Lyrics text
        let regex = try! NSRegularExpression(pattern: timeRegex)
        
        for line in lines {
            
            let nsLine = line as NSString
            
            if let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)) {
                let minutes = Double(nsLine.substring(with: match.range(at: 1))) ?? 0
                let seconds = Double(nsLine.substring(with: match.range(at: 2))) ?? 0
                let text = nsLine.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)
                
                let totalSeconds = (minutes * 60) + seconds
                
                let syncedLyric = SyncedLyric(timestamp: totalSeconds, lyric: text)
                lyrics.append(syncedLyric)
            }
        }
        
        return lyrics
    }
}
