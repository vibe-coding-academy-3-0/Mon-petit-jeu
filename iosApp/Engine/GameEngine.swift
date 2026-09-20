import SwiftUI

public class GameEngine {
    private var nextEntityId: Int64 = 1
    private var asteroidSpawnTimer: CGFloat = 0.5
    private var powerUpSpawnTimer: CGFloat = 6.0
    private var scoreAccumulator: CGFloat = 0.0
    private var thrusterEmitTimer: CGFloat = 0.0

    public init() {}

    public func createInitialStars(count: Int = 65) -> [Star] {
        return (0..<count).map { _ in
            let tier = CGFloat.random(in: 0...1)
            let speed: CGFloat
            let size: CGFloat
            if tier < 0.5 {
                speed = CGFloat.random(in: 0.05...0.09)
                size = CGFloat.random(in: 1.5...3.0)
            } else if tier < 0.85 {
                speed = CGFloat.random(in: 0.12...0.18)
                size = CGFloat.random(in: 2.5...4.5)
            } else {
                speed = CGFloat.random(in: 0.25...0.40)
                size = CGFloat.random(in: 4.0...6.5)
            }
            let alpha = Double.random(in: 0.3...1.0)
            return Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                speed: speed,
                size: size,
                alpha: alpha,
                isNebulaDust: Bool.random() && tier > 0.8
            )
        }
    }

    public func resetTimers() {
        asteroidSpawnTimer = 0.5
        powerUpSpawnTimer = CGFloat.random(in: 6.0...10.0)
        scoreAccumulator = 0.0
        thrusterEmitTimer = 0.0
    }

    public func update(currentState: GameState, dt: CGFloat) -> GameState {
        var state = currentState

        guard state.status == .playing else {
            state.stars = updateStars(stars: state.stars, dt: dt * 0.2)
            return state
        }

        let clampedDt = min(max(dt, 0.001), 0.05)

        // 1. Difficulty progression
        let newSurvival = state.survivalSeconds + clampedDt
        state.survivalSeconds = newSurvival
        state.waveLevel = 1 + Int(newSurvival / 15.0)
        state.speedMultiplier = min(1.0 + (newSurvival * 0.025), 3.2)

        // 2. Score accumulation
        scoreAccumulator += clampedDt * 12.0 * state.speedMultiplier
        if scoreAccumulator >= 1.0 {
            let pts = Int(scoreAccumulator)
            state.score += pts
            scoreAccumulator -= CGFloat(pts)
        }

        // 3. Player steering and tilt
        let targetX = min(max(state.player.targetX, 0.08), 0.92)
        let lerpFactor = min(clampedDt * 14.0, 1.0)
        let newX = state.player.x + (targetX - state.player.x) * lerpFactor
        let deltaMove = targetX - state.player.x
        let targetTilt = Double(min(max(deltaMove * 180.0, -28.0), 28.0))
        let newTilt = state.player.tiltAngle + (targetTilt - state.player.tiltAngle) * Double(min(clampedDt * 10.0, 1.0))
        let newThrusterPhase = (state.player.thrusterPhase + Double(clampedDt) * 16.0).truncatingRemainder(dividingBy: 2.0 * .pi)

        state.player.x = newX
        state.player.tiltAngle = newTilt
        state.player.thrusterPhase = newThrusterPhase

        // 4. Shield timer
        if state.shieldActive {
            state.shieldRemainingSeconds -= clampedDt
            if state.shieldRemainingSeconds <= 0 {
                state.shieldActive = false
                state.shieldRemainingSeconds = 0
            }
        }

        // 5. Starfield parallax
        state.stars = updateStars(stars: state.stars, dt: clampedDt * state.speedMultiplier)

        // 6. Asteroid Spawning
        asteroidSpawnTimer -= clampedDt
        let spawnInterval = min(max(1.1 / (1.0 + newSurvival * 0.04), 0.28), 1.2)
        if asteroidSpawnTimer <= 0 {
            asteroidSpawnTimer = spawnInterval + CGFloat.random(in: 0...(spawnInterval * 0.4))
            state.asteroids.append(createRandomAsteroid(speedMultiplier: state.speedMultiplier))
        }

        // 7. Power-Up Spawning
        powerUpSpawnTimer -= clampedDt
        if powerUpSpawnTimer <= 0 {
            powerUpSpawnTimer = CGFloat.random(in: 11.0...18.0)
            let type: PowerUpType = Bool.random() ? .shield : .bonusScore
            state.powerUps.append(
                PowerUp(
                    id: getNextId(),
                    x: CGFloat.random(in: 0.1...0.9),
                    y: -0.05,
                    radius: 0.038,
                    speed: 0.22 * (1.0 + (state.speedMultiplier - 1.0) * 0.3),
                    type: type
                )
            )
        }

        // 8. Asteroids movement
        var movedAsteroids: [Asteroid] = []
        for var ast in state.asteroids {
            ast.y += ast.speed * clampedDt
            ast.rotation += ast.rotationSpeed * Double(clampedDt)
            if ast.y > 1.08 {
                state.asteroidsDodged += 1
                state.score += 20
            } else {
                movedAsteroids.append(ast)
            }
        }

        // 9. Power-ups movement
        var movedPowerUps: [PowerUp] = []
        for var pu in state.powerUps {
            pu.y += pu.speed * clampedDt
            pu.pulsePhase = (pu.pulsePhase + Double(clampedDt) * 6.0).truncatingRemainder(dividingBy: 2.0 * .pi)
            if pu.y <= 1.08 {
                movedPowerUps.append(pu)
            }
        }

        // 10. Thruster sparks
        thrusterEmitTimer += clampedDt
        if thrusterEmitTimer >= 0.04 {
            thrusterEmitTimer = 0
            let flameColor: Color = Bool.random() ? Color(red: 0.0, green: 0.9, blue: 1.0) : Color(red: 1.0, green: 0.57, blue: 0.0)
            state.particles.append(
                Particle(
                    id: getNextId(),
                    x: state.player.x + CGFloat.random(in: -0.01...0.01),
                    y: state.player.y + 0.04,
                    vx: CGFloat.random(in: -0.02...0.02),
                    vy: CGFloat.random(in: 0.35...0.55),
                    color: flameColor,
                    radius: CGFloat.random(in: 3.5...6.5),
                    alpha: 0.85,
                    life: 0.35,
                    maxLife: 0.35
                )
            )
        }

        // 11. Collision: Player vs Power-ups
        var remainingPowerUps: [PowerUp] = []
        let playerRadius: CGFloat = 0.045
        for pu in movedPowerUps {
            let dist = hypot(state.player.x - pu.x, state.player.y - pu.y)
            if dist < (playerRadius + pu.radius) {
                state.powerUpsCollected += 1
                switch pu.type {
                case .shield:
                    state.shieldActive = true
                    state.shieldRemainingSeconds = 8.0
                    state.score += 150
                    state.floatingTexts.append(
                        FloatingText(
                            id: getNextId(),
                            text: "BOUCLIER ACTIF!",
                            x: state.player.x,
                            y: state.player.y - 0.06,
                            color: Color(red: 0.0, green: 0.9, blue: 1.0)
                        )
                    )
                    spawnParticles(&state.particles, x: pu.x, y: pu.y, color: Color(red: 0.0, green: 0.9, blue: 1.0), count: 20)
                case .bonusScore:
                    state.score += 250
                    state.floatingTexts.append(
                        FloatingText(
                            id: getNextId(),
                            text: "+250 BONUS!",
                            x: state.player.x,
                            y: state.player.y - 0.06,
                            color: Color(red: 1.0, green: 0.84, blue: 0.0)
                        )
                    )
                    spawnParticles(&state.particles, x: pu.x, y: pu.y, color: Color(red: 1.0, green: 0.84, blue: 0.0), count: 22)
                }
            } else {
                remainingPowerUps.append(pu)
            }
        }
        state.powerUps = remainingPowerUps

        // 12. Collision: Player vs Asteroids
        var remainingAsteroids: [Asteroid] = []
        var gameOver = false
        let hitRadius: CGFloat = state.shieldActive ? 0.075 : 0.045

        for ast in movedAsteroids {
            let dist = hypot(state.player.x - ast.x, state.player.y - ast.y)
            let threshold = hitRadius + (ast.radius * 0.82)
            if dist < threshold {
                if state.shieldActive {
                    state.score += 60
                    state.floatingTexts.append(
                        FloatingText(
                            id: getNextId(),
                            text: "DÉVIÉ! +60",
                            x: ast.x,
                            y: ast.y,
                            color: Color(red: 0.22, green: 0.74, blue: 0.97)
                        )
                    )
                    spawnParticles(&state.particles, x: ast.x, y: ast.y, color: Color(red: 0.0, green: 0.94, blue: 1.0), count: 24)
                    state.shieldRemainingSeconds = max(state.shieldRemainingSeconds - 1.2, 0.5)
                } else {
                    gameOver = true
                    spawnParticles(&state.particles, x: state.player.x, y: state.player.y, color: Color(red: 1.0, green: 0.2, blue: 0.4), count: 40)
                    spawnParticles(&state.particles, x: ast.x, y: ast.y, color: Color(red: 1.0, green: 0.62, blue: 0.11), count: 25)
                }
            } else {
                remainingAsteroids.append(ast)
            }
        }
        state.asteroids = remainingAsteroids

        if gameOver {
            state.status = .gameOver
        }

        // 13. Update Particles
        var liveParticles: [Particle] = []
        for var p in state.particles {
            p.life -= clampedDt
            if p.life > 0 {
                p.x += p.vx * clampedDt
                p.y += p.vy * clampedDt
                p.alpha = Double(min(max(p.life / p.maxLife, 0.0), 1.0))
                liveParticles.append(p)
            }
        }
        state.particles = liveParticles

        // 14. Update Floating Texts
        var liveTexts: [FloatingText] = []
        for var ft in state.floatingTexts {
            ft.life -= clampedDt
            if ft.life > 0 {
                ft.y -= clampedDt * 0.045
                liveTexts.append(ft)
            }
        }
        state.floatingTexts = liveTexts

        state.highScore = max(state.highScore, state.score)
        return state
    }

    private func updateStars(stars: [Star], dt: CGFloat) -> [Star] {
        return stars.map { s in
            var star = s
            star.y += star.speed * dt
            if star.y > 1.0 {
                star.y = 0.0
                star.x = CGFloat.random(in: 0...1)
            }
            return star
        }
    }

    private func createRandomAsteroid(speedMultiplier: CGFloat) -> Asteroid {
        let sizeRoll = CGFloat.random(in: 0...1)
        let radius: CGFloat
        if sizeRoll < 0.45 {
            radius = CGFloat.random(in: 0.028...0.036)
        } else if sizeRoll < 0.85 {
            radius = CGFloat.random(in: 0.042...0.054)
        } else {
            radius = CGFloat.random(in: 0.062...0.077)
        }

        let baseSpeed: CGFloat
        if radius < 0.035 {
            baseSpeed = CGFloat.random(in: 0.42...0.54)
        } else if radius < 0.055 {
            baseSpeed = CGFloat.random(in: 0.32...0.41)
        } else {
            baseSpeed = CGFloat.random(in: 0.23...0.30)
        }

        let rotSpeed = Double.random(in: -2.0...2.0)
        let vertices = (0..<8).map { _ in CGFloat.random(in: 0.78...1.22) }

        return Asteroid(
            id: getNextId(),
            x: CGFloat.random(in: 0.08...0.92),
            y: -0.08,
            radius: radius,
            speed: baseSpeed * speedMultiplier,
            rotation: Double.random(in: 0...6.28),
            rotationSpeed: rotSpeed,
            shapeSeed: Int.random(in: 0...1000),
            verticesOffsets: vertices,
            colorVariant: Int.random(in: 0...2)
        )
    }

    private func spawnParticles(_ list: inout [Particle], x: CGFloat, y: CGFloat, color: Color, count: Int) {
        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2.0 * .pi))
            let speed = CGFloat.random(in: 0.15...0.45)
            let life = CGFloat.random(in: 0.4...0.9)
            list.append(
                Particle(
                    id: getNextId(),
                    x: x,
                    y: y,
                    vx: cos(angle) * speed,
                    vy: sin(angle) * speed,
                    color: color,
                    radius: CGFloat.random(in: 3...7),
                    alpha: 1.0,
                    life: life,
                    maxLife: life
                )
            )
        }
    }

    private func getNextId() -> Int64 {
        nextEntityId += 1
        return nextEntityId
    }
}
