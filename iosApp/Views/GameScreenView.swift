import SwiftUI

public struct GameScreenView: View {
    @StateObject private var viewModel = SpaceDodgerViewModel()
    @State private var lastTickTime: Date = Date()

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        ZStack {
            // 1. Core Visual Canvas
            GameCanvasView(state: viewModel.state)

            // 2. Touch Controls (Active when playing)
            if viewModel.state.status == .playing {
                GameControlsView(
                    onMoveLeft: { viewModel.moveLeft() },
                    onMoveRight: { viewModel.moveRight() },
                    onSteerTarget: { targetX in viewModel.setPlayerTargetX(targetX) }
                )
            }

            // 3. Real-time HUD
            GameHudView(
                state: viewModel.state,
                onPauseClick: {
                    if viewModel.state.status == .playing {
                        viewModel.pauseGame()
                    } else if viewModel.state.status == .paused {
                        viewModel.resumeGame()
                    }
                }
            )

            // 4. Overlays
            switch viewModel.state.status {
            case .ready:
                GameStartOverlayView(
                    highScore: viewModel.state.highScore,
                    onStartGame: { viewModel.startGame() }
                )
            case .paused:
                GamePauseOverlayView(
                    state: viewModel.state,
                    onResume: { viewModel.resumeGame() },
                    onRestart: { viewModel.restartGame() }
                )
            case .gameOver:
                GameOverOverlayView(
                    state: viewModel.state,
                    onRestart: { viewModel.restartGame() }
                )
            case .playing:
                EmptyView()
            }
        }
        .onReceive(timer) { currentTime in
            let dt = CGFloat(currentTime.timeIntervalSince(lastTickTime))
            lastTickTime = currentTime
            viewModel.onGameTick(dt: dt)
        }
        .preferredColorScheme(.dark)
    }
}
