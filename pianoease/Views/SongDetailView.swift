import SwiftUI

struct SongDetailView: View {
    let song: Song
    
    @State private var selectedVariantId: ChartVariantId = .lv1
    @State private var chart: SongChart? = nil
    @State private var parser = ChartParser()
    @State private var errorText: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Details Panel
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("曲目准备")
                            .font(AppTheme.Typography.overline)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .tracking(2)
                        
                        Text(song.title)
                            .font(AppTheme.Typography.largeTitle)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("\(song.subtitle)  ·  BPM \(song.bpm)  ·  \(song.durationLabel)")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if let chart = chart {
                            NavigationLink(destination: PracticeView(song: song, chart: chart)) {
                                Text("开始练习")
                                    .font(AppTheme.Typography.body.weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(AppTheme.CornerRadius.md)
                            }
                        } else {
                            Text("开始练习")
                                .font(AppTheme.Typography.body.weight(.semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(AppTheme.Colors.primary.opacity(0.5))
                                .cornerRadius(AppTheme.CornerRadius.md)
                        }
                        
                        NavigationLink(destination: PracticeHistoryView(song: song)) {
                            Text("单曲复盘")
                                .font(AppTheme.Typography.body.weight(.semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(AppTheme.Colors.surface)
                                .cornerRadius(AppTheme.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .cardStyle()
                
                // Variant / Level selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("左手伴奏难度选择")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Picker("左手难度", selection: $selectedVariantId) {
                        ForEach(ChartVariantId.allCases, id: \.self) { variant in
                            Text(variant.label).tag(variant)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Simple description of selected level
                    Text(variantDescription)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, 4)
                }
                .padding(AppTheme.Spacing.md)
                .cardStyle()
                
                // Jianpu Sheet Music Preview
                VStack(alignment: .leading, spacing: 15) {
                    Text("简谱预览")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if let chart {
                        JianpuView(chart: chart, variantId: selectedVariantId)
                            .frame(height: 220)
                    } else if let error = errorText {
                        HStack {
                            Spacer()
                            Text(error)
                                .foregroundColor(AppTheme.Colors.judgeMiss)
                                .font(AppTheme.Typography.body)
                            Spacer()
                        }
                        .frame(height: 220)
                        .cardStyle()
                    } else {
                        HStack {
                            Spacer()
                            ProgressView("正在加载曲谱数据...")
                            Spacer()
                        }
                        .frame(height: 220)
                        .cardStyle()
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(song.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadChart()
        }
    }
    
    private func loadChart() {
        if let loadedChart = parser.findChart(bySongId: song.id) {
            self.chart = loadedChart
        } else {
            self.errorText = "未能加载曲谱数据，请检查文件是否存在。"
        }
    }
    
    private var variantDescription: String {
        switch selectedVariantId {
        case .original:
            return "原谱：原版伴奏，包含完整的左手低音和分解和音（难度较高）。"
        case .lv1:
            return "Lv1 根音：最简化版本，每个和弦只在第1拍弹一个低音根音并保持（适合零基础入门）。"
        case .lv2:
            return "Lv2 柱式：进阶版本，第1拍弹低音根音，第3拍同时按下和声柱式和弦（锻炼双手配合）。"
        case .lv3:
            return "Lv3 分解：简化分解版本，左手弹奏有规律的流动分解和音，丰富音乐表现力（适合有基础的学员）。"
        }
    }
}

#Preview {
    let mockSong = Song(
        id: "friendship-years",
        title: "友情岁月",
        subtitle: "Young and Dangerous",
        bpm: 74,
        durationLabel: "02:15",
        level: .beginner
    )
    NavigationStack {
        SongDetailView(song: mockSong)
    }
}
