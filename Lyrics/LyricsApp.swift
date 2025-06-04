//
//  LyricsApp.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import SwiftUI
import LaunchAtLogin

@main
struct LyricsApp: App {
    
    init() {
        FloatingPanelManager.shared.show()
    }
    
    var body: some Scene {
        MenuBarExtra("Lyrics", systemImage: "music.note") {
            VStack(alignment: .leading, spacing: 12) {
                LaunchAtLogin.Toggle()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .frame(minWidth: 200, minHeight: 200)
        }
    }
}
