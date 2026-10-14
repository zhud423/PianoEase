import Foundation
import SwiftData

/// SwiftData model for persisting practice sessions locally.
/// Schema aligned with web version db/schema.ts practice_sessions table.
@Model
final class PracticeSessionModel {
    @Attribute(.unique) var id: UUID = UUID()
    var songId: String = ""
    var variant: String = "lv1"  // ChartVariantId raw value
    var mode: String = "waiting"  // PracticeMode raw value
    var score: Int = 0
    var hitCount: Int = 0
    var missCount: Int = 0
    var wrongCount: Int = 0
    var requiredNoteCount: Int = 0
    var rightAccuracyPct: Int = 0
    var leftAccuracyPct: Int = 0
    var completionPct: Int = 0
    var startedAt: Date = Date()
    var endedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \MeasureStatModel.practiceSession)
    var measureStats: [MeasureStatModel] = []
    
    init() {}
    
    static func from(record: PracticeSessionRecord) -> PracticeSessionModel {
        let model = PracticeSessionModel()
        model.id = record.id
        model.songId = record.songId
        model.variant = record.variant.rawValue
        model.mode = record.mode.rawValue
        model.score = record.score
        model.hitCount = record.hitCount
        model.missCount = record.missCount
        model.wrongCount = record.wrongCount
        model.requiredNoteCount = record.requiredNoteCount
        model.rightAccuracyPct = record.rightAccuracyPct
        model.leftAccuracyPct = record.leftAccuracyPct
        model.completionPct = record.completionPct
        model.startedAt = record.startedAt
        model.endedAt = record.endedAt
        return model
    }
    
    func toRecord() -> PracticeSessionRecord {
        PracticeSessionRecord(
            id: id,
            songId: songId,
            variant: ChartVariantId(rawValue: variant) ?? .lv1,
            mode: PracticeMode(rawValue: mode) ?? .waiting,
            score: score,
            hitCount: hitCount,
            missCount: missCount,
            wrongCount: wrongCount,
            requiredNoteCount: requiredNoteCount,
            rightAccuracyPct: rightAccuracyPct,
            leftAccuracyPct: leftAccuracyPct,
            completionPct: completionPct,
            startedAt: startedAt,
            endedAt: endedAt
        )
    }
}
