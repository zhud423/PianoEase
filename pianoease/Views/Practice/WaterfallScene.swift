import SpriteKit
import SwiftUI

class WaterfallScene: SKScene {
    // Reference to practice engine to read note locations
    var engine: PracticeEngine?
    
    // Layout parameters
    private let judgmentLineY: CGFloat = 80
    private let tickHeightScale: CGFloat = 0.25 // points per tick
    private let keyboardHeight: CGFloat = 60
    private let midiStart = 36 // C2
    private let midiEnd = 96   // C7 (61 keys)
    private let whiteKeysCount = 36
    
    // Key offsets inside an octave (0-11) to map to white key index (0-6)
    private let whiteKeyOffsets = [0: 0, 2: 1, 4: 2, 5: 3, 7: 4, 9: 5, 11: 6]
    private let blackKeyOffsets = [1: 0.5, 3: 1.5, 6: 3.5, 8: 4.5, 10: 5.5]
    
    private var whiteKeyWidth: CGFloat = 0
    private var activeNoteNodes: [String: SKNode] = [:]
    private var keyboardNode = SKNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        whiteKeyWidth = size.width / CGFloat(whiteKeysCount)
        
        // Build virtual keyboard background
        setupKeyboard()
    }
    
    func updateNotes() {
        guard let engine = engine, let variant = engine.currentVariant else { return }
        
        let currentTick = engine.expectedGroups.safeGet(at: engine.currentGroupIndex)?.startTick ?? 0
        let visibleTickWindow = Int(size.height / tickHeightScale)
        
        // Remove completed notes or notes far away
        var nodesToRemove: [String] = []
        for (id, node) in activeNoteNodes {
            if !variant.noteEvents.contains(where: { $0.id == id }) {
                node.removeFromParent()
                nodesToRemove.append(id)
            }
        }
        nodesToRemove.forEach { activeNoteNodes.removeValue(forKey: $0) }
        
        // Render or update visible notes
        for note in variant.noteEvents {
            // Only draw notes in the current window
            let relativeTick = note.startTick - currentTick
            
            // Skip notes already played
            if note.startTick < currentTick && note.required {
                if let node = activeNoteNodes[note.id] {
                    node.removeFromParent()
                    activeNoteNodes.removeValue(forKey: note.id)
                }
                continue
            }
            
            if relativeTick > visibleTickWindow {
                continue
            }
            
            let noteX = getXPosition(for: note.midi)
            let noteY = judgmentLineY + CGFloat(relativeTick) * tickHeightScale
            let noteHeight = CGFloat(note.durationTick) * tickHeightScale
            let isWhite = isWhiteKey(note.midi)
            let noteWidth: CGFloat = isWhite ? (whiteKeyWidth * CGFloat(0.8)) : (whiteKeyWidth * CGFloat(0.5))
            
            if let node = activeNoteNodes[note.id] {
                // Update position
                node.position = CGPoint(x: noteX, y: noteY + (noteHeight / CGFloat(2.0)))
            } else {
                // Create new note block
                let xVal = -noteWidth / CGFloat(2.0)
                let yVal = -noteHeight / CGFloat(2.0)
                let rect = CGRect(x: xVal, y: yVal, width: noteWidth, height: noteHeight)
                let shape = SKShapeNode(rect: rect, cornerRadius: CGFloat(4.0))
                shape.fillColor = noteColor(for: note.hand)
                shape.strokeColor = UIColor.clear
                shape.position = CGPoint(x: noteX, y: noteY + (noteHeight / CGFloat(2.0)))
                
                addChild(shape)
                activeNoteNodes[note.id] = shape
            }
        }
        
        // Update virtual keys highlighting
        updateKeyboardHighlight()
    }
    
    private func getXPosition(for midi: Int) -> CGFloat {
        let normalized = midi - midiStart
        let octave = normalized / 12
        let pitchClass = normalized % 12
        
        var offset: CGFloat = 0
        if let whiteOffset = whiteKeyOffsets[pitchClass] {
            offset = CGFloat(whiteOffset)
        } else if let blackOffset = blackKeyOffsets[pitchClass] {
            offset = blackOffset
        }
        
        let whiteKeyIndex = CGFloat(octave * 7) + offset
        return whiteKeyIndex * whiteKeyWidth + whiteKeyWidth / 2
    }
    
    private func isWhiteKey(_ midi: Int) -> Bool {
        let pitchClass = (midi - midiStart) % 12
        return whiteKeyOffsets[pitchClass] != nil
    }
    
    private func noteColor(for hand: Hand) -> UIColor {
        hand == .left ? UIColor(AppTheme.Colors.noteLeft) : UIColor(AppTheme.Colors.noteRight)
    }
    
    private func setupKeyboard() {
        addChild(keyboardNode)
        
        // Background
        let bg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: keyboardHeight))
        bg.fillColor = UIColor(AppTheme.Colors.surface)
        bg.strokeColor = UIColor(AppTheme.Colors.border)
        keyboardNode.addChild(bg)
        
        // Render White Keys
        for i in 0..<whiteKeysCount {
            let key = SKShapeNode(rect: CGRect(x: CGFloat(i) * whiteKeyWidth, y: 0, width: whiteKeyWidth, height: keyboardHeight))
            key.fillColor = .white
            key.strokeColor = UIColor(AppTheme.Colors.border)
            key.name = "white_\(i)"
            keyboardNode.addChild(key)
        }
        
        // Render Black Keys (on top)
        for i in 0..<whiteKeysCount {
            // C#, D#, F#, G#, A#
            let pitchClass = (i % 7)
            let isBlackKeyRightOfThis = [0, 1, 3, 4, 5].contains(pitchClass) && i != whiteKeysCount - 1
            
            if isBlackKeyRightOfThis {
                let x = CGFloat(i) * whiteKeyWidth + whiteKeyWidth * 0.75
                let w = whiteKeyWidth * 0.5
                let h = keyboardHeight * 0.65
                let key = SKShapeNode(rect: CGRect(x: x, y: keyboardHeight - h, width: w, height: h), cornerRadius: 1.5)
                key.fillColor = .black
                key.strokeColor = .clear
                key.name = "black_\(i)"
                keyboardNode.addChild(key)
            }
        }
        
        // Draw judgment line
        let judgeLine = SKShapeNode(rect: CGRect(x: 0, y: judgmentLineY - 1, width: size.width, height: 2))
        judgeLine.fillColor = UIColor(AppTheme.Colors.primary.opacity(0.8))
        judgeLine.strokeColor = .clear
        addChild(judgeLine)
    }
    
    private func updateKeyboardHighlight() {
        // Clear previous highlights by resetting fill colors
        // Note: For simplicity of performance in simulation, we can just change node opacity or redraw.
        // We'll fully detail key highlights in subsequent practice test validations.
    }
}

// Helper Array Extension for safe lookup
extension Array {
    func safeGet(at index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
