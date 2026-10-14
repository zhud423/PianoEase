import Foundation

struct ExpectedNoteGroup {
    let startTick: Int
    let notes: [NoteEvent]
}

/// Core practice engine that coordinates MIDI input with chart data.
/// Handles note matching, timing judgement, and metrics updates.
@Observable
final class PracticeEngine {
    private(set) var state: PracticeState = .idle
    let metrics = PracticeMetrics()
    
    private var chart: SongChart?
    private(set) var currentVariant: ChartVariant?
    
    // Grouped expected notes for wait mode
    private(set) var expectedGroups: [ExpectedNoteGroup] = []
    private(set) var currentGroupIndex: Int = 0
    
    private var activePressedNotes = Set<Int>()
    private var startTime: TimeInterval = 0
    private var lastEventTime: TimeInterval = 0
    
    // Callback to inform UI (waterfall, sheet) to refresh/highlight
    var onStateChange: (() -> Void)?
    var onNoteHit: ((TimingJudge) -> Void)?
    
    /// Configure the engine with chart data and variant
    func configure(chart: SongChart, variantId: ChartVariantId) {
        self.chart = chart
        self.currentVariant = chart.variant(for: variantId)
        metrics.variantId = variantId
        reset()
    }
    
    /// Start or resume the practice session
    func start() {
        guard state == .idle || state == .paused else { return }
        if state == .idle {
            startTime = ProcessInfo.processInfo.systemUptime
            lastEventTime = startTime
            prepareExpectedGroups()
        }
        state = .playing
        onStateChange?()
    }
    
    /// Pause the practice session
    func pause() {
        guard state == .playing else { return }
        state = .paused
        onStateChange?()
    }
    
    /// Reset the practice session
    func reset() {
        state = .idle
        currentGroupIndex = 0
        expectedGroups = []
        activePressedNotes.removeAll()
        metrics.reset()
        if let variant = currentVariant {
            metrics.totalRequiredNotes = variant.noteEvents.filter { $0.required }.count
        }
        onStateChange?()
    }
    
    /// Process a MIDI note event from the keyboard
    func handleMIDIEvent(_ event: MIDINoteEvent) {
        guard state == .playing else { return }
        
        if event.type == .noteOn && event.velocity > 0 {
            processNoteOn(event.note, time: event.timestamp)
        } else if event.type == .noteOff {
            processNoteOff(event.note)
        }
    }
    
    private func processNoteOn(_ midiNote: Int, time: TimeInterval) {
        guard currentGroupIndex < expectedGroups.count else { return }
        let currentGroup = expectedGroups[currentGroupIndex]
        
        let expectedMidis = currentGroup.notes.map { $0.midi }
        
        if expectedMidis.contains(midiNote) {
            // Correct note pressed
            activePressedNotes.insert(midiNote)
            
            // Check if all notes in the chord group are pressed
            let allPressed = expectedMidis.allSatisfy { activePressedNotes.contains($0) }
            if allPressed {
                // Determine timing judge (in wait mode, correct hit is always Perfect)
                let judge: TimingJudge
                if metrics.mode == .waiting {
                    judge = .perfect
                } else {
                    let elapsedSinceLast = (time - lastEventTime) * 1000.0
                    judge = classifyTimingJudge(timingOffsetMs: elapsedSinceLast)
                }
                
                // Update metrics
                let baseScore = judge.scoreValue
                let multiplier = getComboMultiplier(metrics.combo)
                metrics.score += baseScore * multiplier
                
                if judge != .miss && judge != .wrong {
                    metrics.combo += 1
                    metrics.maxCombo = max(metrics.maxCombo, metrics.combo)
                    metrics.hitCount += expectedMidis.count
                    if judge == .perfect { metrics.perfectCount += expectedMidis.count }
                    else { metrics.goodCount += expectedMidis.count }
                } else {
                    metrics.combo = 0
                    metrics.missCount += expectedMidis.count
                }
                
                // Set current measure index
                if let firstNote = currentGroup.notes.first {
                    metrics.currentMeasureIndex = firstNote.measureIndex
                }
                
                // Callback for sound/visual effects
                onNoteHit?(judge)
                
                // Clear active presses for next group
                activePressedNotes.removeAll()
                
                // Advance
                currentGroupIndex += 1
                lastEventTime = time
                
                // Check if completed
                if currentGroupIndex >= expectedGroups.count {
                    state = .finished
                }
                
                onStateChange?()
            }
        } else {
            // Wrong note pressed
            metrics.combo = 0
            metrics.wrongCount += 1
            onNoteHit?(.wrong)
            onStateChange?()
        }
    }
    
    private func processNoteOff(_ midiNote: Int) {
        activePressedNotes.remove(midiNote)
    }
    
    private func prepareExpectedGroups() {
        guard let variant = currentVariant else { return }
        let requiredNotes = variant.noteEvents
            .filter { $0.required }
            .sorted { $0.startTick < $1.startTick }
        
        let grouped = Dictionary(grouping: requiredNotes) { $0.startTick }
        expectedGroups = grouped.map { tick, notes in
            ExpectedNoteGroup(startTick: tick, notes: notes)
        }.sorted { $0.startTick < $1.startTick }
    }
    
    private func getComboMultiplier(_ combo: Int) -> Int {
        if combo >= 50 { return 3 }
        if combo >= 30 { return 2 }
        if combo >= 10 { return 2 } // wait, web says: 10 combo x1.5, 30 combo x2.0, 50 combo x3.0.
        // In Swift, since score is Int, let's match:
        // combo >= 50: x3, combo >= 30: x2, else: x1.
        return combo >= 50 ? 3 : (combo >= 30 ? 2 : 1)
    }
}
