package com.example.spacedodger.viewmodel

import androidx.lifecycle.ViewModel
import com.example.spacedodger.engine.GameEngine
import com.example.spacedodger.model.GameState
import com.example.spacedodger.model.GameStatus
import com.example.spacedodger.model.PlayerShip
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

/**
 * Common ViewModel managing the lifecycle, inputs, and game ticks of Space Dodger.
 * Shared between platforms without platform-specific dependencies.
 */
class SpaceDodgerViewModel(
    private val engine: GameEngine = GameEngine()
) : ViewModel() {

    private val _gameState = MutableStateFlow(
        GameState(
            stars = engine.createInitialStars(70)
        )
    )
    val gameState: StateFlow<GameState> = _gameState.asStateFlow()

    private var sessionBestScore = 0

    /**
     * Called on each frame tick by the UI game loop.
     * @param dt Delta time in seconds.
     */
    fun onGameTick(dt: Float) {
        _gameState.update { current ->
            val updated = engine.update(current, dt)
            if (updated.score > sessionBestScore) {
                sessionBestScore = updated.score
            }
            updated
        }
    }

    /**
     * Begins or resumes the game.
     */
    fun startGame() {
        engine.resetTimers()
        _gameState.update { current ->
            current.copy(
                status = GameStatus.PLAYING,
                score = 0,
                survivalSeconds = 0f,
                asteroidsDodged = 0,
                powerUpsCollected = 0,
                shieldActive = false,
                shieldRemainingSeconds = 0f,
                player = PlayerShip(x = 0.5f, targetX = 0.5f),
                asteroids = emptyList(),
                powerUps = emptyList(),
                particles = emptyList(),
                floatingTexts = emptyList(),
                speedMultiplier = 1.0f,
                waveLevel = 1,
                highScore = maxOf(current.highScore, sessionBestScore)
            )
        }
    }

    /**
     * Pauses the game loop.
     */
    fun pauseGame() {
        _gameState.update { current ->
            if (current.status == GameStatus.PLAYING) {
                current.copy(status = GameStatus.PAUSED)
            } else current
        }
    }

    /**
     * Resumes the game loop.
     */
    fun resumeGame() {
        _gameState.update { current ->
            if (current.status == GameStatus.PAUSED) {
                current.copy(status = GameStatus.PLAYING)
            } else current
        }
    }

    /**
     * Restarts the game after a Game Over or from pause menu.
     */
    fun restartGame() {
        startGame()
    }

    /**
     * Direct steering: sets the target horizontal position (0f..1f).
     */
    fun setPlayerTargetX(normalizedX: Float) {
        val clamped = normalizedX.coerceIn(0.08f, 0.92f)
        _gameState.update { current ->
            current.copy(
                player = current.player.copy(targetX = clamped)
            )
        }
    }

    /**
     * Tap movement to the left.
     */
    fun moveLeft(step: Float = 0.14f) {
        _gameState.update { current ->
            val currentTarget = current.player.targetX
            val newTarget = (currentTarget - step).coerceIn(0.08f, 0.92f)
            current.copy(
                player = current.player.copy(targetX = newTarget)
            )
        }
    }

    /**
     * Tap movement to the right.
     */
    fun moveRight(step: Float = 0.14f) {
        _gameState.update { current ->
            val currentTarget = current.player.targetX
            val newTarget = (currentTarget + step).coerceIn(0.08f, 0.92f)
            current.copy(
                player = current.player.copy(targetX = newTarget)
            )
        }
    }
}
