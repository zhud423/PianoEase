import SwiftUI

struct JianpuView: View {
    let chart: SongChart
    let variantId: ChartVariantId
    var followMeasureIndex: Int? = nil
    
    @State private var measureLayouts: [JianpuMeasureLayout] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    // System bracket
                    JianpuSystemBracket()
                        .frame(width: 30)
                    
                    ForEach(measureLayouts) { layout in
                        JianpuMeasureView(
                            layout: layout,
                            timeSignature: chart.timeSignature,
                            isHighlighted: followMeasureIndex == layout.measureIndex,
                            isLast: layout.measureIndex == measureLayouts.count - 1
                        )
                        .frame(width: 240, height: 200)
                        .id(layout.measureIndex)
                    }
                }
                .padding(.vertical, 10)
                .onChange(of: followMeasureIndex) { _, newIndex in
                    if let newIndex {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .onAppear {
            loadLayout()
        }
        .onChange(of: variantId) {
            loadLayout()
        }
    }
    
    private func loadLayout() {
        measureLayouts = JianpuRenderer.buildLayout(chart: chart, variantId: variantId)
    }
}

// MARK: - Bracket helper for jianpu sheet
struct JianpuSystemBracket: View {
    var body: some View {
        Canvas { context, size in
            let path = Path { p in
                p.move(to: CGPoint(x: size.width - 5, y: 35))
                p.addLine(to: CGPoint(x: size.width - 15, y: 35))
                p.addLine(to: CGPoint(x: size.width - 15, y: 155))
                p.addLine(to: CGPoint(x: size.width - 5, y: 155))
            }
            context.stroke(path, with: .color(AppTheme.Colors.textPrimary), lineWidth: 2)
            
            // Draw Right / Left indicators
            context.draw(
                Text("右").font(AppTheme.Typography.caption).foregroundColor(AppTheme.Colors.textSecondary),
                at: CGPoint(x: 10, y: 80)
            )
            context.draw(
                Text("左").font(AppTheme.Typography.caption).foregroundColor(AppTheme.Colors.textSecondary),
                at: CGPoint(x: 10, y: 130)
            )
        }
    }
}

// MARK: - Single Measure rendering
struct JianpuMeasureView: View {
    let layout: JianpuMeasureLayout
    let timeSignature: [Int]
    let isHighlighted: Bool
    let isLast: Bool
    
    var body: some View {
        Canvas { context, size in
            let beatsCount = timeSignature.first ?? 4
            let margin: CGFloat = 15
            let contentWidth = size.width - margin
            let beatWidth = contentWidth / CGFloat(beatsCount)
            
            // Highlight background if selected
            if isHighlighted {
                let rect = CGRect(origin: .zero, size: size)
                context.fill(Path(rect), with: .color(AppTheme.Colors.primaryLight.opacity(0.4)))
            }
            
            // Small index label
            let indexText = Text("\(layout.measureIndex + 1)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.Colors.textTertiary)
            context.draw(indexText, at: CGPoint(x: 15, y: 12))
            
            // Render Chord symbols
            for chord in layout.chords {
                let beatOffset = Double(chord.startTick) / 480.0 // Assuming 480 ppq
                let chordX = margin + CGFloat(beatOffset) * beatWidth
                let chordText = Text(chord.symbol)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.primaryText)
                context.draw(chordText, at: CGPoint(x: chordX, y: 25))
            }
            
            // Render Right Hand Notes
            drawNoteGroups(layout.rightNotes, context: context, y: 80, beatWidth: beatWidth, margin: margin, beatsCount: beatsCount)
            
            // Render Left Hand Notes
            drawNoteGroups(layout.leftNotes, context: context, y: 135, beatWidth: beatWidth, margin: margin, beatsCount: beatsCount)
            
            // Draw boundary lines
            if isLast {
                // Double bar line
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: size.width - 5, y: 35))
                    p.addLine(to: CGPoint(x: size.width - 5, y: 155))
                }, with: .color(AppTheme.Colors.textPrimary), lineWidth: 1)
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: size.width - 2, y: 35))
                    p.addLine(to: CGPoint(x: size.width - 2, y: 155))
                }, with: .color(AppTheme.Colors.textPrimary), lineWidth: 3)
            } else {
                // Regular bar line
                let linePath = Path { p in
                    p.move(to: CGPoint(x: size.width, y: 35))
                    p.addLine(to: CGPoint(x: size.width, y: 155))
                }
                context.stroke(linePath, with: .color(AppTheme.Colors.border), lineWidth: 1)
            }
        }
    }
    
    private func drawNoteGroups(
        _ groups: [JianpuMeasureLayout.NoteGroup],
        context: GraphicsContext,
        y: CGFloat,
        beatWidth: CGFloat,
        margin: CGFloat,
        beatsCount: Int
    ) {
        for group in groups {
            let startX = margin + CGFloat(group.startBeat) * beatWidth
            
            // If the note group contains multiple notes (stacked vertically)
            let noteCount = group.notes.count
            
            for (idx, note) in group.notes.enumerated() {
                // Adjust Y for stacked chords
                let noteYOffset = CGFloat(idx - (noteCount - 1) / 2) * -16
                let noteY = y + noteYOffset
                
                // Draw Note Number
                let text = Text(note.number)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(note.hand == .left ? AppTheme.Colors.noteLeft : AppTheme.Colors.textPrimary)
                
                context.draw(text, at: CGPoint(x: startX, y: noteY))
                
                // Draw Accidental
                if !note.accidental.isEmpty {
                    let accText = Text(note.accidental)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    context.draw(accText, at: CGPoint(x: startX - 10, y: noteY - 2))
                }
                
                // Draw Octave Dots above
                if note.octave > 0 {
                    for i in 0..<note.octave {
                        let dotY = noteY - 14 - CGFloat(i * 5)
                        context.fill(
                            Path(ellipseIn: CGRect(x: startX - 2, y: dotY, width: 3, height: 3)),
                            with: .color(AppTheme.Colors.textPrimary)
                        )
                    }
                }
                
                // Draw Octave Dots below
                if note.octave < 0 {
                    let absoluteOctave = abs(note.octave)
                    for i in 0..<absoluteOctave {
                        let dotY = noteY + 12 + CGFloat(i * 5)
                        context.fill(
                            Path(ellipseIn: CGRect(x: startX - 2, y: dotY, width: 3, height: 3)),
                            with: .color(AppTheme.Colors.textPrimary)
                        )
                    }
                }
                
                // Underline decoration for short notes
                if note.durationBeats < 1.0 {
                    // Underline 1 (eighth notes)
                    context.stroke(Path { p in
                        p.move(to: CGPoint(x: startX - 8, y: noteY + 10))
                        p.addLine(to: CGPoint(x: startX + 8, y: noteY + 10))
                    }, with: .color(AppTheme.Colors.textPrimary), lineWidth: 1.5)
                }
                if note.durationBeats <= 0.25 {
                    // Underline 2 (sixteenth notes)
                    context.stroke(Path { p in
                        p.move(to: CGPoint(x: startX - 8, y: noteY + 13))
                        p.addLine(to: CGPoint(x: startX + 8, y: noteY + 13))
                    }, with: .color(AppTheme.Colors.textPrimary), lineWidth: 1.5)
                }
                
                // Extension dashes for long notes
                if note.durationBeats > 1.1 {
                    let remainingBeats = Int(floor(note.durationBeats))
                    for i in 1..<remainingBeats {
                        if group.startBeat + Double(i) < Double(beatsCount) {
                            let dashX = startX + CGFloat(i) * beatWidth
                            let dashText = Text("-")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            context.draw(dashText, at: CGPoint(x: dashX, y: noteY))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let mockNotes = [
        NoteEvent(id: "1", hand: .right, midi: 60, pitchName: "C4", startTick: 0, durationTick: 480, measureIndex: 0, beatInMeasure: 1, voice: nil, required: true, optional: false, chordSymbol: "C"),
        NoteEvent(id: "2", hand: .right, midi: 64, pitchName: "E4", startTick: 480, durationTick: 480, measureIndex: 0, beatInMeasure: 2, voice: nil, required: true, optional: false, chordSymbol: "C"),
        NoteEvent(id: "3", hand: .right, midi: 67, pitchName: "G4", startTick: 960, durationTick: 480, measureIndex: 0, beatInMeasure: 3, voice: nil, required: true, optional: false, chordSymbol: "C"),
        NoteEvent(id: "4", hand: .right, midi: 72, pitchName: "C5", startTick: 1440, durationTick: 480, measureIndex: 0, beatInMeasure: 4, voice: nil, required: true, optional: false, chordSymbol: "C"),
        NoteEvent(id: "5", hand: .left, midi: 48, pitchName: "C3", startTick: 0, durationTick: 1920, measureIndex: 0, beatInMeasure: 1, voice: nil, required: true, optional: false, chordSymbol: "C")
    ]
    let mockChart = SongChart(
        songId: "test",
        title: "测试曲目",
        bpm: 80,
        ppq: 480,
        timeSignature: [4, 4],
        keySignature: "C Major",
        variants: [
            ChartVariant(id: .lv1, label: "Lv1 根音", measures: [Measure(index: 0, startTick: 0, endTick: 1920)], noteEvents: mockNotes, chordSegments: [ChordSegment(measureIndex: 0, startTick: 0, endTick: 1920, symbol: "C", leftHandPattern: nil)])
        ]
    )
    JianpuView(chart: mockChart, variantId: .lv1)
}
