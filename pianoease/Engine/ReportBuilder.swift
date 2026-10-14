import Foundation

/// Builds practice report summary, aligned with web version practice/report-summary.ts
struct ReportSummary {
    let heatValues: [Int]
    let maxMissValue: Int
    let weakestMeasureIndex: Int
    let rhythmLabel: String
    let weakBarLabel: String
}

final class ReportBuilder {
    static func build(measureStats: [PracticeMeasureStatPayload], measureCount: Int) -> ReportSummary {
        let safeMeasureCount = max(1, measureCount)
        var missByMeasure: [Int: Int] = [:]
        let timingSamples = measureStats.filter { $0.avgTimingOffsetMs != nil }
        
        for stat in measureStats {
            missByMeasure[stat.measureIndex, default: 0] += stat.missCount
        }
        
        let heatValues = (0..<safeMeasureCount).map { missByMeasure[$0] ?? 0 }
        let maxMissValue = max(1, heatValues.max() ?? 1)
        let highestMiss = heatValues.max() ?? 0
        let weakestMeasureIndex = highestMiss > 0 ? (heatValues.firstIndex(of: highestMiss) ?? -1) : -1
        
        let avgTimingOffsetMs: Double? = {
            guard !timingSamples.isEmpty else { return nil }
            let sum = timingSamples.compactMap { $0.avgTimingOffsetMs }.reduce(0, +)
            return (sum / Double(timingSamples.count)).rounded()
        }()
        
        let rhythmLabel: String = {
            guard let offset = avgTimingOffsetMs else { return "暂无节奏数据" }
            if offset > 0 { return "整体偏慢 \(Int(offset))ms" }
            if offset < 0 { return "整体偏快 \(Int(abs(offset)))ms" }
            return "节奏稳定"
        }()
        
        let weakBarLabel = weakestMeasureIndex >= 0 ? "第 \(weakestMeasureIndex + 1) 小节" : "暂无薄弱小节"
        
        return ReportSummary(
            heatValues: heatValues,
            maxMissValue: maxMissValue,
            weakestMeasureIndex: weakestMeasureIndex,
            rhythmLabel: rhythmLabel,
            weakBarLabel: weakBarLabel
        )
    }
}
