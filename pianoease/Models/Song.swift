import Foundation

// MARK: - Song Level

enum SongLevel: String, Codable, CaseIterable {
    case beginner = "入门"
    case intermediate = "进阶"
    case challenge = "挑战"
}

// MARK: - Song

struct Song: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let bpm: Int
    let durationLabel: String
    let level: SongLevel
}

// MARK: - Song Manifest

struct SongManifest: Codable {
    let version: String
    let songs: [Song]
}
