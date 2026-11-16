import SwiftUI

struct ContentView: View {
    @AppStorage("infusionsSteeped") private var steeped: Int = 0

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Tea.all) { tea in
                            NavigationLink(value: tea) {
                                TeaCard(tea: tea)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .background(ThemeBackground())
            .navigationTitle("Steep")
            .navigationDestination(for: Tea.self) { (tea: Tea) in
                TimerView(tea: tea)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    LinearGradient(colors: [Color(red: 0.37, green: 0.85, blue: 0.64), Theme.accent],
                                   startPoint: .top, endPoint: .bottom),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("Pick your leaf")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text(steeped == 0 ? "Perfect temperature and time, every cup." : "\(steeped) infusions steeped so far")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .card()
    }
}

struct TeaCard: View {
    let tea: Tea

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: tea.symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(colors: [tea.color.opacity(0.75), tea.color],
                                   startPoint: .top, endPoint: .bottom),
                    in: Circle()
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(tea.name)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("\(tea.tempC)°C · \(Tea.format(tea.baseSeconds))")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}
