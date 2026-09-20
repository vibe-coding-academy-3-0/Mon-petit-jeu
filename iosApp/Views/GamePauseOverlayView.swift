import SwiftUI

public struct GamePauseOverlayView: View {
    public let state: GameState
    public let onResume: () -> Void
    public let onRestart: () -> Void

    public init(state: GameState, onResume: @escaping () -> Void, onRestart: @escaping () -> Void) {
        self.state = state
        self.onResume = onResume
        self.onRestart = onRestart
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("PAUSE")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(.white)

                VStack(spacing: 4) {
                    Text("SCORE ACTUEL : \(state.score)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                    Text("TEMPS : \(state.formattedSurvivalTime)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                }

                VStack(spacing: 12) {
                    Button(action: onResume) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("REPRENDRE")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(Color(red: 0.04, green: 0.05, blue: 0.10))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0.0, green: 0.9, blue: 1.0))
                        .cornerRadius(14)
                    }

                    Button(action: onRestart) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                            Text("RECOMMENCER")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.94, green: 0.27, blue: 0.27), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.22, green: 0.74, blue: 0.97), lineWidth: 1.5)
            )
            .padding(32)
        }
    }
}
