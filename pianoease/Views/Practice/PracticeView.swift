import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let song: Song
    let chart: SongChart
    
    @State private var selectedVariantId: ChartVariantId = .lv1
    @Environment(MIDIManager.self) private var midiManager
    @State private var engine = PracticeEngine()
    
    // UI Feedback state
    @State private var hitJudge: TimingJudge? = nil
    @State private var feedbackTimer: Timer? = nil
    @State private var showingReport = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Header panel matching web Practice Page
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(10)
                .background(AppTheme.Colors.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("练习模式")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Text(song.title)
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                // Real MIDI Connection indicator
                MIDIStatusIndicator(midiManager: midiManager)
                
                Text(song.durationLabel)
                    .font(AppTheme.Typography.body.weight(.semibold))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, 10)
            
            // Middle section (Jianpu preview on top, Waterfall on bottom)
            VStack(spacing: 15) {
                // Jianpu Sheet
                JianpuView(
                    chart: chart,
                    variantId: selectedVariantId,
                    followMeasureIndex: engine.metrics.currentMeasureIndex
                )
                .frame(height: 190)
                .padding(.horizontal, AppTheme.Spacing.lg)
                
                // Waterfall Scene
                ZStack {
                    WaterfallView(engine: engine)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    // Hit Judgement feedback pop-up
                    if let judge = hitJudge {
                        Text(judge.rawValue)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(judgeColor(judge))
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                            .transition(.scale.combined(with: .opacity))
                            .id("feedback_\(judge.rawValue)_\(Date().timeIntervalSince1970)")
                    }
                }
            }
            
            // Bottom stats bar
            HStack {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SCORE")
                            .font(AppTheme.Typography.overline)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("\(engine.metrics.score)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("COMBO")
                            .font(AppTheme.Typography.overline)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("\(engine.metrics.combo)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.levelIntermediate)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACCURACY")
                            .font(AppTheme.Typography.overline)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("\(engine.metrics.overallAccuracyPct)%")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
                .padding(.leading, 15)
                
                Spacer()
                
                // Keyboard simulator instructions (Computer key simulation helper)
                Text("物理键盘仿真(测试用)：A W S E D F T G Y H U J K (C4 - C5)")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .padding(.trailing, 15)
            }
            .padding(AppTheme.Spacing.sm)
            .cardStyle()
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Toolbar
            PracticeToolbar(engine: engine, chart: chart, selectedVariantId: $selectedVariantId)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, 10)
        }
        .background(AppTheme.Colors.background)
        .navigationBarBackButtonHidden(true)
        .focused($isFocused)
        .focusable()
        .onKeyPress(phases: [.down, .up]) { press in
            let midiNote = getMidiNote(for: press.characters)
            guard midiNote > 0 else { return .ignored }
            
            let eventType: MIDIEventType = (press.phase == .down) ? .noteOn : .noteOff
            let velocity = (press.phase == .down) ? 64 : 0
            let event = MIDINoteEvent(type: eventType, note: midiNote, velocity: velocity, timestamp: Date().timeIntervalSince1970)
            engine.handleMIDIEvent(event)
            return .handled
        }
        .onAppear {
            isFocused = true
            engine.configure(chart: chart, variantId: selectedVariantId)
            
            // Setup MIDI note callbacks
            midiManager.onNoteEvent = { event in
                engine.handleMIDIEvent(event)
            }
            
            engine.onNoteHit = { judge in
                showFeedback(judge)
            }
            
            // Register state change updates
            engine.onStateChange = {
                if engine.state == .finished {
                    saveSession()
                    showingReport = true
                }
            }
        }
        .onDisappear {
            engine.reset()
            midiManager.onNoteEvent = nil
        }
        .sheet(isPresented: $showingReport) {
            PracticeReportView(song: song, metrics: engine.metrics, onDismiss: {
                showingReport = false
                engine.reset()
            }, onReplay: {
                showingReport = false
                engine.reset()
                engine.start()
            })
        }
    }
    
    private func showFeedback(_ judge: TimingJudge) {
        feedbackTimer?.invalidate()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            hitJudge = judge
        }
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                hitJudge = nil
            }
        }
    }
    
    private func judgeColor(_ judge: TimingJudge) -> Color {
        switch judge {
        case .perfect: return AppTheme.Colors.judgePerfect
        case .good: return AppTheme.Colors.judgeGood
        case .miss: return AppTheme.Colors.judgeMiss
        case .wrong: return AppTheme.Colors.judgeMiss
        }
    }
    
    private func getMidiNote(for characters: String) -> Int {
        guard let char = characters.first?.lowercased() else { return 0 }
        switch char {
        case "a": return 60 // C4
        case "w": return 61 // C#4
        case "s": return 62 // D4
        case "e": return 63 // D#4
        case "d": return 64 // E4
        case "f": return 65 // F4
        case "t": return 66 // F#4
        case "g": return 67 // G4
        case "y": return 68 // G#4
        case "h": return 69 // A4
        case "u": return 70 // A#4
        case "j": return 71 // B4
        case "k": return 72 // C5
        default: return 0
        }
    }
    
    private func saveSession() {
        let record = PracticeSessionRecord(
            id: UUID(),
            songId: song.id,
            variant: selectedVariantId,
            mode: .waiting,
            score: engine.metrics.score,
            hitCount: engine.metrics.hitCount,
            missCount: engine.metrics.missCount,
            wrongCount: engine.metrics.wrongCount,
            requiredNoteCount: engine.metrics.totalRequiredNotes,
            rightAccuracyPct: engine.metrics.rightAccuracyPct,
            leftAccuracyPct: engine.metrics.leftAccuracyPct,
            completionPct: 100,
            startedAt: Date(),
            endedAt: Date()
        )
        
        Task {
            let container = context.container
            let repo = LocalPracticeRepository(modelContainer: container)
            do {
                try await repo.savePracticeSession(record)
                print("[PracticeView] Practice session saved successfully!")
            } catch {
                print("[PracticeView] Failed to save session: \(error)")
            }
        }
    }
}

