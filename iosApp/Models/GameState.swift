import SwiftUI

public enum GameStatus: String {
    case ready
    case playing
    case paused
    case gameOver
}

public struct GameState {
    public var status: GameStatus = .ready
    public var score: Int = 0
    public var highScore: Int = 0
    public var survivalSeconds: CGFloat = 0
    public var asteroidsDodged: Int = 0
    public var powerUpsCollected: Int = 0
    public var shieldActive: Bool = false
    public var shieldRemainingSeconds: CGFloat = 0
    public var shieldMaxSeconds: CGFloat = 8.0
    public var player: PlayerShip = PlayerShip()
    public var asteroids: [Asteroid] = []
    public var powerUps: [PowerUp] = []
    public var particles: [Particle] = []
    public var floatingTexts: [FloatingText] = []
    public var stars: [Star] = []
    public var speedMultiplier: CGFloat = 1.0
    public var waveLevel: Int = 1

    public init(stars: [Star] = []) {
        self.stars = stars
    }

    public var formattedSurvivalTime: String {
        let total = Int(survivalSeconds)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    public var shieldRatio: CGFloat {
        if shieldMaxSeconds > 0 {
            return min(max(shieldRemainingSeconds / shieldMaxSeconds, 0.0), 1.0)
        }
        return 0.0
    }
}
