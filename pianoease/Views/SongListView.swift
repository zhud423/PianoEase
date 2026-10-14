import SwiftUI

struct SongListView: View {
    @State private var catalog = SongCatalog()
    @State private var searchText = ""
    @Environment(MIDIManager.self) private var midiManager
    
    // Grid columns layout for iPad screen
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header card, matching web design
                VStack(alignment: .leading, spacing: 10) {
                    Text("PIANOEASE LIBRARY")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .tracking(2)
                    
                    Text("分级简化曲库")
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("当前默认首页仅保留曲库入口。选择曲目后进入分级简化练习，并可查看该曲的单曲练习复盘。")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        
                        TextField("搜索曲名 / 副标题 / ID", text: $searchText)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .autocorrectionDisabled()
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.background)
                    .cornerRadius(AppTheme.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                    .padding(.top, 10)
                }
                .padding(AppTheme.Spacing.lg)
                .cardStyle()
                
                // Song Grid
                let filteredSongs = catalog.search(query: searchText)
                if filteredSongs.isEmpty {
                    VStack {
                        Text("没有匹配到曲目，请尝试其他关键词。")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(.vertical, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle()
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredSongs) { song in
                            NavigationLink(destination: SongDetailView(song: song)) {
                                SongCardView(song: song)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("首页")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MIDIStatusIndicator(midiManager: midiManager)
            }
        }
    }
}

// MARK: - Song Card
struct SongCardView: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(song.subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Level Badge
                Text(song.level.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelBgColor)
                    .foregroundColor(levelTextColor)
                    .cornerRadius(8)
            }
            
            Divider()
                .background(AppTheme.Colors.border)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BPM")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Text("\(song.bpm)")
                        .font(AppTheme.Typography.body.weight(.semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("时长")
                        .font(AppTheme.Typography.overline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Text(song.durationLabel)
                        .font(AppTheme.Typography.body.weight(.semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            
            // Practice Action Link Indicator
            HStack {
                Spacer()
                Text("查看详情 →")
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }
            .padding(.top, 5)
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
    
    private var levelTextColor: Color {
        switch song.level {
        case .beginner: return AppTheme.Colors.levelBeginner
        case .intermediate: return AppTheme.Colors.levelIntermediate
        case .challenge: return AppTheme.Colors.levelChallenge
        }
    }
    
    private var levelBgColor: Color {
        switch song.level {
        case .beginner: return AppTheme.Colors.levelBeginnerBg
        case .intermediate: return AppTheme.Colors.levelIntermediateBg
        case .challenge: return AppTheme.Colors.levelChallengeBg
        }
    }
}

#Preview {
    NavigationStack {
        SongListView()
    }
}
