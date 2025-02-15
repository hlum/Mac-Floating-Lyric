//
//  SyncedLyric.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation

struct SyncedLyric: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let lyric: String
}
