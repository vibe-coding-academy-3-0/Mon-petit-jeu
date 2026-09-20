import SwiftUI

public struct GameControlsView: View {
    public let onMoveLeft: () -> Void
    public let onMoveRight: () -> Void
    public let onSteerTarget: (CGFloat) -> Void

    public init(
        onMoveLeft: @escaping () -> Void,
        onMoveRight: @escaping () -> Void,
        onSteerTarget: @escaping (CGFloat) -> Void
    ) {
        self.onMoveLeft = onMoveLeft
        self.onMoveRight = onMoveRight
        self.onSteerTarget = onSteerTarget
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dual Tap Zones
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onMoveLeft()
                        }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onMoveRight()
                        }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let normalized = value.location.x / geo.size.width
                            onSteerTarget(normalized)
                        }
                )

                // Visual Indicators at bottom
                VStack {
                    Spacer()
                    HStack {
                        // Left Indicator
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                            Text("GAUCHE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.3), Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.6), lineWidth: 1)
                        )

                        Spacer()

                        // Right Indicator
                        HStack(spacing: 6) {
                            Text("DROITE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.3), Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.6), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
