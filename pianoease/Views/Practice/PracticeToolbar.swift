import SwiftUI

struct PracticeToolbar: View {
    @Bindable var engine: PracticeEngine
    let chart: SongChart
    @Binding var selectedVariantId: ChartVariantId
    
    var body: some View {
        HStack(spacing: 20) {
            // Play/Pause Control
            Button(action: togglePlay) {
                HStack(spacing: 8) {
                    Image(systemName: engine.state == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(engine.state == .playing ? "暂停" : "开始")
                        .font(AppTheme.Typography.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(engine.state == .playing ? Color.orange : AppTheme.Colors.primary)
                .cornerRadius(AppTheme.CornerRadius.md)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Reset Button
            Button(action: { engine.reset() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("重置")
                        .font(AppTheme.Typography.body)
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Difficulty Selection Inside Toolbar (matches web flexibility)
            HStack(spacing: 10) {
                Text("难度:")
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                
                Picker("左手难度", selection: $selectedVariantId) {
                    ForEach(ChartVariantId.allCases, id: \.self) { variant in
                        Text(variant.label).tag(variant)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                .onChange(of: selectedVariantId) { _, newValue in
                    engine.configure(chart: chart, variantId: newValue)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
    
    private func togglePlay() {
        if engine.state == .playing {
            engine.pause()
        } else {
            engine.start()
        }
    }
}
