import Foundation
import simd

/// **GameConstants** - Centralized configuration for all game mechanics
///
/// **Learning Concepts:**
/// - **Constants Management**: Single source of truth for game values
/// - **Performance Optimization**: Compile-time constants vs runtime variables
/// - **Game Balance**: Tweakable values for difficulty tuning
/// - **Team Collaboration**: Designers can modify values without code changes
///
/// **Architecture Role:**
/// - Referenced by all Systems (EnemySpawnSystem, MovementSystem, etc.)
/// - Used by Factories for consistent entity creation
/// - Imported by game logic classes for consistent behavior
///
/// **Usage Example:**
/// ```swift
/// // In EnemyFactory
/// enemy.speed = GameConstants.Enemy.basicSpeed
///
/// // In ScoreSystem
/// score += GameConstants.Scoring.basicEnemyPoints
/// ```
struct GameConstants {
    // MARK: - Player Configuration
    /// **Player mechanics and capabilities**
    /// These values control the player's abilities and constraints
    struct Player {
        /// Maximum health the player starts with
        /// - Note: Affects game difficulty - higher = easier
        static let startingHealth: Int = 3

        /// Minimum time between shots in seconds
        /// - Note: Lower = faster shooting, higher = more strategic
        static let shootingCooldown: Float = 0.2

        /// Maximum distance bullets travel before disappearing (meters)
        /// - Note: Prevents infinite bullets, affects performance
        static let bulletRange: Float = 10.0
    }

    // MARK: - Enemy Configuration
    /// **Enemy types and their characteristics**
    /// Each enemy type has distinct properties for varied gameplay
    struct Enemy {
        // Basic Enemy (Red Cube) - Most common, balanced stats
        static let basicHealth: Int = 1
        static let basicSpeed: Float = 1.0      // meters per second
        static let basicSize: Float = 0.3       // meters

        // Fast Enemy (Yellow Sphere) - Quick but fragile
        static let fastHealth: Int = 1
        static let fastSpeed: Float = 2.5       // 2.5x faster than basic
        static let fastSize: Float = 0.2        // Smaller = harder to hit

        // Tank Enemy (Gray Cylinder) - Slow but tough
        static let tankHealth: Int = 5
        static let tankSpeed: Float = 0.5       // Half speed of basic
        static let tankSize: Float = 0.4        // Larger = easier to hit
    }

    // MARK: - Spawning Configuration
    /// **How and where enemies appear**
    /// Controls the spatial distribution and timing of enemy spawns
    struct Spawning {
        /// Distance from player where enemies spawn (meters)
        /// - Note: Too close = overwhelming, too far = boring
        static let spawnRadius: Float = 5.0

        /// Time between waves in seconds
        /// - Note: Gives player breathing room between challenges
        static let waveCooldown: Float = 3.0

        /// Random variation in spawn positions (meters)
        /// - Note: Prevents predictable spawn patterns
        static let spawnRandomization: Float = 0.5

        /// Height range for enemy spawns (meters)
        /// - Note: Creates 3D gameplay vs flat 2D spawning
        static let spawnHeightRange: ClosedRange<Float> = -1.0...2.0
    }

    // MARK: - Scoring System
    /// **Point values and combo mechanics**
    /// Rewards players for skill and consecutive hits
    struct Scoring {
        // Base point values for different enemy types
        static let basicEnemyPoints: Int = 10
        static let fastEnemyPoints: Int = 25      // Higher reward for harder target
        static let tankEnemyPoints: Int = 50      // Highest reward for toughest enemy

        // Combo system - rewards consecutive hits without missing
        static let comboMultiplier: Float = 1.5   // 50% bonus per combo level
        static let maxComboLevel: Int = 5         // Cap to prevent infinite scaling
        static let comboResetDelay: Float = 2.0   // Seconds without hit = combo lost
    }

    // MARK: - Power-Up Configuration
    /// **Special abilities and their effects**
    /// Temporary boosts that enhance player capabilities
    struct PowerUps {
        /// Chance of power-up spawning after wave completion (0.0 - 1.0)
        static let spawnChance: Float = 0.15      // 15% chance per wave

        // Power-up effect durations in seconds
        static let rapidFireDuration: Float = 10.0    // Triple fire rate
        static let spreadShotDuration: Float = 8.0     // Five bullets per shot
        static let freezeTimeDuration: Float = 6.0     // Slow enemy movement 50%

        // Power-up visual properties
        static let powerUpSize: Float = 0.25           // meters
        static let rotationSpeed: Float = 2.0          // radians per second
    }

    // MARK: - Audio Configuration
    /// **Spatial audio settings for immersion**
    /// 3D positioned sound effects enhance the spatial experience
    struct Audio {
        /// Master volume multiplier (0.0 - 1.0)
        static let masterVolume: Float = 0.8

        /// Volume for different sound categories
        static let shootingVolume: Float = 0.6
        static let explosionVolume: Float = 0.8
        static let powerUpVolume: Float = 0.5
        static let backgroundMusicVolume: Float = 0.3

        /// Maximum distance for spatial audio falloff (meters)
        static let audioMaxDistance: Float = 15.0
    }

    // MARK: - Performance Optimization
    /// **Limits to maintain 90fps on Vision Pro**
    /// visionOS requires consistent high framerate for comfort
    struct Performance {
        /// Maximum entities active simultaneously
        static let maxActiveEntities: Int = 200

        /// Maximum particles per emitter
        static let maxParticlesPerEmitter: Int = 100

        /// Entity cleanup distance (meters from player)
        /// - Note: Removes distant entities to free memory
        static let entityCleanupDistance: Float = 20.0

        /// Frame rate target (Vision Pro requirement)
        static let targetFrameRate: Int = 90
    }

    // MARK: - Physics & Collision
    /// **3D physics simulation parameters**
    /// Controls how objects interact in the spatial environment
    struct Physics {
        /// Bullet speed in meters per second
        static let bulletSpeed: Float = 15.0

        /// Gravity acceleration (if needed for future features)
        static let gravity: Float = -9.8

        /// Collision detection tolerance (meters)
        /// - Note: Smaller = more precise, larger = more forgiving
        static let collisionTolerance: Float = 0.1
    }

    // MARK: - Visual Effects
    /// **Particle systems and visual feedback**
    /// Enhance game feel with satisfying visual responses
    struct Effects {
        /// Bullet trail particle count
        static let bulletTrailParticles: Int = 20

        /// Explosion particle count
        static let explosionParticles: Int = 50

        /// Screen flash duration for hits (seconds)
        static let hitFlashDuration: Float = 0.1

        /// Screen shake intensity for impacts
        static let screenShakeIntensity: Float = 0.02   // meters
    }
}

// MARK: - Computed Properties
/// **Derived values calculated from base constants**
/// These provide convenience while maintaining single source of truth
extension GameConstants {
    /// **Wave progression formulas**
    /// Calculates difficulty scaling based on wave number
    struct WaveProgression {
        /// Calculate enemy count for given wave
        /// - Parameter waveNumber: Current wave (1-based)
        /// - Returns: Total enemies to spawn this wave
        static func enemyCount(for waveNumber: Int) -> Int {
            return max(5, 3 + waveNumber * 2)  // Minimum 5, increases by 2 per wave
        }
        
        /// Calculate enemy speed multiplier for wave
        /// - Parameter waveNumber: Current wave (1-based)
        /// - Returns: Speed multiplier (1.0 = normal speed)
        static func speedMultiplier(for waveNumber: Int) -> Float {
            return 1.0 + (Float(waveNumber) * 0.1)  // 10% faster each wave
        }
    }
}
