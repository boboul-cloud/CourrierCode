import SwiftUI

// MARK: - Couleurs du thème
struct AppColors {
    // Couleurs principales
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [Color(hex: "f2994a"), Color(hex: "f2c94c")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let dangerGradient = LinearGradient(
        colors: [Color(hex: "eb3349"), Color(hex: "f45c43")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleGradient = LinearGradient(
        colors: [Color(hex: "a855f7"), Color(hex: "6366f1")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let darkCard = Color(hex: "1a1a2e")
    static let cardBackground = Color(hex: "16213e")
    static let surfaceColor = Color(.systemGray6)
    
    // Couleurs sémantiques
    static let encode = Color(hex: "38ef7d")
    static let decode = Color(hex: "667eea")
    static let secret = Color(hex: "f2994a")
    static let random = Color(hex: "a855f7")
}

// MARK: - Extension Color pour hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - Composants de design réutilisables

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}

struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    
    init(gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
    }
}

struct GradientButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    var fullWidth: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                Capsule()
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
            )
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            IconBadge(icon: icon, color: color, size: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var accentColor: Color = .blue
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(text.isEmpty ? .secondary : accentColor)
                    .frame(width: 24)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(text.isEmpty ? Color.clear : accentColor.opacity(0.5), lineWidth: 2)
                )
        )
    }
}

struct ModernTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100
    var accentColor: Color = .blue
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
            }
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(12)
        }
        .frame(minHeight: minHeight)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(text.isEmpty ? Color.clear : accentColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct AnimatedCopyButton: View {
    let action: () -> Void
    @State private var isCopied = false
    var color: Color = .green
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isCopied = false
                }
            }
        }) {
            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isCopied ? Color.green.gradient : color.gradient)
                )
                .scaleEffect(isCopied ? 1.1 : 1.0)
        }
    }
}

// MARK: - Header avec dégradé
struct GradientHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(AppColors.primaryGradient)
    }
}

// MARK: - Indicateur de statut
struct StatusPill: View {
    let text: String
    let icon: String
    let color: Color
    var isActive: Bool = true
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(isActive ? color : .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isActive ? color.opacity(0.15) : Color.gray.opacity(0.1))
        )
    }
}
