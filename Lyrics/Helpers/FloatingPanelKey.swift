//
//  FloatingPanelKey.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/18.
//
import SwiftUI

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}
