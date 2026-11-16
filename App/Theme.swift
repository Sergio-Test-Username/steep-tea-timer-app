import SwiftUI
import UIKit

enum Theme {
    static let accent = Color(red: 0.12, green: 0.62, blue: 0.48)

    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { (traits: UITraitCollection) -> UIColor in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    static let bgTop = dynamic(
        light: UIColor(red: 0.90, green: 0.97, blue: 0.93, alpha: 1),
        dark: UIColor(red: 0.07, green: 0.16, blue: 0.14, alpha: 1)
    )
    static let bgBottom = dynamic(
        light: UIColor(red: 0.98, green: 0.97, blue: 0.91, alpha: 1),
        dark: UIColor(red: 0.03, green: 0.07, blue: 0.07, alpha: 1)
    )
    static let card = dynamic(
        light: UIColor(white: 1.0, alpha: 0.75),
        dark: UIColor(white: 1.0, alpha: 0.08)
    )
}

struct ThemeBackground: View {
    var tint: Color? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
            if let tint = tint {
                RadialGradient(
                    colors: [tint.opacity(0.28), Color.clear],
                    center: .top,
                    startRadius: 20,
                    endRadius: 420
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}

struct RoundIconButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(width: 44, height: 44)
                .background(Color.primary.opacity(0.08), in: Circle())
        }
        .buttonStyle(.plain)
    }
}
