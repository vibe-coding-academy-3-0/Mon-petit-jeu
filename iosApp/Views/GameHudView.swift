import SwiftUI

public struct GameHudView: View {
    public let state: GameState
    public let onPauseClick: () -> Void

    public init(state: GameState, onPauseClick: @escaping () -> Void) {
        self.state = state
        self.onPauseClick = onPauseClick
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                // High score badge & Wave level
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.01))
                        Text("RECORD: \(state.highScore)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.12, green: 0.16, blue: 0.23).opacity(0.85))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.20, green: 0.25, blue: 0.33), lineWidth: 1)
                    )

                    Text("VAGUE \(state.waveLevel)  •  \(String(format: "%.1fx", state.speedMultiplier))")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                        .padding(.leading, 4)
                }

                Spacer()

                // Center Score Display
                VStack(spacing: 0) {
                    Text("SCORE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    Text("\(state.score)")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.6), radius: 8)
                }

                Spacer()

                // Survival Time & Pause Button
                HStack(spacing: 8) {
                    Text(state.formattedSurvivalTime)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.97))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.85))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.20, green: 0.25, blue: 0.33), lineWidth: 1)
                        )

                    Button(action: onPauseClick) {
                        Image(systemName: state.status == .paused ? "play.fill" : "pause.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.23).opacity(0.9))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color(red: 0.28, green: 0.33, blue: 0.41), lineWidth: 1)
                            )
                    }
                }
            }

            // Shield status indicator
            if state.shieldActive {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.88, green: 0.95, blue: 1.0))
                        Text("BOUCLIER ACTIF (\(String(format: "%.1fs", state.shieldRemainingSeconds)))")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.white)
                    }
                    ProgressView(value: Double(state.shieldRatio))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.22, green: 0.74, blue: 0.97)))
                        .frame(width: 140)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 0.01, green: 0.41, blue: 0.63).opacity(0.85))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.22, green: 0.74, blue: 0.97), lineWidth: 1)
                )
                .transition(.opacity)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}
