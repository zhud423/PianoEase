import SwiftUI

struct MIDIStatusIndicator: View {
    @Bindable var midiManager: MIDIManager
    @State private var showingConnectionSheet = false
    
    var body: some View {
        Button(action: { showingConnectionSheet.toggle() }) {
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(statusText)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingConnectionSheet) {
            MIDIConnectionSheet(midiManager: midiManager)
        }
    }
    
    private var statusColor: Color {
        switch midiManager.connectionStatus {
        case .connected:
            return AppTheme.Colors.judgeGood // Green
        case .connecting:
            return AppTheme.Colors.judgePerfect // Yellow/Orange
        case .disconnected:
            return AppTheme.Colors.judgeMiss // Red
        case .error:
            return AppTheme.Colors.judgeMiss // Red
        }
    }
    
    private var statusText: String {
        switch midiManager.connectionStatus {
        case .connected:
            return midiManager.connectedDeviceName ?? "已连接"
        case .connecting:
            return "连接中…"
        case .disconnected:
            return "未连接"
        case .error:
            return "连接出错"
        }
    }
}
