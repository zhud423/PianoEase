import Foundation
import CoreMIDI

/// CoreMIDI manager for iPad.
/// Auto-discovers USB and Bluetooth MIDI devices.
@Observable
final class MIDIManager {
    private(set) var connectionStatus: MIDIConnectionStatus = .disconnected
    private(set) var connectedDeviceName: String?
    private(set) var availableDevices: [MIDIDeviceInfo] = []

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()

    /// Callback for MIDI note events
    var onNoteEvent: ((MIDINoteEvent) -> Void)?

    init() {
        setupMIDI()
    }

    deinit {
        MIDIClientDispose(midiClient)
    }

    func connect(to device: MIDIDeviceInfo) {
        let source = MIDIGetSource(device.sourceIndex)
        let status = MIDIPortConnectSource(inputPort, source, nil)
        if status == noErr {
            connectionStatus = .connected
            connectedDeviceName = device.name
        } else {
            connectionStatus = .error("连接失败: \(status)")
        }
    }

    func disconnect() {
        connectionStatus = .disconnected
        connectedDeviceName = nil
    }

    // MARK: - Setup

    private func setupMIDI() {
        connectionStatus = .connecting

        let status = MIDIClientCreateWithBlock(
            "PianoEase" as CFString,
            &midiClient
        ) { [weak self] notification in
            self?.handleMIDINotification(notification)
        }

        guard status == noErr else {
            connectionStatus = .error("Failed to create MIDI client: \(status)")
            return
        }

        MIDIInputPortCreateWithProtocol(
            midiClient,
            "Input" as CFString,
            ._1_0,
            &inputPort
        ) { [weak self] eventList, _ in
            self?.handleMIDIEventList(eventList)
        }

        if case .connecting = connectionStatus {
            connectionStatus = .disconnected
        }
        refreshDeviceList()
    }

    private func refreshDeviceList() {
        let sourceCount = MIDIGetNumberOfSources()
        var devices: [MIDIDeviceInfo] = []
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &name)
            let displayName = (name?.takeRetainedValue() as String?) ?? "Unknown Device"
            devices.append(MIDIDeviceInfo(id: Int(source), name: displayName, sourceIndex: i))
        }
        DispatchQueue.main.async {
            self.availableDevices = devices
            self.autoConnectIfPossible()
        }
    }

    private func autoConnectIfPossible() {
        if connectionStatus != .connected && !availableDevices.isEmpty {
            if let firstDevice = availableDevices.first {
                print("[MIDIManager] Auto-connecting to: \(firstDevice.name)")
                connect(to: firstDevice)
            }
        }
    }

    // MARK: - Event Handling

    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        if notification.pointee.messageID == .msgSetupChanged {
            DispatchQueue.main.async { [weak self] in
                self?.refreshDeviceList()
            }
        }
    }

    private func handleMIDIEventList(_ eventList: UnsafePointer<MIDIEventList>) {
        let timestamp = Date().timeIntervalSince1970
        let numPackets = eventList.pointee.numPackets
        guard numPackets > 0 else { return }
        
        let packetHeadPtr = UnsafeRawPointer(eventList).advanced(by: MemoryLayout<UInt32>.size).assumingMemoryBound(to: MIDIEventPacket.self)
        var packetPtr = UnsafeMutablePointer(mutating: packetHeadPtr)
        
        for _ in 0..<numPackets {
            let packet = packetPtr.pointee
            let wordCount = packet.wordCount
            
            withUnsafePointer(to: packet.words) { tuplePtr in
                tuplePtr.withMemoryRebound(to: UInt32.self, capacity: Int(wordCount)) { words in
                    for w in 0..<Int(wordCount) {
                        let word = words[w]
                        // Parse MIDI 1.0 Voice Message (Message Type = 2) in UMP
                        let messageType = (word >> 28) & 0x0F
                        if messageType == 0x2 {
                            let status = (word >> 16) & 0xF0
                            let note = Int((word >> 8) & 0x7F)
                            let velocity = Int(word & 0x7F)
                            
                            var event: MIDINoteEvent? = nil
                            if status == 0x90 && velocity > 0 {
                                event = MIDINoteEvent(type: .noteOn, note: note, velocity: velocity, timestamp: timestamp)
                            } else if status == 0x80 || (status == 0x90 && velocity == 0) {
                                event = MIDINoteEvent(type: .noteOff, note: note, velocity: 0, timestamp: timestamp)
                            }
                            
                            if let event = event {
                                DispatchQueue.main.async { [weak self] in
                                    self?.onNoteEvent?(event)
                                }
                            }
                        }
                    }
                }
            }
            packetPtr = MIDIEventPacketNext(packetPtr)
        }
    }
}
