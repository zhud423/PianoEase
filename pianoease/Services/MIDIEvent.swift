import Foundation

/// MIDI event and connection types.
/// Aligned with web version: lib/midi/events.ts

// MARK: - Connection Status

enum MIDIConnectionStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var label: String {
        switch self {
        case .disconnected: return "未连接"
        case .connecting: return "连接中…"
        case .connected: return "已连接"
        case .error(let msg): return "错误: \(msg)"
        }
    }
}

// MARK: - Device Info

struct MIDIDeviceInfo: Identifiable, Hashable {
    let id: Int
    let name: String
    let sourceIndex: Int
}

// MARK: - Note Event

enum MIDIEventType {
    case noteOn
    case noteOff
}

struct MIDINoteEvent {
    let type: MIDIEventType
    let note: Int           // MIDI note number 0-127
    let velocity: Int       // 0-127
    let timestamp: TimeInterval
}
