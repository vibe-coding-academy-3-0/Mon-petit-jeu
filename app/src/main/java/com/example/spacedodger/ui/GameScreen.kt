package com.example.spacedodger.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.spacedodger.model.GameStatus
import com.example.spacedodger.viewmodel.SpaceDodgerViewModel
import kotlinx.coroutines.isActive

/**
 * Main game screen composable orchestrating the frame-rate synchronized game loop,
 * interactive canvas, heads-up display, and status overlays.
 */
@Composable
fun GameScreen(
    modifier: Modifier = Modifier,
    viewModel: SpaceDodgerViewModel = viewModel()
) {
    val gameState by viewModel.gameState.collectAsStateWithLifecycle()

    // --- Frame-Rate Synchronized Game Loop (60/120 FPS vsync) ---
    LaunchedEffect(gameState.status) {
        if (gameState.status == GameStatus.PLAYING) {
            var lastFrameNanos = 0L
            while (isActive) {
                withFrameNanos { frameTimeNanos ->
                    if (lastFrameNanos != 0L) {
                        val dt = (frameTimeNanos - lastFrameNanos) / 1_000_000_000f
                        viewModel.onGameTick(dt)
                    }
                    lastFrameNanos = frameTimeNanos
                }
            }
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        // 1. Core Visual Canvas (Stars, Ship, Asteroids, Power-ups, Particles)
        GameCanvas(state = gameState)

        // 2. Interactive Touch Controls (Active when playing)
        if (gameState.status == GameStatus.PLAYING) {
            GameControls(
                onMoveLeft = { viewModel.moveLeft() },
                onMoveRight = { viewModel.moveRight() },
                onSteerTarget = { targetX -> viewModel.setPlayerTargetX(targetX) }
            )
        }

        // 3. Real-time HUD (Score, High Score, Shield Bar, Wave, Timer)
        GameHud(
            state = gameState,
            onPauseClick = {
                if (gameState.status == GameStatus.PLAYING) {
                    viewModel.pauseGame()
                } else if (gameState.status == GameStatus.PAUSED) {
                    viewModel.resumeGame()
                }
            }
        )

        // 4. Overlays according to game status
        when (gameState.status) {
            GameStatus.READY -> {
                GameStartOverlay(
                    highScore = gameState.highScore,
                    onStartGame = { viewModel.startGame() }
                )
            }
            GameStatus.PAUSED -> {
                GamePauseOverlay(
                    state = gameState,
                    onResume = { viewModel.resumeGame() },
                    onRestart = { viewModel.restartGame() }
                )
            }
            GameStatus.GAME_OVER -> {
                GameOverOverlay(
                    state = gameState,
                    onRestart = { viewModel.restartGame() }
                )
            }
            GameStatus.PLAYING -> {
                // Game in active motion
            }
        }
    }
}
