//
//  PeripheralState.swift
//  Lyrics
//
//  Created by cmStudent on 2025/04/02.
//


import SwiftUI

enum PeripheralState: String {
    case scanning, disconnected, connecting, connected, error
    
    var color: Color {
        switch self {
        case .scanning:
                .gray
        case .disconnected:
                .orange
        case .connecting:
                .blue
        case .connected:
                .green
        case .error:
                .red
        }
    }
}
