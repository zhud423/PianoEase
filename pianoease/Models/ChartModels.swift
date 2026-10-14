import Foundation

// MARK: - Chart Variant ID
// Aligned with web version: lib/chart/types.ts → ChartVariantId

enum ChartVariantId: String, Codable, CaseIterable {
    case original
    case lv1
    case lv2
    case lv3

    var label: String {
        switch self {
        case .original: return "原谱"
        case .lv1: return "Lv1 根音"
        case .lv2: return "Lv2 柱式"
        case .lv3: return "Lv3 分解"
        }
    }
}

// MARK: - Hand

enum Hand: String, Codable {
    case left
    case right
}

// MARK: - Song Chart
// Aligned with web version: lib/chart/types.ts → SongChart

struct SongChart: Codable {
    let songId: String
    let title: String
    let bpm: Int
    let ppq: Int
    let timeSignature: [Int]
    let keySignature: String
    let variants: [ChartVariant]

    func variant(for id: ChartVariantId) -> ChartVariant? {
        variants.first { $0.id == id }
    }
}

// MARK: - Chart Variant

struct ChartVariant: Codable {
    let id: ChartVariantId
    let label: String
    let measures: [Measure]
    let noteEvents: [NoteEvent]
    let chordSegments: [ChordSegment]
}

// MARK: - Measure

struct Measure: Codable {
    let index: Int
    let startTick: Int
    let endTick: Int
}

// MARK: - Note Event

struct NoteEvent: Codable, Identifiable {
    let id: String
    let hand: Hand
    let midi: Int
    let pitchName: String
    let startTick: Int
    let durationTick: Int
    let measureIndex: Int
    let beatInMeasure: Double
    let voice: String?
    let required: Bool
    let optional: Bool
    let chordSymbol: String?
}

// MARK: - Chord Segment

struct ChordSegment: Codable {
    let measureIndex: Int
    let startTick: Int
    let endTick: Int
    let symbol: String
    let leftHandPattern: String?
}
