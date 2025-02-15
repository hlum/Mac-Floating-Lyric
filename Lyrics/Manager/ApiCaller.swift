//
//  ApiCaller.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import Foundation

@Observable
final class ApiCaller {
    private let baseURL = "https://lrclib.net/api/get"
    func fetchLyrics(songName: String, artistName: String) async -> String {
        guard var urlComponents = URLComponents(string: baseURL) else {
            Logger.standard.error("!! Invalid URL")
            return ""
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "track_name", value: songName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        
        guard let url = urlComponents.url else {
            Logger.standard.error("!! Can't create the url from url components")
            return ""
        }
        print(url)
        https://lrclib.net/api/search?q=Norwegian%20Wood%20The%20Beatles
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                Logger.standard.error("!! Invalid url response")
                return ""
            }
            
            let decoder = JSONDecoder()
            let lyrics = try decoder.decode(Lyrics.self, from: data)
            return lyrics.syncedLyrics
        } catch {
            Logger.standard.error("!! Can't fetch data: \(error.localizedDescription)")
            return ""
        }
    }
}
