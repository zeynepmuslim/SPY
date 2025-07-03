//
//  structs.swift
//  Spy
//
//  Created by Zeynep Müslim on 19.06.2025.
//

struct PlayerScore {
    let id: Int
    let name: String
    var score: Int
}

struct DefaultCategory: Codable {
    let icon: String
    let title: String
    let values: [String]
}

struct HowToPlayData: Codable {
    let howToPlay: [HowToPlayItem]
}

struct HowToPlayItem: Codable {
    let title: String
    let text: String
}
