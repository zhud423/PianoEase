import Foundation

/// Real-time practice metrics.
/// Aligned with web version: lib/practice/metrics.ts

// MARK: - Practice Mode & State

enum PracticeMode: String, Codable {
    case waiting
    case free
}

enum PracticeState {
    case idle
    case playing
    case paused
    case finished
}

// MARK: - Measure Stats

struct PracticeMeasureStatPayload {
    let measureIndex: Int
    let hand: Hand
    var hitCount: Int = 0
    var missCount: Int = 0
    var avgTimingOffsetMs: Double?
}

struct PracticeMeasureWrongPayload {
    let measureIndex: Int
    var wrongCount: Int = 0
}

// MARK: - Practice Metrics

@Observable
final class PracticeMetrics {
    var variantId: ChartVariantId = .lv1
    var mode: PracticeMode = .waiting
    var score: Int = 0
    var combo: Int = 0
    var maxCombo: Int = 0
    var perfectCount: Int = 0
    var goodCount: Int = 0
    var wrongCount: Int = 0
    var missCount: Int = 0
    var hitCount: Int = 0
    var totalRequiredNotes: Int = 0
    var rightAccuracyPct: Int = 0
    var leftAccuracyPct: Int = 0
    var currentMeasureIndex: Int = 0
    var measureStats: [PracticeMeasureStatPayload] = []
    var wrongByMeasure: [PracticeMeasureWrongPayload] = []

    var overallAccuracyPct: Int {
        guard totalRequiredNotes > 0 else { return 0 }
        return Int(Double(hitCount) / Double(totalRequiredNotes) * 100)
    }

    var starRating: Int {
        switch overallAccuracyPct {
        case 90...100: return 3
        case 70..<90: return 2
        case 50..<70: return 1
        default: return 0
        }
    }

    func reset() {
        score = 0; combo = 0; maxCombo = 0
        perfectCount = 0; goodCount = 0; wrongCount = 0
        missCount = 0; hitCount = 0
        totalRequiredNotes = 0; rightAccuracyPct = 0; leftAccuracyPct = 0
        currentMeasureIndex = 0; measureStats = []; wrongByMeasure = []
    }
}
