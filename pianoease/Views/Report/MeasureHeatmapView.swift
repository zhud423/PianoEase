import SwiftUI

struct MeasureHeatmapView: View {
    let heatValues: [Int]
    let maxMissValue: Int
    
    // Grid layout for measure blocks
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 8)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("错音小节分布热力图")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if heatValues.isEmpty {
                Text("暂无数据")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<heatValues.count, id: \.self) { idx in
                        let missCount = heatValues[idx]
                        VStack(spacing: 4) {
                            Text("\(idx + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(textColor(for: missCount))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color(for: missCount))
                                .frame(height: 30)
                                .overlay(
                                    Text("\(missCount)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(textColor(for: missCount))
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func color(for missCount: Int) -> Color {
        if missCount == 0 {
            return Color(hex: "#f4f4f5") // zinc-100 (light gray)
        }
        
        let ratio = CGFloat(missCount) / CGFloat(max(1, maxMissValue))
        // Interpolate between light rose and deep rose/red
        return AppTheme.Colors.levelChallenge.opacity(Double(0.2 + 0.8 * ratio))
    }
    
    private func textColor(for missCount: Int) -> Color {
        if missCount == 0 {
            return AppTheme.Colors.textSecondary
        }
        return .white
    }
}

#Preview {
    MeasureHeatmapView(heatValues: [0, 1, 3, 0, 5, 2, 0, 0, 1, 0], maxMissValue: 5)
        .frame(width: 350)
}
