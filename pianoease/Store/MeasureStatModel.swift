import Foundation
import SwiftData

/// SwiftData model for per-measure practice statistics.
/// Aligned with web version db/schema.ts practice_measure_stats table.
@Model
final class MeasureStatModel {
    @Attribute(.unique) var id: UUID = UUID()
    var measureIndex: Int = 0
    var hand: String = "right"  // Hand raw value
    var hitCount: Int = 0
    var missCount: Int = 0
    var avgTimingOffsetMs: Int?
    
    var practiceSession: PracticeSessionModel?
    
    init() {}
}
