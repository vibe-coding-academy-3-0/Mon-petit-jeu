package com.example.spacedodger.engine

import androidx.compose.ui.graphics.Color
import com.example.spacedodger.model.Asteroid
import com.example.spacedodger.model.FloatingText
import com.example.spacedodger.model.GameState
import com.example.spacedodger.model.GameStatus
import com.example.spacedodger.model.Particle
import com.example.spacedodger.model.PowerUp
import com.example.spacedodger.model.PowerUpType
import com.example.spacedodger.model.Star
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin
import kotlin.random.Random

/**
 * Pure Kotlin game engine logic.
 * Independent of Android-specific APIs to ensure 100% Kotlin Multiplatform compatibility.
 */
class GameEngine(
    private val random: Random = Random.Default
) {
    private var nextEntityId = 1L
    private var asteroidSpawnTimer = 0f
    private var powerUpSpawnTimer = 5f
    private var scoreAccumulator = 0f
    private var thrusterEmitTimer = 0f

    /**
     * Initializes the background starfield for parallax effect.
     */
    fun createInitialStars(count: Int = 60): List<Star> {
        return List(count) {
            val speedTier = random.nextFloat()
            val speed = when {
                speedTier < 0.5f -> 0.05f + random.nextFloat() * 0.04f // Distant slow stars
                speedTier < 0.85f -> 0.12f + random.nextFloat() * 0.06f // Mid-layer stars
                else -> 0.25f + random.nextFloat() * 0.15f // Fast foreground stars
            }
            val size = when {
                speedTier < 0.5f -> 1.5f + random.nextFloat() * 1.5f
                speedTier < 0.85f -> 2.5f + random.nextFloat() * 2f
                else -> 4f + random.nextFloat() * 2.5f
            }
            val alpha = 0.3f + random.nextFloat() * 0.7f
            Star(
                x = random.nextFloat(),
                y = random.nextFloat(),
                speed = speed,
                size = size,
                alpha = alpha,
                isNebulaDust = random.nextFloat() < 0.1f
            )
        }
    }

    /**
     * Resets internal timers and counters when a new game begins.
     */
    fun resetTimers() {
        asteroidSpawnTimer = 0.5f
        powerUpSpawnTimer = 6f + random.nextFloat() * 4f
        scoreAccumulator = 0f
        thrusterEmitTimer = 0f
    }

    /**
     * Main step function updating physics, collisions, entity lifecycles, and scores.
     * @param currentState Current snapshot of the game.
     * @param dt Elapsed delta time in seconds.
     * @return New updated GameState.
     */
    fun update(currentState: GameState, dt: Float): GameState {
        if (currentState.status != GameStatus.PLAYING) {
            // Even when paused or ready, animate stars for ambient cosmic motion
            val updatedStars = updateStars(currentState.stars, dt * 0.2f)
            return currentState.copy(stars = updatedStars)
        }

        val clampedDt = dt.coerceIn(0.001f, 0.05f) // Avoid large frame jump glitches

        // 1. Difficulty progression
        val newSurvivalSeconds = currentState.survivalSeconds + clampedDt
        val waveLevel = 1 + (newSurvivalSeconds / 15f).toInt()
        val speedMultiplier = (1.0f + (newSurvivalSeconds * 0.025f)).coerceAtMost(3.2f)

        // 2. Continuous survival score accumulation
        scoreAccumulator += clampedDt * 12f * speedMultiplier
        var newScore = currentState.score
        if (scoreAccumulator >= 1f) {
            val ptsToAdd = scoreAccumulator.toInt()
            newScore += ptsToAdd
            scoreAccumulator -= ptsToAdd
        }

        // 3. Update player ship position & tilt smoothly towards targetX
        val player = currentState.player
        val targetX = player.targetX.coerceIn(0.08f, 0.92f)
        val lerpFactor = (clampedDt * 14f).coerceAtMost(1f)
        val newX = player.x + (targetX - player.x) * lerpFactor
        val deltaMove = targetX - player.x
        val targetTilt = (deltaMove * 180f).coerceIn(-28f, 28f)
        val newTilt = player.tiltAngle + (targetTilt - player.tiltAngle) * (clampedDt * 10f).coerceAtMost(1f)
        val newThrusterPhase = (player.thrusterPhase + clampedDt * 16f) % (2f * Math.PI.toFloat())

        val updatedPlayer = player.copy(
            x = newX,
            tiltAngle = newTilt,
            thrusterPhase = newThrusterPhase
        )

        // 4. Update shield timer
        var isShieldActive = currentState.shieldActive
        var remainingShield = currentState.shieldRemainingSeconds
        if (isShieldActive) {
            remainingShield -= clampedDt
            if (remainingShield <= 0f) {
                isShieldActive = false
                remainingShield = 0f
            }
        }

        // 5. Update Stars
        val updatedStars = updateStars(currentState.stars, clampedDt * speedMultiplier)

        // 6. Spawn Asteroids
        asteroidSpawnTimer -= clampedDt
        val spawnInterval = (1.1f / (1f + newSurvivalSeconds * 0.04f)).coerceIn(0.28f, 1.2f)
        val mutableAsteroids = currentState.asteroids.toMutableList()

        if (asteroidSpawnTimer <= 0f) {
            asteroidSpawnTimer = spawnInterval + random.nextFloat() * (spawnInterval * 0.4f)
            mutableAsteroids.add(createRandomAsteroid(speedMultiplier))
        }

        // 7. Spawn Power-ups
        powerUpSpawnTimer -= clampedDt
        val mutablePowerUps = currentState.powerUps.toMutableList()
        if (powerUpSpawnTimer <= 0f) {
            powerUpSpawnTimer = 11f + random.nextFloat() * 7f
            val type = if (random.nextFloat() < 0.45f) PowerUpType.SHIELD else PowerUpType.BONUS_SCORE
            mutablePowerUps.add(
                PowerUp(
                    id = nextEntityId++,
                    x = 0.1f + random.nextFloat() * 0.8f,
                    y = -0.05f,
                    radius = 0.038f,
                    speed = 0.22f * (1.0f + (speedMultiplier - 1f) * 0.3f),
                    type = type
                )
            )
        }

        // 8. Move entities
        val movedAsteroids = mutableListOf<Asteroid>()
        var dodgedCount = currentState.asteroidsDodged

        for (ast in mutableAsteroids) {
            val nextY = ast.y + ast.speed * clampedDt
            val nextRot = ast.rotation + ast.rotationSpeed * clampedDt
            if (nextY > 1.08f) {
                // Asteroid safely avoided!
                dodgedCount++
                newScore += 20
            } else {
                movedAsteroids.add(ast.copy(y = nextY, rotation = nextRot))
            }
        }

        val movedPowerUps = mutableListOf<PowerUp>()
        for (pu in mutablePowerUps) {
            val nextY = pu.y + pu.speed * clampedDt
            val nextPulse = (pu.pulsePhase + clampedDt * 6f) % (2f * Math.PI.toFloat())
            if (nextY <= 1.08f) {
                movedPowerUps.add(pu.copy(y = nextY, pulsePhase = nextPulse))
            }
        }

        // 9. Particle emitter & updater
        val mutableParticles = currentState.particles.toMutableList()
        val mutableFloatingTexts = currentState.floatingTexts.toMutableList()

        // Thruster sparks from engine
        thrusterEmitTimer += clampedDt
        if (thrusterEmitTimer >= 0.04f) {
            thrusterEmitTimer = 0f
            val flameColor = if (random.nextBoolean()) Color(0xFF00E5FF) else Color(0xFFFF9100)
            mutableParticles.add(
                Particle(
                    id = nextEntityId++,
                    x = updatedPlayer.x + (random.nextFloat() - 0.5f) * 0.02f,
                    y = updatedPlayer.y + 0.04f,
                    vx = (random.nextFloat() - 0.5f) * 0.04f,
                    vy = 0.35f + random.nextFloat() * 0.2f,
                    color = flameColor,
                    radius = 3.5f + random.nextFloat() * 3f,
                    alpha = 0.85f,
                    life = 0.35f,
                    maxLife = 0.35f
                )
            )
        }

        // 10. Collision Detection: Player vs Power-ups
        val survivingPowerUps = mutableListOf<PowerUp>()
        var powerUpsCollected = currentState.powerUpsCollected
        val playerRadius = 0.045f

        for (pu in movedPowerUps) {
            val dist = hypot(updatedPlayer.x - pu.x, updatedPlayer.y - pu.y)
            if (dist < (playerRadius + pu.radius)) {
                // Collected power-up!
                powerUpsCollected++
                when (pu.type) {
                    PowerUpType.SHIELD -> {
                        isShieldActive = true
                        remainingShield = 8.0f
                        newScore += 150
                        mutableFloatingTexts.add(
                            FloatingText(
                                id = nextEntityId++,
                                text = "BOUCLIER ACTIF!",
                                x = updatedPlayer.x,
                                y = updatedPlayer.y - 0.06f,
                                color = Color(0xFF00E5FF)
                            )
                        )
                        spawnShockwaveParticles(mutableParticles, pu.x, pu.y, Color(0xFF00E5FF), count = 20)
                    }
                    PowerUpType.BONUS_SCORE -> {
                        newScore += 250
                        mutableFloatingTexts.add(
                            FloatingText(
                                id = nextEntityId++,
                                text = "+250 BONUS!",
                                x = updatedPlayer.x,
                                y = updatedPlayer.y - 0.06f,
                                color = Color(0xFFFFD700)
                            )
                        )
                        spawnShockwaveParticles(mutableParticles, pu.x, pu.y, Color(0xFFFFD700), count = 22)
                    }
                }
            } else {
                survivingPowerUps.add(pu)
            }
        }

        // 11. Collision Detection: Player vs Asteroids
        val survivingAsteroids = mutableListOf<Asteroid>()
        var gameOver = false
        val effectiveHitRadius = if (isShieldActive) 0.075f else 0.045f

        for (ast in movedAsteroids) {
            val dist = hypot(updatedPlayer.x - ast.x, updatedPlayer.y - ast.y)
            val collisionThreshold = effectiveHitRadius + (ast.radius * 0.82f)

            if (dist < collisionThreshold) {
                if (isShieldActive) {
                    // Shield destroys asteroid!
                    newScore += 60
                    mutableFloatingTexts.add(
                        FloatingText(
                            id = nextEntityId++,
                            text = "DÉVIÉ! +60",
                            x = ast.x,
                            y = ast.y,
                            color = Color(0xFF38BDF8)
                        )
                    )
                    spawnExplosionParticles(mutableParticles, ast.x, ast.y, Color(0xFF00F0FF), count = 24)
                    // Shield absorbs impact, reducing remaining time slightly as feedback
                    remainingShield = (remainingShield - 1.2f).coerceAtLeast(0.5f)
                } else {
                    // Fatal collision!
                    gameOver = true
                    spawnExplosionParticles(mutableParticles, updatedPlayer.x, updatedPlayer.y, Color(0xFFFF3366), count = 40)
                    spawnExplosionParticles(mutableParticles, ast.x, ast.y, Color(0xFFFF9F1C), count = 25)
                }
            } else {
                survivingAsteroids.add(ast)
            }
        }

        // 12. Update Particles lifecycle
        val remainingParticles = mutableListOf<Particle>()
        for (p in mutableParticles) {
            val nextLife = p.life - clampedDt
            if (nextLife > 0f) {
                val nextAlpha = (nextLife / p.maxLife).coerceIn(0f, 1f)
                remainingParticles.add(
                    p.copy(
                        x = p.x + p.vx * clampedDt,
                        y = p.y + p.vy * clampedDt,
                        life = nextLife,
                        alpha = nextAlpha
                    )
                )
            }
        }

        // 13. Update Floating texts
        val remainingTexts = mutableListOf<FloatingText>()
        for (ft in mutableFloatingTexts) {
            val nextLife = ft.life - clampedDt
            if (nextLife > 0f) {
                remainingTexts.add(
                    ft.copy(
                        y = ft.y - clampedDt * 0.045f,
                        life = nextLife
                    )
                )
            }
        }

        val finalHighScore = if (newScore > currentState.highScore) newScore else currentState.highScore

        return currentState.copy(
            status = if (gameOver) GameStatus.GAME_OVER else GameStatus.PLAYING,
            score = newScore,
            highScore = finalHighScore,
            survivalSeconds = newSurvivalSeconds,
            asteroidsDodged = dodgedCount,
            powerUpsCollected = powerUpsCollected,
            shieldActive = isShieldActive,
            shieldRemainingSeconds = remainingShield,
            player = updatedPlayer,
            asteroids = survivingAsteroids,
            powerUps = survivingPowerUps,
            particles = remainingParticles,
            floatingTexts = remainingTexts,
            stars = updatedStars,
            speedMultiplier = speedMultiplier,
            waveLevel = waveLevel
        )
    }

    private fun updateStars(stars: List<Star>, dt: Float): List<Star> {
        return stars.map { star ->
            var newY = star.y + star.speed * dt
            var newX = star.x
            if (newY > 1.0f) {
                newY = 0.0f
                newX = random.nextFloat()
            }
            star.copy(x = newX, y = newY)
        }
    }

    private fun createRandomAsteroid(speedMultiplier: Float): Asteroid {
        // Size categories: Small (0.028f), Medium (0.045f), Large (0.065f)
        val sizeRoll = random.nextFloat()
        val radius = when {
            sizeRoll < 0.45f -> 0.028f + random.nextFloat() * 0.008f
            sizeRoll < 0.85f -> 0.042f + random.nextFloat() * 0.012f
            else -> 0.062f + random.nextFloat() * 0.015f
        }

        // Smaller asteroids travel slightly faster
        val baseSpeed = when {
            radius < 0.035f -> 0.42f + random.nextFloat() * 0.12f
            radius < 0.055f -> 0.32f + random.nextFloat() * 0.09f
            else -> 0.23f + random.nextFloat() * 0.07f
        }

        val rotSpeed = (random.nextFloat() - 0.5f) * 4.0f

        // Generate 8 craggy shape offsets for polygon rendering
        val vertexCount = 8
        val vertices = List(vertexCount) {
            0.78f + random.nextFloat() * 0.44f // Radius factor [0.78..1.22]
        }

        return Asteroid(
            id = nextEntityId++,
            x = 0.08f + random.nextFloat() * 0.84f,
            y = -0.08f,
            radius = radius,
            speed = baseSpeed * speedMultiplier,
            rotation = random.nextFloat() * 6.28f,
            rotationSpeed = rotSpeed,
            shapeSeed = random.nextInt(1000),
            verticesOffsets = vertices,
            colorVariant = random.nextInt(3)
        )
    }

    private fun spawnExplosionParticles(
        list: MutableList<Particle>,
        x: Float,
        y: Float,
        baseColor: Color,
        count: Int
    ) {
        for (i in 0 until count) {
            val angle = random.nextFloat() * 6.283f
            val speed = 0.15f + random.nextFloat() * 0.45f
            val vx = cos(angle) * speed
            val vy = sin(angle) * speed
            val life = 0.4f + random.nextFloat() * 0.5f
            list.add(
                Particle(
                    id = nextEntityId++,
                    x = x,
                    y = y,
                    vx = vx,
                    vy = vy,
                    color = baseColor,
                    radius = 3f + random.nextFloat() * 5f,
                    alpha = 1.0f,
                    life = life,
                    maxLife = life
                )
            )
        }
    }

    private fun spawnShockwaveParticles(
        list: MutableList<Particle>,
        x: Float,
        y: Float,
        color: Color,
        count: Int
    ) {
        for (i in 0 until count) {
            val angle = (i.toFloat() / count) * 6.283f
            val speed = 0.22f + random.nextFloat() * 0.15f
            list.add(
                Particle(
                    id = nextEntityId++,
                    x = x,
                    y = y,
                    vx = cos(angle) * speed,
                    vy = sin(angle) * speed,
                    color = color,
                    radius = 3.5f + random.nextFloat() * 3f,
                    alpha = 1f,
                    life = 0.45f,
                    maxLife = 0.45f
                )
            )
        }
    }
}
