import SwiftUI

/// PianoEase design system — aligned with web version's emerald + zinc palette.
enum AppTheme {
    // MARK: - Colors (aligned with Tailwind emerald + zinc)
    enum Colors {
        static let primary = Color(hex: "#059669")       // emerald-600
        static let primaryLight = Color(hex: "#d1fae5")  // emerald-100
        static let primaryDark = Color(hex: "#064e3b")   // emerald-900
        static let primaryText = Color(hex: "#047857")   // emerald-700
        
        static let surface = Color.white
        static let background = Color(hex: "#f3f6f4")
        static let border = Color(hex: "#e4e4e7")       // zinc-200
        static let textPrimary = Color(hex: "#18181b")   // zinc-900
        static let textSecondary = Color(hex: "#52525b") // zinc-600
        static let textTertiary = Color(hex: "#71717a")  // zinc-500
        
        // Difficulty level colors
        static let levelBeginner = Color(hex: "#059669")      // emerald
        static let levelBeginnerBg = Color(hex: "#d1fae5")
        static let levelIntermediate = Color(hex: "#d97706")  // amber
        static let levelIntermediateBg = Color(hex: "#fef3c7")
        static let levelChallenge = Color(hex: "#e11d48")     // rose
        static let levelChallengeBg = Color(hex: "#ffe4e6")
        
        // Waterfall note colors
        static let noteLeft = Color(hex: "#3b82f6")   // blue
        static let noteRight = Color(hex: "#22c55e")  // green
        
        // Judgement colors
        static let judgePerfect = Color(hex: "#facc15")  // yellow
        static let judgeGood = Color(hex: "#22c55e")     // green
        static let judgeMiss = Color(hex: "#ef4444")      // red
    }
    
    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.system(size: 32, weight: .semibold, design: .rounded)
        static let title = Font.system(size: 24, weight: .semibold)
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 15)
        static let caption = Font.system(size: 12)
        static let overline = Font.system(size: 11, weight: .medium)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Card Style ViewModifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
