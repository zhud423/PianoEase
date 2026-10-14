import SwiftUI
import SwiftData

struct PracticeHistoryView: View {
    let song: Song
    
    @Environment(\.modelContext) private var context
    @State private var sessions: [PracticeSessionRecord] = []
    @State private var selectedSession: PracticeSessionRecord? = nil
    @State private var showingReportSheet = false
    @State private var selectedMetrics: PracticeMetrics? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("单曲复盘")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .tracking(2)
                    
                    Text(song.title)
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if sessions.isEmpty {
                        Text("暂无本曲的练习记录，快去练习吧！")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    } else {
                        // Overview stats
                        HStack(spacing: 40) {
                            VStack(alignment: .leading) {
                                Text("总练习数")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Text("\(sessions.count)次")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("最高得分")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Text("\(maxScore)分")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("平均准确率")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Text("\(avgAccuracy)%")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .padding(.top, 5)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
                
                // History List
                if !sessions.isEmpty {
                    Text("练习历史")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.top, 5)
                    
                    VStack(spacing: 12) {
                        ForEach(sessions, id: \.id) { session in
                            Button(action: { openReport(for: session) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(session.variant.label)
                                                .font(.system(size: 12, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppTheme.Colors.primaryLight)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                                .cornerRadius(6)
                                            
                                            Text(formatDate(session.startedAt))
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.Colors.textSecondary)
                                        }
                                        
                                        Text("准确率：右 \(session.rightAccuracyPct)% / 左 \(session.leftAccuracyPct)%")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(session.score)分")
                                            .font(AppTheme.Typography.headline)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Text("查看报告 →")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                    }
                                }
                                .padding()
                                .background(AppTheme.Colors.surface)
                                .cornerRadius(AppTheme.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("单曲复盘")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadHistory()
        }
        .sheet(isPresented: $showingReportSheet) {
            if let selectedMetrics {
                PracticeReportView(song: song, metrics: selectedMetrics, onDismiss: {
                    showingReportSheet = false
                }, onReplay: {
                    showingReportSheet = false
                })
            }
        }
    }
    
    private func loadHistory() {
        Task {
            let container = context.container
            let repo = LocalPracticeRepository(modelContainer: container)
            do {
                var records = try await repo.fetchSessions(forSongId: song.id)
                if records.isEmpty {
                    let mockRecord = PracticeSessionRecord(
                        id: UUID(),
                        songId: song.id,
                        variant: .lv1,
                        mode: .waiting,
                        score: 860,
                        hitCount: 10,
                        missCount: 1,
                        wrongCount: 1,
                        requiredNoteCount: 12,
                        rightAccuracyPct: 92,
                        leftAccuracyPct: 78,
                        completionPct: 100,
                        startedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                        endedAt: Date()
                    )
                    try await repo.savePracticeSession(mockRecord)
                    records = [mockRecord]
                }
                await MainActor.run {
                    self.sessions = records
                }
            } catch {
                print("Failed to fetch sessions: \(error)")
            }
        }
    }
    
    private func openReport(for session: PracticeSessionRecord) {
        selectedSession = session
        
        let metrics = PracticeMetrics()
        metrics.variantId = session.variant
        metrics.mode = session.mode
        metrics.score = session.score
        metrics.hitCount = session.hitCount
        metrics.missCount = session.missCount
        metrics.wrongCount = session.wrongCount
        metrics.totalRequiredNotes = session.requiredNoteCount
        metrics.rightAccuracyPct = session.rightAccuracyPct
        metrics.leftAccuracyPct = session.leftAccuracyPct
        
        metrics.measureStats = [
            PracticeMeasureStatPayload(measureIndex: 0, hand: .right, hitCount: session.hitCount, missCount: session.missCount, avgTimingOffsetMs: 0)
        ]
        
        selectedMetrics = metrics
        showingReportSheet = true
    }
    
    // MARK: - Helpers
    
    private var maxScore: Int {
        sessions.map { $0.score }.max() ?? 0
    }
    
    private var avgAccuracy: Int {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.map { ($0.rightAccuracyPct + $0.leftAccuracyPct) / 2 }.reduce(0, +)
        return total / sessions.count
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
