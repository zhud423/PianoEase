import SwiftUI

struct MIDIConnectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var midiManager: MIDIManager
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("当前状态")) {
                    HStack {
                        Text("连接状态")
                        Spacer()
                        Text(midiManager.connectionStatus.label)
                            .foregroundColor(statusColor)
                    }
                    
                    if let connectedName = midiManager.connectedDeviceName {
                        HStack {
                            Text("已连接设备")
                            Spacer()
                            Text(connectedName)
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }
                        
                        Button(role: .destructive, action: { midiManager.disconnect() }) {
                            Text("断开连接")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Section(header: Text("可用 MIDI 设备 (\(midiManager.availableDevices.count))")) {
                    if midiManager.availableDevices.isEmpty {
                        Text("未检测到设备，请使用 USB 或者是蓝牙连接电钢琴")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(midiManager.availableDevices) { device in
                            Button(action: { midiManager.connect(to: device) }) {
                                HStack {
                                    Text(device.name)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    Spacer()
                                    if midiManager.connectedDeviceName == device.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("MIDI 设备管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var statusColor: Color {
        switch midiManager.connectionStatus {
        case .connected:
            return AppTheme.Colors.judgeGood
        case .connecting:
            return AppTheme.Colors.judgePerfect
        default:
            return AppTheme.Colors.textSecondary
        }
    }
}
