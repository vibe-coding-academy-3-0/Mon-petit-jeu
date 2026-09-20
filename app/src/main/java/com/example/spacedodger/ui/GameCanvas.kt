package com.example.spacedodger.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import com.example.spacedodger.model.Asteroid
import com.example.spacedodger.model.GameState
import com.example.spacedodger.model.PlayerShip
import com.example.spacedodger.model.PowerUp
import com.example.spacedodger.model.PowerUpType
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * High-performance Compose Canvas rendering all entities of Space Dodger.
 * Clean, high-contrast aesthetics with sharp vector shapes and luminous neon accents.
 */
@Composable
fun GameCanvas(
    state: GameState,
    modifier: Modifier = Modifier
) {
    // Colors
    val deepSpaceVoid = remember { Color(0xFF060913) }
    val deepSpaceNebula = remember { Color(0xFF0F172A) }
    val shipHullColor = remember { Color(0xFFE2E8F0) }
    val shipCockpitColor = remember { Color(0xFF6366F1) }
    val shipWingColor = remember { Color(0xFF00F0FF) }
    val thrusterInnerColor = remember { Color(0xFFFFFFFF) }
    val thrusterOuterColor = remember { Color(0xFFFF9100) }
    val shieldNeonColor = remember { Color(0xFF38BDF8) }
    val shieldGlowColor = remember { Color(0x6600E5FF) }
    val bonusGoldColor = remember { Color(0xFFFFB703) }

    Canvas(modifier = modifier.fillMaxSize()) {
        val canvasWidth = size.width
        val canvasHeight = size.height

        // 1. Cosmic Background Gradient
        drawRect(
            brush = Brush.verticalGradient(
                colors = listOf(deepSpaceVoid, deepSpaceNebula, deepSpaceVoid)
            ),
            size = size
        )

        // 2. Starfield (Parallax)
        state.stars.forEach { star ->
            val sx = star.x * canvasWidth
            val sy = star.y * canvasHeight
            val starColor = if (star.isNebulaDust) {
                Color(0xFF38BDF8).copy(alpha = star.alpha * 0.45f)
            } else {
                Color.White.copy(alpha = star.alpha)
            }
            drawCircle(
                color = starColor,
                radius = star.size,
                center = Offset(sx, sy)
            )
        }

        // 3. Power-Ups
        state.powerUps.forEach { pu ->
            drawPowerUp(pu, canvasWidth, canvasHeight, shieldNeonColor, bonusGoldColor)
        }

        // 4. Asteroids
        state.asteroids.forEach { asteroid ->
            drawAsteroid(asteroid, canvasWidth, canvasHeight)
        }

        // 5. Particles (Explosions & Thrusters)
        state.particles.forEach { p ->
            drawCircle(
                color = p.color.copy(alpha = p.alpha),
                radius = p.radius,
                center = Offset(p.x * canvasWidth, p.y * canvasHeight)
            )
        }

        // 6. Player Ship (Only if not Game Over, or fading out)
        if (state.status != com.example.spacedodger.model.GameStatus.GAME_OVER) {
            drawPlayerShip(
                ship = state.player,
                shieldActive = state.shieldActive,
                shieldRemainingSec = state.shieldRemainingSeconds,
                canvasWidth = canvasWidth,
                canvasHeight = canvasHeight,
                hullColor = shipHullColor,
                cockpitColor = shipCockpitColor,
                wingColor = shipWingColor,
                thrusterInner = thrusterInnerColor,
                thrusterOuter = thrusterOuterColor,
                shieldColor = shieldNeonColor,
                shieldGlow = shieldGlowColor
            )
        }
    }
}

/**
 * Draws the player's futuristic spaceship, thrusters, and energetic shield barrier.
 */
private fun DrawScope.drawPlayerShip(
    ship: PlayerShip,
    shieldActive: Boolean,
    shieldRemainingSec: Float,
    canvasWidth: Float,
    canvasHeight: Float,
    hullColor: Color,
    cockpitColor: Color,
    wingColor: Color,
    thrusterInner: Color,
    thrusterOuter: Color,
    shieldColor: Color,
    shieldGlow: Color
) {
    val shipCenterX = ship.x * canvasWidth
    val shipCenterY = ship.y * canvasHeight
    val shipSize = canvasWidth * 0.13f

    rotate(degrees = ship.tiltAngle, pivot = Offset(shipCenterX, shipCenterY)) {
        // --- Thruster Jet Flame ---
        val flameFlicker = (sin(ship.thrusterPhase) * 0.2f) + 1.0f
        val flameHeight = shipSize * 0.7f * flameFlicker
        val thrusterPath = Path().apply {
            moveTo(shipCenterX - shipSize * 0.18f, shipCenterY + shipSize * 0.38f)
            lineTo(shipCenterX, shipCenterY + shipSize * 0.38f + flameHeight)
            lineTo(shipCenterX + shipSize * 0.18f, shipCenterY + shipSize * 0.38f)
            close()
        }
        drawPath(
            path = thrusterPath,
            brush = Brush.verticalGradient(
                colors = listOf(thrusterInner, thrusterOuter, Color.Transparent),
                startY = shipCenterY + shipSize * 0.35f,
                endY = shipCenterY + shipSize * 0.38f + flameHeight
            )
        )

        // --- Delta Wings & Cannons ---
        val leftWingPath = Path().apply {
            moveTo(shipCenterX, shipCenterY - shipSize * 0.5f)
            lineTo(shipCenterX - shipSize * 0.52f, shipCenterY + shipSize * 0.38f)
            lineTo(shipCenterX - shipSize * 0.22f, shipCenterY + shipSize * 0.24f)
            close()
        }
        drawPath(path = leftWingPath, color = wingColor)

        val rightWingPath = Path().apply {
            moveTo(shipCenterX, shipCenterY - shipSize * 0.5f)
            lineTo(shipCenterX + shipSize * 0.52f, shipCenterY + shipSize * 0.38f)
            lineTo(shipCenterX + shipSize * 0.22f, shipCenterY + shipSize * 0.24f)
            close()
        }
        drawPath(path = rightWingPath, color = wingColor)

        // --- Center Fuselage ---
        val fuselagePath = Path().apply {
            moveTo(shipCenterX, shipCenterY - shipSize * 0.65f) // Nose cone
            lineTo(shipCenterX + shipSize * 0.18f, shipCenterY + shipSize * 0.28f)
            lineTo(shipCenterX, shipCenterY + shipSize * 0.38f)
            lineTo(shipCenterX - shipSize * 0.18f, shipCenterY + shipSize * 0.28f)
            close()
        }
        drawPath(path = fuselagePath, color = hullColor)
        drawPath(
            path = fuselagePath,
            color = Color(0xFF0F172A),
            style = Stroke(width = 2.5f)
        )

        // --- Cockpit Canopy ---
        val cockpitPath = Path().apply {
            moveTo(shipCenterX, shipCenterY - shipSize * 0.38f)
            lineTo(shipCenterX + shipSize * 0.09f, shipCenterY - shipSize * 0.05f)
            lineTo(shipCenterX, shipCenterY + shipSize * 0.08f)
            lineTo(shipCenterX - shipSize * 0.09f, shipCenterY - shipSize * 0.05f)
            close()
        }
        drawPath(path = cockpitPath, color = cockpitColor)

        // Specular reflection on cockpit
        drawCircle(
            color = Color.White.copy(alpha = 0.8f),
            radius = shipSize * 0.04f,
            center = Offset(shipCenterX - shipSize * 0.03f, shipCenterY - shipSize * 0.18f)
        )

        // --- Active Shield Force Field ---
        if (shieldActive) {
            val shieldRadius = shipSize * 0.82f
            val pulseAlpha = if (shieldRemainingSec < 2.5f) {
                // Flash when about to expire
                (sin(ship.thrusterPhase * 3f) * 0.35f + 0.55f).coerceIn(0.2f, 0.9f)
            } else {
                (sin(ship.thrusterPhase) * 0.15f + 0.75f).coerceIn(0.5f, 0.95f)
            }

            // Outer energy glow ring
            drawCircle(
                color = shieldGlow.copy(alpha = pulseAlpha * 0.4f),
                radius = shieldRadius * 1.08f,
                center = Offset(shipCenterX, shipCenterY)
            )

            // Primary shield boundary
            drawCircle(
                color = shieldColor.copy(alpha = pulseAlpha),
                radius = shieldRadius,
                center = Offset(shipCenterX, shipCenterY),
                style = Stroke(width = 3.5f, cap = StrokeCap.Round)
            )

            // Dynamic shield energy arc
            val arcAngle = (ship.thrusterPhase * 40f) % 360f
            drawArc(
                color = Color.White.copy(alpha = pulseAlpha * 0.8f),
                startAngle = arcAngle,
                sweepAngle = 70f,
                useCenter = false,
                topLeft = Offset(shipCenterX - shieldRadius, shipCenterY - shieldRadius),
                size = Size(shieldRadius * 2f, shieldRadius * 2f),
                style = Stroke(width = 4f, cap = StrokeCap.Round)
            )
        }
    }
}

/**
 * Draws a rocky, faceted asteroid with rotation and crater details.
 */
private fun DrawScope.drawAsteroid(
    asteroid: Asteroid,
    canvasWidth: Float,
    canvasHeight: Float
) {
    val cx = asteroid.x * canvasWidth
    val cy = asteroid.y * canvasHeight
    val baseRadius = asteroid.radius * canvasWidth

    // Asteroid base colors according to variant
    val (primaryColor, darkShadeColor, highlightColor) = when (asteroid.colorVariant) {
        0 -> Triple(Color(0xFF475569), Color(0xFF1E293B), Color(0xFF94A3B8)) // Iron Slate
        1 -> Triple(Color(0xFF57534E), Color(0xFF292524), Color(0xFFA8A29E)) // Basalt Rock
        else -> Triple(Color(0xFF3F3F46), Color(0xFF18181B), Color(0xFF71717A)) // Carbon Chondrite
    }

    rotate(degrees = asteroid.rotation * 57.2958f, pivot = Offset(cx, cy)) {
        val path = Path()
        val count = asteroid.verticesOffsets.size.coerceAtLeast(6)
        val angleStep = (2f * PI / count).toFloat()

        for (i in 0 until count) {
            val angle = i * angleStep
            val factor = asteroid.verticesOffsets.getOrElse(i) { 1.0f }
            val r = baseRadius * factor
            val px = cx + cos(angle) * r
            val py = cy + sin(angle) * r
            if (i == 0) path.moveTo(px, py) else path.lineTo(px, py)
        }
        path.close()

        // Shaded body with radial gradient to give spherical volume
        drawPath(
            path = path,
            brush = Brush.radialGradient(
                colors = listOf(highlightColor, primaryColor, darkShadeColor),
                center = Offset(cx - baseRadius * 0.3f, cy - baseRadius * 0.3f),
                radius = baseRadius * 1.2f
            ),
            style = Fill
        )

        // Outline contour
        drawPath(
            path = path,
            color = darkShadeColor,
            style = Stroke(width = 2.0f)
        )

        // Crater depressions
        val crater1Offset = Offset(cx - baseRadius * 0.28f, cy - baseRadius * 0.15f)
        drawCircle(
            color = darkShadeColor.copy(alpha = 0.85f),
            radius = baseRadius * 0.22f,
            center = crater1Offset
        )
        drawCircle(
            color = highlightColor.copy(alpha = 0.5f),
            radius = baseRadius * 0.22f,
            center = crater1Offset,
            style = Stroke(width = 1.5f)
        )

        val crater2Offset = Offset(cx + baseRadius * 0.25f, cy + baseRadius * 0.22f)
        drawCircle(
            color = darkShadeColor.copy(alpha = 0.8f),
            radius = baseRadius * 0.16f,
            center = crater2Offset
        )
    }
}

/**
 * Draws floating bonus items with pulsating halos and distinctive icons.
 */
private fun DrawScope.drawPowerUp(
    pu: PowerUp,
    canvasWidth: Float,
    canvasHeight: Float,
    shieldColor: Color,
    goldColor: Color
) {
    val cx = pu.x * canvasWidth
    val cy = pu.y * canvasHeight
    val baseRadius = pu.radius * canvasWidth
    val pulse = (sin(pu.pulsePhase) * 0.22f) + 1.0f
    val currentRadius = baseRadius * pulse

    when (pu.type) {
        PowerUpType.SHIELD -> {
            // Cyan pulsing shield orb
            drawCircle(
                color = shieldColor.copy(alpha = 0.25f),
                radius = currentRadius * 1.5f,
                center = Offset(cx, cy)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(Color.White, shieldColor, Color(0xFF0284C7)),
                    center = Offset(cx, cy),
                    radius = currentRadius
                ),
                radius = currentRadius,
                center = Offset(cx, cy)
            )
            // Outer ring
            drawCircle(
                color = Color.White,
                radius = currentRadius,
                center = Offset(cx, cy),
                style = Stroke(width = 2.5f)
            )

            // Shield vector emblem in center
            val emblemSize = currentRadius * 0.6f
            val shieldEmblem = Path().apply {
                moveTo(cx, cy - emblemSize)
                lineTo(cx + emblemSize * 0.8f, cy - emblemSize * 0.4f)
                lineTo(cx + emblemSize * 0.65f, cy + emblemSize * 0.5f)
                lineTo(cx, cy + emblemSize)
                lineTo(cx - emblemSize * 0.65f, cy + emblemSize * 0.5f)
                lineTo(cx - emblemSize * 0.8f, cy - emblemSize * 0.4f)
                close()
            }
            drawPath(path = shieldEmblem, color = Color(0xFF0F172A))
            drawPath(
                path = shieldEmblem,
                color = Color.White,
                style = Stroke(width = 2f)
            )
        }

        PowerUpType.BONUS_SCORE -> {
            // Gold pulsing score star orb
            drawCircle(
                color = goldColor.copy(alpha = 0.3f),
                radius = currentRadius * 1.5f,
                center = Offset(cx, cy)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(Color.White, goldColor, Color(0xFFEA580C)),
                    center = Offset(cx, cy),
                    radius = currentRadius
                ),
                radius = currentRadius,
                center = Offset(cx, cy)
            )
            drawCircle(
                color = Color.White,
                radius = currentRadius,
                center = Offset(cx, cy),
                style = Stroke(width = 2.5f)
            )

            // Star diamond emblem in center
            val starSize = currentRadius * 0.65f
            val starPath = Path().apply {
                moveTo(cx, cy - starSize)
                lineTo(cx + starSize * 0.35f, cy - starSize * 0.35f)
                lineTo(cx + starSize, cy)
                lineTo(cx + starSize * 0.35f, cy + starSize * 0.35f)
                lineTo(cx, cy + starSize)
                lineTo(cx - starSize * 0.35f, cy + starSize * 0.35f)
                lineTo(cx - starSize, cy)
                lineTo(cx - starSize * 0.35f, cy - starSize * 0.35f)
                close()
            }
            drawPath(path = starPath, color = Color(0xFF78350F))
            drawPath(path = starPath, color = Color.White, style = Stroke(width = 2f))
        }
    }
}
