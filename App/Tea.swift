import SwiftUI

struct Tea: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let tempC: Int
    let baseSeconds: Int
    let increment: Int
    let maxInfusions: Int
    let hue: Double
    let note: String

    var color: Color {
        Color(hue: hue, saturation: 0.65, brightness: 0.68)
    }

    static let all: [Tea] = [
        Tea(id: "green", name: "Green", symbol: "leaf.fill", tempC: 80, baseSeconds: 120,
            increment: 20, maxInfusions: 3, hue: 0.38,
            note: "Use cooler water to avoid bitterness. Pull the leaves as soon as the timer ends."),
        Tea(id: "white", name: "White", symbol: "sparkles", tempC: 85, baseSeconds: 150,
            increment: 30, maxInfusions: 4, hue: 0.14,
            note: "Delicate and sweet. Longer, gentler steeps bring out the honeyed notes."),
        Tea(id: "oolong", name: "Oolong", symbol: "wind", tempC: 95, baseSeconds: 45,
            increment: 15, maxInfusions: 6, hue: 0.07,
            note: "Rinse the leaves first. Short steeps, many infusions. The flavor opens up each round."),
        Tea(id: "black", name: "Black", symbol: "flame.fill", tempC: 95, baseSeconds: 180,
            increment: 30, maxInfusions: 3, hue: 0.02,
            note: "Bold and malty. Go past four minutes and it turns astringent."),
        Tea(id: "puerh", name: "Pu-erh", symbol: "mountain.2.fill", tempC: 100, baseSeconds: 20,
            increment: 10, maxInfusions: 8, hue: 0.95,
            note: "Boiling water, quick rinse, then very short steeps. Gets smoother with every infusion."),
        Tea(id: "herbal", name: "Herbal", symbol: "camera.macro", tempC: 100, baseSeconds: 300,
            increment: 60, maxInfusions: 2, hue: 0.78,
            note: "No caffeine, so steep it long. Cover the cup to keep the aromatics in.")
    ]

    static func format(_ seconds: Int) -> String {
        let s = max(0, seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
