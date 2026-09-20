import SwiftUI

public struct GameCanvasView: View {
    public let state: GameState

    private let deepSpaceVoid = Color(red: 0.024, green: 0.035, blue: 0.075)
    private let deepSpaceNebula = Color(red: 0.059, green: 0.090, blue: 0.165)
    private let shipHullColor = Color(red: 0.886, green: 0.910, blue: 0.941)
    private let shipCockpitColor = Color(red: 0.388, green: 0.400, blue: 0.945)
    private let shipWingColor = Color(red: 0.0, green: 0.941, blue: 1.0)
    private let thrusterInnerColor = Color.white
    private let thrusterOuterColor = Color(red: 1.0, green: 0.569, blue: 0.0)
    private let shieldNeonColor = Color(red: 0.220, green: 0.741, blue: 0.973)
    private let shieldGlowColor = Color(red: 0.0, green: 0.898, blue: 1.0).opacity(0.4)
    private let bonusGoldColor = Color(red: 1.0, green: 0.718, blue: 0.012)

    public init(state: GameState) {
        self.state = state
    }

    public var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // 1. Cosmic Background Gradient
            let bgRect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(bgRect),
                with: .linearGradient(
                    Gradient(colors: [deepSpaceVoid, deepSpaceNebula, deepSpaceVoid]),
                    startPoint: CGPoint(x: w / 2, y: 0),
                    endPoint: CGPoint(x: w / 2, y: h)
                )
            )

            // 2. Starfield
            for star in state.stars {
                let starPoint = CGPoint(x: star.x * w, y: star.y * h)
                let starColor = star.isNebulaDust
                    ? Color(red: 0.22, green: 0.74, blue: 0.97).opacity(star.alpha * 0.45)
                    : Color.white.opacity(star.alpha)
                let starPath = Path(ellipseIn: CGRect(
                    x: starPoint.x - star.size / 2,
                    y: starPoint.y - star.size / 2,
                    width: star.size,
                    height: star.size
                ))
                context.fill(starPath, with: .color(starColor))
            }

            // 3. Power-Ups
            for pu in state.powerUps {
                drawPowerUp(context: context, pu: pu, w: w, h: h)
            }

            // 4. Asteroids
            for ast in state.asteroids {
                drawAsteroid(context: context, ast: ast, w: w, h: h)
            }

            // 5. Particles
            for p in state.particles {
                let particleRect = CGRect(
                    x: p.x * w - p.radius,
                    y: p.y * h - p.radius,
                    width: p.radius * 2,
                    height: p.radius * 2
                )
                context.fill(Path(ellipseIn: particleRect), with: .color(p.color.opacity(p.alpha)))
            }

            // 6. Player Ship
            if state.status != .gameOver {
                drawPlayerShip(context: context, ship: state.player, w: w, h: h)
            }
        }
        .ignoresSafeArea()
    }

    private func drawPlayerShip(context: GraphicsContext, ship: PlayerShip, w: CGFloat, h: CGFloat) {
        var shipCtx = context
        let cx = ship.x * w
        let cy = ship.y * h
        let shipSize = w * 0.13

        shipCtx.translateBy(x: cx, y: cy)
        shipCtx.rotate(by: .degrees(ship.tiltAngle))

        // Thruster flame
        let flicker = CGFloat(sin(ship.thrusterPhase) * 0.2 + 1.0)
        let flameHeight = shipSize * 0.7 * flicker
        var flamePath = Path()
        flamePath.move(to: CGPoint(x: -shipSize * 0.18, y: shipSize * 0.38))
        flamePath.addLine(to: CGPoint(x: 0, y: shipSize * 0.38 + flameHeight))
        flamePath.addLine(to: CGPoint(x: shipSize * 0.18, y: shipSize * 0.38))
        flamePath.closeSubpath()

        shipCtx.fill(
            flamePath,
            with: .linearGradient(
                Gradient(colors: [thrusterInnerColor, thrusterOuterColor, .clear]),
                startPoint: CGPoint(x: 0, y: shipSize * 0.35),
                endPoint: CGPoint(x: 0, y: shipSize * 0.38 + flameHeight)
            )
        )

        // Wings
        var leftWing = Path()
        leftWing.move(to: CGPoint(x: 0, y: -shipSize * 0.5))
        leftWing.addLine(to: CGPoint(x: -shipSize * 0.52, y: shipSize * 0.38))
        leftWing.addLine(to: CGPoint(x: -shipSize * 0.22, y: shipSize * 0.24))
        leftWing.closeSubpath()
        shipCtx.fill(leftWing, with: .color(shipWingColor))

        var rightWing = Path()
        rightWing.move(to: CGPoint(x: 0, y: -shipSize * 0.5))
        rightWing.addLine(to: CGPoint(x: shipSize * 0.52, y: shipSize * 0.38))
        rightWing.addLine(to: CGPoint(x: shipSize * 0.22, y: shipSize * 0.24))
        rightWing.closeSubpath()
        shipCtx.fill(rightWing, with: .color(shipWingColor))

        // Fuselage
        var fuselage = Path()
        fuselage.move(to: CGPoint(x: 0, y: -shipSize * 0.65))
        fuselage.addLine(to: CGPoint(x: shipSize * 0.18, y: shipSize * 0.28))
        fuselage.addLine(to: CGPoint(x: 0, y: shipSize * 0.38))
        fuselage.addLine(to: CGPoint(x: -shipSize * 0.18, y: shipSize * 0.28))
        fuselage.closeSubpath()
        shipCtx.fill(fuselage, with: .color(shipHullColor))
        shipCtx.stroke(fuselage, with: .color(Color(red: 0.059, green: 0.090, blue: 0.165)), lineWidth: 2.5)

        // Cockpit
        var cockpit = Path()
        cockpit.move(to: CGPoint(x: 0, y: -shipSize * 0.38))
        cockpit.addLine(to: CGPoint(x: shipSize * 0.09, y: -shipSize * 0.05))
        cockpit.addLine(to: CGPoint(x: 0, y: shipSize * 0.08))
        cockpit.addLine(to: CGPoint(x: -shipSize * 0.09, y: -shipSize * 0.05))
        cockpit.closeSubpath()
        shipCtx.fill(cockpit, with: .color(shipCockpitColor))

        // Specular highlight
        let highlightRect = CGRect(x: -shipSize * 0.05, y: -shipSize * 0.22, width: shipSize * 0.08, height: shipSize * 0.08)
        shipCtx.fill(Path(ellipseIn: highlightRect), with: .color(Color.white.opacity(0.8)))

        // Shield
        if state.shieldActive {
            let sRadius = shipSize * 0.82
            let pulseAlpha = state.shieldRemainingSeconds < 2.5
                ? min(max(sin(ship.thrusterPhase * 3.0) * 0.35 + 0.55, 0.2), 0.9)
                : min(max(sin(ship.thrusterPhase) * 0.15 + 0.75, 0.5), 0.95)

            let sRect = CGRect(x: -sRadius, y: -sRadius, width: sRadius * 2, height: sRadius * 2)
            let sOuterRect = CGRect(x: -sRadius * 1.08, y: -sRadius * 1.08, width: sRadius * 2.16, height: sRadius * 2.16)

            shipCtx.fill(Path(ellipseIn: sOuterRect), with: .color(shieldGlowColor.opacity(pulseAlpha * 0.4)))
            shipCtx.stroke(Path(ellipseIn: sRect), with: .color(shieldNeonColor.opacity(pulseAlpha)), lineWidth: 3.5)
        }
    }

    private func drawAsteroid(context: GraphicsContext, ast: Asteroid, w: CGFloat, h: CGFloat) {
        var astCtx = context
        let cx = ast.x * w
        let cy = ast.y * h
        let baseRadius = ast.radius * w

        astCtx.translateBy(x: cx, y: cy)
        astCtx.rotate(by: .radians(ast.rotation))

        var path = Path()
        let count = max(ast.verticesOffsets.count, 6)
        let angleStep = (2.0 * .pi) / Double(count)

        for i in 0..<count {
            let angle = Double(i) * angleStep
            let factor = i < ast.verticesOffsets.count ? ast.verticesOffsets[i] : 1.0
            let r = baseRadius * factor
            let px = CGFloat(cos(angle)) * r
            let py = CGFloat(sin(angle)) * r
            if i == 0 {
                path.move(to: CGPoint(x: px, y: py))
            } else {
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }
        path.closeSubpath()

        let baseColor: Color = ast.colorVariant == 0
            ? Color(red: 0.28, green: 0.33, blue: 0.41)
            : (ast.colorVariant == 1 ? Color(red: 0.34, green: 0.32, blue: 0.31) : Color(red: 0.25, green: 0.25, blue: 0.27))

        astCtx.fill(path, with: .color(baseColor))
        astCtx.stroke(path, with: .color(Color(red: 0.12, green: 0.16, blue: 0.23)), lineWidth: 2.0)

        // Craters
        let c1 = CGRect(x: -baseRadius * 0.3, y: -baseRadius * 0.2, width: baseRadius * 0.4, height: baseRadius * 0.4)
        astCtx.fill(Path(ellipseIn: c1), with: .color(Color.black.opacity(0.4)))
    }

    private func drawPowerUp(context: GraphicsContext, pu: PowerUp, w: CGFloat, h: CGFloat) {
        let cx = pu.x * w
        let cy = pu.y * h
        let baseRadius = pu.radius * w
        let pulse = CGFloat(sin(pu.pulsePhase) * 0.22 + 1.0)
        let curRadius = baseRadius * pulse

        let color = pu.type == .shield ? shieldNeonColor : bonusGoldColor
        let orbRect = CGRect(x: cx - curRadius, y: cy - curRadius, width: curRadius * 2, height: curRadius * 2)
        let glowRect = CGRect(x: cx - curRadius * 1.5, y: cy - curRadius * 1.5, width: curRadius * 3, height: curRadius * 3)

        context.fill(Path(ellipseIn: glowRect), with: .color(color.opacity(0.25)))
        context.fill(Path(ellipseIn: orbRect), with: .color(color))
        context.stroke(Path(ellipseIn: orbRect), with: .color(.white), lineWidth: 2.5)
    }
}
