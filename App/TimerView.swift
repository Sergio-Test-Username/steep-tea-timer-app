import SwiftUI
import UIKit

struct TimerView: View {
    let tea: Tea
    @State private var timer: SteepTimer
    @AppStorage("infusionsSteeped") private var steeped: Int = 0

    init(tea: Tea) {
        self.tea = tea
        _timer = State(initialValue: SteepTimer(tea: tea))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                chips
                ring
                controls
                settingsCard
                noteCard
            }
            .padding(20)
        }
        .background(ThemeBackground(tint: tea.color))
        .navigationTitle(tea.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: timer.state) { _, newState in
            UIApplication.shared.isIdleTimerDisabled = (newState == .running)
            if newState == .done { steeped += 1 }
        }
        .sensoryFeedback(trigger: timer.state) { (_, new: TimerState) -> SensoryFeedback? in
            switch new {
            case .done: return .success
            case .running: return .impact
            default: return nil
            }
        }
        .onDisappear {
            timer.reset()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private var chips: some View {
        HStack(spacing: 10) {
            chip(symbol: "thermometer.medium", text: "\(tea.tempC)°C")
            chip(symbol: "drop.fill", text: "Infusion \(timer.infusion) of \(tea.maxInfusions)")
        }
    }

    private func chip(symbol: String, text: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tea.color.opacity(0.18), in: Capsule())
            .foregroundStyle(tea.color)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 18)
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    LinearGradient(colors: [tea.color.opacity(0.6), tea.color], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 6) {
                if timer.state == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(tea.color)
                        .transition(.scale.combined(with: .opacity))
                    Text("Ready")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                } else {
                    Text(Tea.format(Int(ceil(timer.remaining))))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text(statusText)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 270, height: 270)
        .padding(.vertical, 8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timer.state)
    }

    private var statusText: String {
        switch timer.state {
        case .idle: return "Ready to steep"
        case .running: return "Steeping"
        case .paused: return "Paused"
        case .done: return "Ready"
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(action: mainAction) {
                Label(mainTitle, systemImage: mainSymbol)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(tea.color, in: Capsule())
            }
            .buttonStyle(.plain)

            if timer.state != .idle {
                RoundIconButton(symbol: "arrow.counterclockwise") {
                    withAnimation(.spring) { timer.reset() }
                }
                .frame(width: 56, height: 56)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timer.state)
    }

    private var mainTitle: String {
        switch timer.state {
        case .idle: return "Start steeping"
        case .running: return "Pause"
        case .paused: return "Resume"
        case .done: return timer.isLastInfusion ? "Brew again" : "Next infusion"
        }
    }

    private var mainSymbol: String {
        switch timer.state {
        case .idle, .paused: return "play.fill"
        case .running: return "pause.fill"
        case .done: return timer.isLastInfusion ? "arrow.counterclockwise" : "forward.fill"
        }
    }

    private func mainAction() {
        withAnimation(.spring) {
            switch timer.state {
            case .idle, .paused: timer.start()
            case .running: timer.pause()
            case .done:
                if timer.isLastInfusion {
                    timer.restartCycle()
                } else {
                    timer.selectInfusion(timer.infusion + 1)
                }
            }
        }
    }

    private var settingsCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Infusion")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Spacer()
                RoundIconButton(symbol: "minus") { timer.selectInfusion(timer.infusion - 1) }
                Text("\(timer.infusion)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .frame(minWidth: 30)
                RoundIconButton(symbol: "plus") { timer.selectInfusion(timer.infusion + 1) }
            }
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Steep time")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                    Text(Tea.format(timer.total))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                RoundIconButton(symbol: "minus") { timer.changeAdjust(by: -10) }
                Text("10s")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .frame(minWidth: 30)
                RoundIconButton(symbol: "plus") { timer.changeAdjust(by: 10) }
            }
        }
        .card()
        .opacity(timer.isLocked ? 0.5 : 1)
        .disabled(timer.isLocked)
        .animation(.easeInOut(duration: 0.2), value: timer.isLocked)
    }

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tea.symbol)
                .font(.title3)
                .foregroundStyle(tea.color)
                .frame(width: 28)
            Text(tea.note)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .card()
    }
}
