import SwiftUI

public struct GameStartOverlayView: View {
    public let highScore: Int
    public let onStartGame: () -> Void

    public init(highScore: Int, onStartGame: @escaping () -> Void) {
        self.highScore = highScore
        self.onStartGame = onStartGame
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                // Mission Tag
                Text("MISSION SPATIALE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.0, green: 0.94, blue: 1.0))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.4), lineWidth: 1)
                    )

                Text("SPACE DODGER")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                Text("Pilotez le vaisseau et survivez aux vagues d'astéroïdes")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))

                if highScore > 0 {
                    Text("RECORD ACTUEL : \(highScore) PTS")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.01))
                }

                // Guide List
                VStack(spacing: 10) {
                    GuideItemView(icon: "hand.tap.fill", title: "Contrôles Tactiles", desc: "Tapotez à gauche / droite ou glissez votre doigt", color: Color(red: 0.0, green: 0.94, blue: 1.0))
                    GuideItemView(icon: "shield.fill", title: "Bouclier d'Énergie", desc: "Absorbe les impacts et désintègre les obstacles", color: Color(red: 0.22, green: 0.74, blue: 0.97))
                    GuideItemView(icon: "star.fill", title: "Orbes Bonus", desc: "+250 points immédiats et multiplicateur", color: Color(red: 1.0, green: 0.72, blue: 0.01))
                }
                .padding(.vertical, 6)

                Button(action: onStartGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("LANCER LA MISSION")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .tracking(1)
                    }
                    .foregroundColor(Color(red: 0.04, green: 0.05, blue: 0.10))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.0, green: 0.9, blue: 1.0))
                    .cornerRadius(16)
                }
                .padding(.top, 6)
            }
            .padding(24)
            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.0, green: 0.94, blue: 1.0), lineWidth: 1.5)
            )
            .padding(24)
        }
    }
}

private struct GuideItemView: View {
    let icon: String
    let title: String
    let desc: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
            }
            Spacer()
        }
        .padding(10)
        .background(Color(red: 0.12, green: 0.16, blue: 0.23))
        .cornerRadius(12)
    }
}
