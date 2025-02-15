//
//  Logger.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//
import Foundation
import OSLog

public enum Logger {
    public static let standard: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.apiCall.rawValue
    )
}

private enum LogCategory: String {
    case apiCall = "API Call"
}
