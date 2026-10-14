import Foundation

/// Timing judgement for practice notes.
/// Aligned with web version: lib/practice/judgement.ts

// MARK: - Constants

let kPerfectWindowMs: Double = 50.0
let kGoodWindowMs: Double = 150.0

// MARK: - Timing Judge

enum TimingJudge: String, CaseIterable {
    case perfect = "Perfect"
    case good = "Good"
    case miss = "Miss"
    case wrong = "Wrong"

    var scoreValue: Int {
        switch self {
        case .perfect: return 100
        case .good: return 50
        case .miss, .wrong: return 0
        }
    }
}

// MARK: - Classification

func classifyTimingJudge(timingOffsetMs: Double) -> TimingJudge {
    let delta = abs(timingOffsetMs)
    if delta <= kPerfectWindowMs { return .perfect }
    if delta <= kGoodWindowMs { return .good }
    return .miss
}
