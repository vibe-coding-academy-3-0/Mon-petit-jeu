package com.example.spacedodger

import androidx.compose.ui.graphics.Color
import com.example.spacedodger.engine.GameEngine
import com.example.spacedodger.model.Asteroid
import com.example.spacedodger.model.GameState
import com.example.spacedodger.model.GameStatus
import com.example.spacedodger.model.PlayerShip
import com.example.spacedodger.model.PowerUp
import com.example.spacedodger.model.PowerUpType
import com.example.spacedodger.viewmodel.SpaceDodgerViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class GameEngineTest {

    private val engine = GameEngine()

    @Test
    fun testInitialStateAndStart() {
        val vm = SpaceDodgerViewModel(engine)
        assertEquals(GameStatus.READY, vm.gameState.value.status)
        assertEquals(0, vm.gameState.value.score)

        vm.startGame()
        assertEquals(GameStatus.PLAYING, vm.gameState.value.status)
        assertEquals(0, vm.gameState.value.score)
    }

    @Test
    fun testPlayerSteering() {
        val vm = SpaceDodgerViewModel(engine)
        vm.startGame()

        val initialX = vm.gameState.value.player.targetX
        vm.moveLeft(0.1f)
        assertTrue(vm.gameState.value.player.targetX < initialX)

        vm.moveRight(0.2f)
        assertTrue(vm.gameState.value.player.targetX > initialX)

        vm.setPlayerTargetX(0.8f)
        assertEquals(0.8f, vm.gameState.value.player.targetX, 0.001f)
    }

    @Test
    fun testShieldProtectsAgainstAsteroidCollision() {
        val initial = GameState(
            status = GameStatus.PLAYING,
            shieldActive = true,
            shieldRemainingSeconds = 5.0f,
            player = PlayerShip(x = 0.5f, y = 0.85f, targetX = 0.5f),
            asteroids = listOf(
                Asteroid(
                    id = 1L,
                    x = 0.5f,
                    y = 0.85f, // Direct hit
                    radius = 0.04f,
                    speed = 0.2f
                )
            )
        )

        val updated = engine.update(initial, 0.016f)
        // Game should NOT be game over because shield is active
        assertEquals(GameStatus.PLAYING, updated.status)
        // Asteroid should have been deflected/destroyed
        assertEquals(0, updated.asteroids.size)
        // Score should have increased
        assertTrue(updated.score > initial.score)
    }

    @Test
    fun testFatalCollisionWithoutShieldTriggersGameOver() {
        val initial = GameState(
            status = GameStatus.PLAYING,
            shieldActive = false,
            player = PlayerShip(x = 0.5f, y = 0.85f, targetX = 0.5f),
            asteroids = listOf(
                Asteroid(
                    id = 1L,
                    x = 0.5f,
                    y = 0.85f, // Direct hit
                    radius = 0.04f,
                    speed = 0.2f
                )
            )
        )

        val updated = engine.update(initial, 0.016f)
        assertEquals(GameStatus.GAME_OVER, updated.status)
    }

    @Test
    fun testPowerUpShieldPickup() {
        val initial = GameState(
            status = GameStatus.PLAYING,
            shieldActive = false,
            player = PlayerShip(x = 0.5f, y = 0.85f, targetX = 0.5f),
            powerUps = listOf(
                PowerUp(
                    id = 10L,
                    x = 0.5f,
                    y = 0.85f,
                    radius = 0.04f,
                    type = PowerUpType.SHIELD
                )
            )
        )

        val updated = engine.update(initial, 0.016f)
        assertTrue(updated.shieldActive)
        assertTrue(updated.shieldRemainingSeconds > 0f)
        assertEquals(0, updated.powerUps.size)
    }

    @Test
    fun testPowerUpScoreBonusPickup() {
        val initial = GameState(
            status = GameStatus.PLAYING,
            score = 100,
            player = PlayerShip(x = 0.5f, y = 0.85f, targetX = 0.5f),
            powerUps = listOf(
                PowerUp(
                    id = 11L,
                    x = 0.5f,
                    y = 0.85f,
                    radius = 0.04f,
                    type = PowerUpType.BONUS_SCORE
                )
            )
        )

        val updated = engine.update(initial, 0.016f)
        assertTrue(updated.score >= 350)
        assertEquals(0, updated.powerUps.size)
    }
}
