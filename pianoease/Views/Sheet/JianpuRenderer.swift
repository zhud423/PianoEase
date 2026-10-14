import SwiftUI

/// Represent a rendered jianpu note in relative notation
struct JianpuNoteLayout: Identifiable {
    let id = UUID()
    let midi: Int
    let number: String       // "1", "2", "3", ... or "0" for rest
    let accidental: String   // "", "#", "b"
    let octave: Int          // relative octave offset
    let startBeat: Double    // beat position in measure (0-indexed)
    let durationBeats: Double
    let hand: Hand
}

struct JianpuMeasureLayout: Identifiable {
    let id = UUID()
    let measureIndex: Int
    let rightNotes: [NoteGroup]
    let leftNotes: [NoteGroup]
    let chords: [ChordSegment]
    
    struct NoteGroup: Identifiable {
        let id = UUID()
        let startBeat: Double
        let durationBeats: Double
        let notes: [JianpuNoteLayout] // sorted from low to high
    }
}

class JianpuRenderer {
    static func convertToJianpu(midi: Int, keySignature: String) -> (number: String, accidental: String, octave: Int) {
        let key = keySignature.lowercased()
        
        // Default major tonic is C (0)
        var majorTonic = 0
        
        if key.contains("c major") || key.contains("a minor") { majorTonic = 0 }
        else if key.contains("g major") || key.contains("e minor") { majorTonic = 7 }
        else if key.contains("d major") || key.contains("b minor") { majorTonic = 2 }
        else if key.contains("a major") || key.contains("f# minor") { majorTonic = 9 }
        else if key.contains("e major") || key.contains("c# minor") { majorTonic = 4 }
        else if key.contains("b major") || key.contains("g# minor") { majorTonic = 11 }
        else if key.contains("f# major") || key.contains("d# minor") { majorTonic = 6 }
        else if key.contains("f major") || key.contains("d minor") { majorTonic = 5 }
        else if key.contains("bb major") || key.contains("g minor") { majorTonic = 10 }
        else if key.contains("eb major") || key.contains("c minor") { majorTonic = 3 }
        else if key.contains("ab major") || key.contains("f minor") { majorTonic = 8 }
        else if key.contains("db major") || key.contains("bb minor") { majorTonic = 1 }
        else if key.contains("gb major") || key.contains("eb minor") { majorTonic = 6 }
        
        let relativePitch = (midi - majorTonic) % 12
        let normalizedRelativePitch = relativePitch >= 0 ? relativePitch : relativePitch + 12
        
        var number = "1"
        var accidental = ""
        
        switch normalizedRelativePitch {
        case 0: number = "1"; accidental = ""
        case 1: number = "1"; accidental = "#"
        case 2: number = "2"; accidental = ""
        case 3: number = "3"; accidental = "b" // Eb is b3
        case 4: number = "3"; accidental = ""
        case 5: number = "4"; accidental = ""
        case 6: number = "4"; accidental = "#"
        case 7: number = "5"; accidental = ""
        case 8: number = "6"; accidental = "b" // Ab is b6
        case 9: number = "6"; accidental = ""
        case 10: number = "7"; accidental = "b" // Bb is b7
        case 11: number = "7"; accidental = ""
        default: break
        }
        
        // Calculate octave relative to the middle octave (Tonic 4)
        // MIDI 60 is C4. Let's find the MIDI note of the majorTonic in octave 4.
        let baseMidi = 60 + majorTonic
        let octaveOffset = Int(floor(Double(midi - baseMidi) / 12.0))
        
        return (number, accidental, octaveOffset)
    }
    
    static func buildLayout(chart: SongChart, variantId: ChartVariantId) -> [JianpuMeasureLayout] {
        guard let variant = chart.variant(for: variantId) else { return [] }
        
        var layouts: [JianpuMeasureLayout] = []
        let ppq = Double(chart.ppq)
        
        for measure in variant.measures {
            let measureNotes = variant.noteEvents.filter { $0.measureIndex == measure.index }
            let measureChords = variant.chordSegments.filter { $0.measureIndex == measure.index }
            
            let rightHand = measureNotes.filter { $0.hand == .right }
            let leftHand = measureNotes.filter { $0.hand == .left }
            
            let rightGroups = groupNotesByBeat(rightHand, keySignature: chart.keySignature, ppq: ppq)
            let leftGroups = groupNotesByBeat(leftHand, keySignature: chart.keySignature, ppq: ppq)
            
            layouts.append(
                JianpuMeasureLayout(
                    measureIndex: measure.index,
                    rightNotes: rightGroups,
                    leftNotes: leftGroups,
                    chords: measureChords
                )
            )
        }
        
        return layouts
    }
    
    private static func groupNotesByBeat(_ events: [NoteEvent], keySignature: String, ppq: Double) -> [JianpuMeasureLayout.NoteGroup] {
        let grouped = Dictionary(grouping: events) { $0.startTick }
        var result: [JianpuMeasureLayout.NoteGroup] = []
        
        for (_, notesAtTick) in grouped {
            let startBeat = Double(notesAtTick.first?.beatInMeasure ?? 1.0) - 1.0 // Convert to 0-indexed beat
            let durationBeats = Double(notesAtTick.first?.durationTick ?? 0) / ppq
            
            let noteLayouts = notesAtTick.map { event in
                let jianpu = convertToJianpu(midi: event.midi, keySignature: keySignature)
                return JianpuNoteLayout(
                    midi: event.midi,
                    number: jianpu.number,
                    accidental: jianpu.accidental,
                    octave: jianpu.octave,
                    startBeat: startBeat,
                    durationBeats: durationBeats,
                    hand: event.hand
                )
            }.sorted { $0.midi < $1.midi }
            
            result.append(
                JianpuMeasureLayout.NoteGroup(
                    startBeat: startBeat,
                    durationBeats: durationBeats,
                    notes: noteLayouts
                )
            )
        }
        
        return result.sorted { $0.startBeat < $1.startBeat }
    }
}
