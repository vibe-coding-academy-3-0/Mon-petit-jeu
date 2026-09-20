import SwiftUI
import Combine

public class SpaceDodgerViewModel: ObservableObject {
    @Published public var state: GameState
    private let engine: GameEngine
    private let highScoreKey = "SpaceDodger_HighScore"

    public init(engine: GameEngine = GameEngine()) {
        self.engine = engine
        let savedHighScore = UserDefaults.standard.integer(forKey: highScoreKey)
        var initialState = GameState(stars: engine.createInitialStars(70))
        initialState.highScore = savedHighScore
        self.state = initialState
    }

    public func onGameTick(dt: CGFloat) {
        let updated = engine.update(currentState: state, dt: dt)
        if updated.score > state.highScore {
            UserDefaults.standard.set(updated.score, forKey: highScoreKey)
        }
        self.state = updated
    }

    public func startGame() {
        engine.resetTimers()
        let currentHighScore = state.highScore
        var newState = GameState(stars: state.stars)
        newState.status = .playing
        newState.highScore = currentHighScore
        self.state = newState
    }

    public func pauseGame() {
        if state.status == .playing {
            state.status = .paused
        }
    }

    public func resumeGame() {
        if state.status == .paused {
            state.status = .playing
        }
    }

    public func restartGame() {
        startGame()
    }

    public func setPlayerTargetX(_ targetX: CGFloat) {
        let clamped = min(max(targetX, 0.08), 0.92)
        state.player.targetX = clamped
    }

    public func moveLeft(step: CGFloat = 0.14) {
        let current = state.player.targetX
        setPlayerTargetX(current - step)
    }

    public func moveRight(step: CGFloat = 0.14) {
        let current = state.player.targetX
        setPlayerTargetX(current + step)
    }
}
