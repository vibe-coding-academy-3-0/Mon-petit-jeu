package com.example.spacedodger.model

/**
 * High-level lifecycle states of the game session.
 */
enum class GameStatus {
    READY,
    PLAYING,
    PAUSED,
    GAME_OVER
}

/**
 * Immutable snapshot of the Space Dodger game state.
 * Designed for predictable state flow in Compose Multiplatform.
 */
data class GameState(
    val status: GameStatus = GameStatus.READY,
    val score: Int = 0,
    val highScore: Int = 0,
    val survivalSeconds: Float = 0f,
    val asteroidsDodged: Int = 0,
    val powerUpsCollected: Int = 0,
    val shieldActive: Boolean = false,
    val shieldRemainingSeconds: Float = 0f,
    val shieldMaxSeconds: Float = 8f,
    val player: PlayerShip = PlayerShip(),
    val asteroids: List<Asteroid> = emptyList(),
    val powerUps: List<PowerUp> = emptyList(),
    val particles: List<Particle> = emptyList(),
    val floatingTexts: List<FloatingText> = emptyList(),
    val stars: List<Star> = emptyList(),
    val speedMultiplier: Float = 1.0f,
    val waveLevel: Int = 1
) {
    /**
     * Formatted survival time "MM:SS"
     */
    val formattedSurvivalTime: String
        get() {
            val totalSec = survivalSeconds.toInt()
            val minutes = totalSec / 60
            val seconds = totalSec % 60
            return "%02d:%02d".format(minutes, seconds)
        }

    /**
     * Progress ratio (0.0f..1.0f) of the active shield power-up.
     */
    val shieldRatio: Float
        get() = if (shieldMaxSeconds > 0f) (shieldRemainingSeconds / shieldMaxSeconds).coerceIn(0f, 1f) else 0f
}
