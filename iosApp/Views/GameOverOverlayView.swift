import SwiftUI

public struct GameOverOverlayView: View {
    public let state: GameState
    public let onRestart: () -> Void

    public init(state: GameState, onRestart: @escaping () -> Void) {
        self.state = state
        self.onRestart = onRestart
    }

    public var body: some View {
        let isNewRecord = state.score > 0 && state.score >= state.highScore

        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("MISSION ÉCHOUÉE")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))

                Text("GAME OVER")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                if isNewRecord {
                    Text("★ NOUVEAU RECORD ! ★")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.96, green: 0.62, blue: 0.04), Color(red: 0.92, green: 0.35, blue: 0.05)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                }

                // Final Score Box
                VStack(spacing: 4) {
                    Text("SCORE FINAL")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    Text("\(state.score)")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color(red: 0.12, green: 0.16, blue: 0.23))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.20, green: 0.25, blue: 0.33), lineWidth: 1)
                )

                // Stats List
                VStack(spacing: 8) {
                    StatRowView(icon: "trophy.fill", label: "Meilleur Score", value: "\(state.highScore)", color: Color(red: 1.0, green: 0.72, blue: 0.01))
                    StatRowView(icon: "timer", label: "Temps de Survie", value: state.formattedSurvivalTime, color: Color(red: 0.22, green: 0.74, blue: 0.97))
                    StatRowView(icon: "arrow.triangle.swap", label: "Astéroïdes Esquivés", value: "\(state.asteroidsDodged)", color: Color(red: 0.29, green: 0.87, blue: 0.50))
                }

                Button(action: onRestart) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("REJOUER")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .tracking(1.5)
                    }
                    .foregroundColor(Color(red: 0.04, green: 0.05, blue: 0.10))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.0, green: 0.9, blue: 1.0))
                    .cornerRadius(16)
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.88, green: 0.11, blue: 0.28), lineWidth: 1.5)
            )
            .padding(24)
        }
    }
}

private struct StatRowView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.80, green: 0.84, blue: 0.88))
            }
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.04, green: 0.05, blue: 0.10))
        .cornerRadius(12)
    }
}
