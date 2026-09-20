import SwiftUI

public enum PowerUpType: String, CaseIterable {
    case shield
    case bonusScore
}

public struct PlayerShip {
    public var x: CGFloat = 0.5
    public var y: CGFloat = 0.85
    public var width: CGFloat = 0.12
    public var height: CGFloat = 0.08
    public var targetX: CGFloat = 0.5
    public var tiltAngle: Double = 0.0
    public var thrusterPhase: Double = 0.0

    public init(
        x: CGFloat = 0.5,
        y: CGFloat = 0.85,
        width: CGFloat = 0.12,
        height: CGFloat = 0.08,
        targetX: CGFloat = 0.5,
        tiltAngle: Double = 0.0,
        thrusterPhase: Double = 0.0
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.targetX = targetX
        self.tiltAngle = tiltAngle
        self.thrusterPhase = thrusterPhase
    }
}

public struct Asteroid: Identifiable {
    public let id: Int64
    public var x: CGFloat
    public var y: CGFloat
    public var radius: CGFloat
    public var speed: CGFloat
    public var rotation: Double
    public var rotationSpeed: Double
    public var shapeSeed: Int
    public var verticesOffsets: [CGFloat]
    public var colorVariant: Int

    public init(
        id: Int64,
        x: CGFloat,
        y: CGFloat,
        radius: CGFloat,
        speed: CGFloat,
        rotation: Double = 0,
        rotationSpeed: Double = 1.5,
        shapeSeed: Int = 0,
        verticesOffsets: [CGFloat] = [],
        colorVariant: Int = 0
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.radius = radius
        self.speed = speed
        self.rotation = rotation
        self.rotationSpeed = rotationSpeed
        self.shapeSeed = shapeSeed
        self.verticesOffsets = verticesOffsets
        self.colorVariant = colorVariant
    }
}

public struct PowerUp: Identifiable {
    public let id: Int64
    public var x: CGFloat
    public var y: CGFloat
    public var radius: CGFloat
    public var speed: CGFloat
    public var type: PowerUpType
    public var pulsePhase: Double

    public init(
        id: Int64,
        x: CGFloat,
        y: CGFloat,
        radius: CGFloat = 0.04,
        speed: CGFloat = 0.25,
        type: PowerUpType,
        pulsePhase: Double = 0
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.radius = radius
        self.speed = speed
        self.type = type
        self.pulsePhase = pulsePhase
    }
}

public struct Particle: Identifiable {
    public let id: Int64
    public var x: CGFloat
    public var y: CGFloat
    public var vx: CGFloat
    public var vy: CGFloat
    public var color: Color
    public var radius: CGFloat
    public var alpha: Double
    public var life: CGFloat
    public var maxLife: CGFloat

    public init(
        id: Int64,
        x: CGFloat,
        y: CGFloat,
        vx: CGFloat,
        vy: CGFloat,
        color: Color,
        radius: CGFloat,
        alpha: Double,
        life: CGFloat,
        maxLife: CGFloat
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.color = color
        self.radius = radius
        self.alpha = alpha
        self.life = life
        self.maxLife = maxLife
    }
}

public struct Star: Identifiable {
    public let id: UUID = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var speed: CGFloat
    public var size: CGFloat
    public var alpha: Double
    public var isNebulaDust: Bool

    public init(
        x: CGFloat,
        y: CGFloat,
        speed: CGFloat,
        size: CGFloat,
        alpha: Double,
        isNebulaDust: Bool = false
    ) {
        self.x = x
        self.y = y
        self.speed = speed
        self.size = size
        self.alpha = alpha
        self.isNebulaDust = isNebulaDust
    }
}

public struct FloatingText: Identifiable {
    public let id: Int64
    public let text: String
    public var x: CGFloat
    public var y: CGFloat
    public let color: Color
    public var life: CGFloat
    public let maxLife: CGFloat

    public init(
        id: Int64,
        text: String,
        x: CGFloat,
        y: CGFloat,
        color: Color,
        life: CGFloat = 1.0,
        maxLife: CGFloat = 1.0
    ) {
        self.id = id
        self.text = text
        self.x = x
        self.y = y
        self.color = color
        self.life = life
        self.maxLife = maxLife
    }
}
