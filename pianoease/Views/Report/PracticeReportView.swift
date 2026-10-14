import SwiftUI

struct PracticeReportView: View {
    let song: Song
    let metrics: PracticeMetrics
    let onDismiss: () -> Void
    let onReplay: () -> Void
    
    @State private var summary: ReportSummary? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header Star/Result Card
                VStack(spacing: 15) {
                    Text("练习报告")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .tracking(2)
                    
                    Text(song.title)
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    // Star rating
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { star in
                            Image(systemName: star <= metrics.starRating ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundColor(star <= metrics.starRating ? AppTheme.Colors.judgePerfect : AppTheme.Colors.textTertiary)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    Text("\(metrics.score)分")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                .padding(AppTheme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .cardStyle()
                
                // Detailed metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Right hand accuracy
                    VStack(alignment: .leading, spacing: 8) {
                        Text("右手准确率")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text("\(metrics.rightAccuracyPct)%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.noteRight)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                    
                    // Left hand accuracy
                    VStack(alignment: .leading, spacing: 8) {
                        Text("左手准确率")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text("\(metrics.leftAccuracyPct)%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.noteLeft)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                    
                    // Rhythm stability
                    VStack(alignment: .leading, spacing: 8) {
                        Text("节奏评价")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text(summary?.rhythmLabel ?? "暂无数据")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                    
                    // Weakest measure
                    VStack(alignment: .leading, spacing: 8) {
                        Text("薄弱小节")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text(summary?.weakBarLabel ?? "暂无数据")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.levelChallenge)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }
                
                // Heatmap Section
                if let summary {
                    MeasureHeatmapView(heatValues: summary.heatValues, maxMissValue: summary.maxMissValue)
                }
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: onReplay) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("再练一次")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.md)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDismiss) {
                        Text("回首页")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.Colors.surface)
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .stroke(AppTheme.Colors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 10)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            computeSummary()
        }
    }
    
    private func computeSummary() {
        let totalMeasures = metrics.measureStats.map { $0.measureIndex }.max().map { $0 + 1 } ?? 1
        summary = ReportBuilder.build(measureStats: metrics.measureStats, measureCount: totalMeasures)
    }
}

#Preview {
    let mockSong = Song(id: "test", title: "友情岁月", subtitle: "Young and Dangerous", bpm: 74, durationLabel: "02:15", level: .beginner)
    let mockMetrics = PracticeMetrics()
    mockMetrics.score = 860
    mockMetrics.perfectCount = 8
    mockMetrics.goodCount = 2
    mockMetrics.hitCount = 10
    mockMetrics.totalRequiredNotes = 12
    mockMetrics.rightAccuracyPct = 92
    mockMetrics.leftAccuracyPct = 78
    mockMetrics.measureStats = [
        PracticeMeasureStatPayload(measureIndex: 0, hand: .right, hitCount: 2, missCount: 0, avgTimingOffsetMs: -15.0),
        PracticeMeasureStatPayload(measureIndex: 1, hand: .right, hitCount: 2, missCount: 1, avgTimingOffsetMs: 5.0),
        PracticeMeasureStatPayload(measureIndex: 2, hand: .right, hitCount: 2, missCount: 0, avgTimingOffsetMs: 2.0),
        PracticeMeasureStatPayload(measureIndex: 3, hand: .right, hitCount: 4, missCount: 0, avgTimingOffsetMs: -5.0)
    ]
    return PracticeReportView(song: mockSong, metrics: mockMetrics, onDismiss: {}, onReplay: {})
}
