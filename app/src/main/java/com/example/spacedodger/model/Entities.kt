package com.example.spacedodger.model

import androidx.compose.ui.graphics.Color

/**
 * Types of power-ups available in Space Dodger.
 */
enum class PowerUpType {
    SHIELD,
    BONUS_SCORE
}

/**
 * Represents the player's spaceship state.
 * Positions and dimensions are normalized (0f..1f relative to screen width/height)
 * or mapped to game coordinate space.
 */
data class PlayerShip(
    val x: Float = 0.5f,
    val y: Float = 0.85f,
    val width: Float = 0.12f,
    val height: Float = 0.08f,
    val targetX: Float = 0.5f,
    val tiltAngle: Float = 0f,
    val thrusterPhase: Float = 0f
)

/**
 * Represents an asteroid falling from the top.
 */
data class Asteroid(
    val id: Long,
    val x: Float,
    val y: Float,
    val radius: Float,
    val speed: Float,
    val rotation: Float = 0f,
    val rotationSpeed: Float = 1.5f,
    val shapeSeed: Int = 0,
    val verticesOffsets: List<Float> = emptyList(),
    val colorVariant: Int = 0
)

/**
 * Represents a bonus item falling towards the player.
 */
data class PowerUp(
    val id: Long,
    val x: Float,
    val y: Float,
    val radius: Float = 0.04f,
    val speed: Float = 0.25f,
    val type: PowerUpType,
    val pulsePhase: Float = 0f
)

/**
 * Visual particle for explosion, thruster trail, or starfield.
 */
data class Particle(
    val id: Long,
    val x: Float,
    val y: Float,
    val vx: Float,
    val vy: Float,
    val color: Color,
    val radius: Float,
    val alpha: Float,
    val life: Float,
    val maxLife: Float
)

/**
 * Background star for the parallax starfield.
 */
data class Star(
    val x: Float,
    val y: Float,
    val speed: Float,
    val size: Float,
    val alpha: Float,
    val isNebulaDust: Boolean = false
)

/**
 * Temporary floating text indicator (e.g. "+250", "SHIELD UP!").
 */
data class FloatingText(
    val id: Long,
    val text: String,
    val x: Float,
    val y: Float,
    val color: Color,
    val life: Float = 1.0f,
    val maxLife: Float = 1.0f
)
