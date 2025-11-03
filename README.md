# SpatialDefender 🎯

A fully immersive first-person wave shooter for Apple Vision Pro. Defend yourself against waves of geometric enemies using hand tracking and spatial awareness.

## 📋 Project Overview

**Spatial Defense** is a tower defense game where YOU are the tower. Enemies spawn in 360° around you and move toward your position. Use hand tracking to aim and pinch gestures to shoot them down before they reach you.

### Core Features
- 🖐️ **Hand Tracking**: Point and pinch to shoot with both hands
- 🌍 **Full Space Immersion**: 360° gameplay in volumetric space
- 💥 **Particle Effects**: Bullet trails, explosions, and power-up effects
- 🎮 **Wave-Based Progression**: Increasing difficulty with enemy variety
- 🔊 **Spatial Audio**: 3D sound positioning for immersive feedback
- ⚡ **Power-Ups**: Collectible upgrades like rapid fire and spread shot
- 🧠 **AI-Powered Adaptation**: Smart power-up drops based on your playstyle (uses Apple Intelligence)

## 🎯 Learning Objectives

This project is designed to teach:
1. visionOS 26 app architecture
2. ImmersiveSpace and Full Space mode
3. RealityKit Entity-Component-System (ECS)
4. Hand tracking with ARKit
5. Particle systems and visual effects
6. Game loop implementation
7. Spatial audio integration
8. 3D math basics (vectors, raycasting)
9. **Apple Intelligence integration** for adaptive gameplay
10. **CoreML** for on-device player behavior prediction

## 🛠️ Technical Stack

### Requirements
- **Xcode**: 26 or later
- **visionOS SDK**: 26 or later
- **Swift**: 6.2+
- **Device**: Apple Vision Pro (or visionOS Simulator)

### Frameworks Used
- **SwiftUI**: App structure and UI
- **RealityKit**: 3D rendering and Entity-Component-System
- **ARKit**: Hand tracking provider
- **AVFoundation**: Spatial audio
- **Combine**: Reactive state management
- **Apple Intelligence**: AI-powered gameplay adaptation (iOS 26+)
- **CoreML**: On-device machine learning for player behavior analysis

## 📁 Project Structure

```
SpatialDefense/
├── SpatialDefenseApp.swift          # Main app entry point
├── Views/
│   ├── GameView.swift               # Main immersive game view
│   ├── MenuView.swift               # Start menu and settings
│   └── HUDView.swift                # Score, health, wave counter
├── Systems/
│   ├── EnemySpawnSystem.swift       # Spawns enemies in waves
│   ├── MovementSystem.swift         # Moves enemies toward player
│   ├── ShootingSystem.swift         # Handles aiming and firing
│   ├── CollisionSystem.swift        # Detects bullet-enemy hits
│   ├── ParticleSystem.swift         # Manages visual effects
│   ├── WaveSystem.swift             # Controls wave progression
│   ├── ScoreSystem.swift            # Tracks score and health
│   └── AIAdaptationSystem.swift     # AI-powered gameplay adaptation
├── Components/
│   ├── EnemyComponent.swift         # Enemy data (health, type, speed)
│   ├── BulletComponent.swift        # Bullet data (damage, lifetime)
│   ├── PowerUpComponent.swift       # Power-up data (type, effect)
│   └── HealthComponent.swift        # Health tracking
├── Entities/
│   ├── EnemyFactory.swift           # Creates enemy entities
│   ├── BulletFactory.swift          # Creates bullet entities
│   ├── PowerUpFactory.swift         # Creates power-up entities
│   └── ParticleFactory.swift        # Creates particle effects
├── Utilities/
│   ├── HandTrackingManager.swift    # Manages hand tracking state
│   ├── SpatialAudioManager.swift    # Handles 3D audio
│   ├── AIBehaviorAnalyzer.swift     # Analyzes player patterns for AI
│   ├── GameConstants.swift          # Game balance constants
│   └── Extensions.swift             # Utility extensions
└── Resources/
    ├── Sounds/                      # Audio files
    └── Assets.xcassets              # App icons and images
```

## 🎮 Game Design

### Enemy Types (Simple Geometry)

| Enemy Type | Shape | Color | Speed | Health | Points |
|------------|-------|-------|-------|--------|--------|
| Basic | Cube | Red | 1.0 | 1 | 10 |
| Fast | Small Sphere | Yellow | 2.5 | 1 | 25 |
| Tank | Large Cylinder | Gray | 0.5 | 5 | 50 |

### Power-Ups

| Power-Up | Effect | Duration | Visual |
|----------|--------|----------|--------|
| Rapid Fire | 3x fire rate | 10s | Blue rotating sphere |
| Spread Shot | 5 bullets per shot | 8s | Orange rotating sphere |
| Freeze Time | 50% enemy speed | 6s | Cyan rotating sphere |
| Shield | +1 health | Instant | Green rotating sphere |

### Wave Progression

```
Wave 1: 5 Basic enemies
Wave 2: 8 Basic enemies
Wave 3: 6 Basic + 2 Fast enemies
Wave 4: 10 Basic + 3 Fast enemies
Wave 5: 8 Basic + 4 Fast + 1 Tank
...
Every 5 waves: Boss wave (10 Tanks)
```

## 🧠 AI-Powered Gameplay Adaptation

### Overview
The game uses **Apple Intelligence** and **CoreML** to analyze your playstyle in real-time and adapt the experience to keep you engaged. This is on-device ML - no data leaves your Vision Pro.

### What the AI Tracks

| Metric | What It Means | How It's Used |
|--------|---------------|---------------|
| **Accuracy Rate** | % of shots that hit enemies | Low accuracy → Spawn Spread Shot power-up |
| **Reaction Time** | Average time to shoot at new enemies | Slow reaction → Reduce enemy speed slightly |
| **Overwhelm Score** | How many enemies get close to you | High overwhelm → Spawn Freeze Time or Shield |
| **Engagement Pattern** | Which directions you focus on | Spawn enemies in neglected areas |
| **Power-Up Usage** | Which power-ups you collect/ignore | Spawn more of what you use |
| **Survival Time** | How long you last in waves | Adjust difficulty curve |

### Smart Power-Up System

The AI decides which power-up to spawn based on your current needs:

```swift
// Example AI decision logic
if player.accuracy < 0.4 && player.shotsFired > 20 {
    // Player is struggling with aim
    spawnPowerUp(.spreadShot, priority: .high)
} else if player.nearMissCount > 5 {
    // Enemies getting too close
    spawnPowerUp(.freezeTime, priority: .urgent)
} else if player.currentStreak > 10 {
    // Player is doing well, reward them
    spawnPowerUp(.rapidFire, priority: .normal)
}
```

### AI Architecture

```
Player Actions → Behavior Analyzer → CoreML Model → Adaptation Decisions
     ↓                                                        ↓
  Metrics DB  ←────────────────────────────────  Update Game Parameters
```

**Components:**

1. **AIBehaviorAnalyzer**: Collects gameplay metrics every frame
2. **PlayerProfileModel**: CoreML model trained to classify player skill/style
3. **AIAdaptationSystem**: Makes real-time decisions based on AI predictions
4. **FeedbackLoop**: Updates model based on player response to adaptations

### Privacy & Performance
- ✅ **100% on-device**: No data sent to servers
- ✅ **Lightweight**: CoreML model < 5MB
- ✅ **Efficient**: Runs inference once per second (not per frame)
- ✅ **Optional**: Players can disable AI adaptation in settings

### Technical Implementation

We'll use **Create ML** to build a simple classifier:

**Input Features:**
- Accuracy (Float)
- Reaction time (Float)
- Enemies killed per wave (Int)
- Health remaining (Int)
- Time survived (Float)

**Output:**
- Recommended power-up (Category: spread_shot, rapid_fire, freeze_time, shield, none)

**Training:**
- We'll create synthetic training data based on game design principles
- Model size: ~3MB
- Inference time: < 10ms

### Example Scenarios

**Scenario 1: Struggling Player**
```
Metrics: accuracy=25%, enemiesClose=4, health=1
AI Decision: Spawn Shield (urgent) + Freeze Time
Result: Player gets breathing room to improve
```

**Scenario 2: Skilled Player**
```
Metrics: accuracy=80%, killStreak=15, health=3
AI Decision: Increase enemy spawn rate + Spawn Rapid Fire
Result: Challenge matches skill level
```

**Scenario 3: Defensive Player**
```
Metrics: shotDelay=0.8s, favorsBackside=true
AI Decision: Spawn enemies from front + Rapid Fire power-up
Result: Encourage more aggressive play
```

## 🏗️ Development Phases

### Phase 1: Foundation ✅
- [ ] Create visionOS project
- [ ] Set up ImmersiveSpace
- [ ] Add first 3D cube
- [ ] Implement basic app navigation

### Phase 2: Hand Tracking 🖐️
- [ ] Set up HandTrackingProvider
- [ ] Track hand positions in 3D space
- [ ] Calculate aim direction from index finger
- [ ] Detect pinch gestures

### Phase 3: Enemy System 👾
- [ ] Create EnemyComponent
- [ ] Implement EnemyFactory with simple geometry
- [ ] Build EnemySpawnSystem (spawn in circle around player)
- [ ] Build MovementSystem (move toward center)
- [ ] Add health and damage system

### Phase 4: Shooting & Particles 💥
- [ ] Build ShootingSystem with raycasting
- [ ] Create BulletFactory with particle trails
- [ ] Implement CollisionSystem
- [ ] Add explosion particle effects
- [ ] Integrate spatial audio for shooting/explosions

### Phase 5: Game Loop 🎮
- [ ] Implement WaveSystem
- [ ] Build ScoreSystem (points, combos, health)
- [ ] Create HUD with SwiftUI overlay
- [ ] Add game over and restart logic
- [ ] Create power-up spawning and collection

### Phase 6: Polish & Juice ✨
- [ ] Add visual feedback (hit flashes, screen shake)
- [ ] Implement difficulty scaling
- [ ] Add menu system
- [ ] Create settings (difficulty, volume)
- [ ] Optimize performance
- [ ] Add haptic feedback (if available)

### Phase 7: AI Integration 🧠
- [ ] Create AIBehaviorAnalyzer to track metrics
- [ ] Build synthetic training dataset
- [ ] Train CoreML model with Create ML
- [ ] Implement AIAdaptationSystem
- [ ] Test AI decisions across player types
- [ ] Add AI toggle in settings

## 🎓 Key Concepts for Junior Developers

### Entity-Component-System (ECS)
RealityKit uses ECS architecture:
- **Entity**: A thing in your game (enemy, bullet, power-up)
- **Component**: Data attached to entities (position, health, speed)
- **System**: Logic that processes entities with specific components

Example:
```swift
// Entity
let enemy = ModelEntity(mesh: .generateBox(size: 0.3))

// Component
struct EnemyComponent: Component {
    var health: Int
    var speed: Float
    var type: EnemyType
}

// System (runs every frame)
func updateMovement(deltaTime: Float) {
    for entity in enemyEntities {
        if let enemy = entity.components[EnemyComponent.self] {
            // Move enemy toward player
        }
    }
}
```

### Hand Tracking Basics
```swift
// Get hand position
let handAnchor = handTracking.handAnchors[.right]
let indexTip = handAnchor.skeleton.joint(.indexFingerTip)
let thumbTip = handAnchor.skeleton.joint(.thumbTip)

// Calculate aim direction
let aimDirection = normalize(indexTip.position - headPosition)

// Detect pinch
let isPinching = distance(indexTip.position, thumbTip.position) < 0.02
```

### Particle Systems
```swift
var particleEmitter = ParticleEmitterComponent()
particleEmitter.emitterShape = .sphere
particleEmitter.birthRate = 100
particleEmitter.lifeSpan = 0.5
particleEmitter.speed = 2.0
entity.components.set(particleEmitter)
```

### AI Behavior Analysis
```swift
import CoreML

class AIBehaviorAnalyzer {
    private var shotsFired: Int = 0
    private var shotsHit: Int = 0
    private var model: PlayerProfileModel?
    
    func recordShot(hit: Bool) {
        shotsFired += 1
        if hit { shotsHit += 1 }
    }
    
    func getRecommendedPowerUp() async -> PowerUpType {
        let accuracy = Float(shotsHit) / Float(max(shotsFired, 1))
        
        // Create input for CoreML model
        let input = PlayerProfileInput(
            accuracy: accuracy,
            reactionTime: getAverageReactionTime(),
            enemiesKilled: getEnemiesKilledThisWave(),
            healthRemaining: getPlayerHealth(),
            timeSurvived: getCurrentWaveTime()
        )
        
        // Run prediction
        guard let prediction = try? await model?.prediction(from: input) else {
            return .none
        }
        
        return PowerUpType(rawValue: prediction.recommendedPowerUp) ?? .none
    }
}
```

## 🔧 Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/shortcut/SpacialDefender
cd spatial-defense
```

### 2. Open in Xcode
```bash
open SpatialDefense.xcodeproj
```

### 3. Configure Signing
- Select project in navigator
- Go to "Signing & Capabilities"
- Select your development team
- Xcode will automatically configure provisioning

### 4. Run on Simulator or Device
- Select "Apple Vision Pro" simulator or your device
- Press `Cmd + R` to build and run

## 📝 Development Guidelines

### Code Style
- Use Swift naming conventions (camelCase for variables, PascalCase for types)
- Keep functions small and focused (< 50 lines)
- Comment complex game logic
- Use meaningful variable names (`enemyHealth` not `eh`)

### Performance Targets
- **Frame Rate**: 90 FPS minimum (visionOS requirement)
- **Particle Count**: < 1000 active particles
- **Entity Count**: < 200 active entities
- **Draw Calls**: Minimize by batching similar geometry

### Testing Checklist
- [ ] Test with both hands
- [ ] Test with one hand
- [ ] Test enemy spawning at all angles
- [ ] Test wave progression
- [ ] Test power-up collection
- [ ] Test game over state
- [ ] Test performance (monitor FPS)

## 🐛 Common Issues & Solutions

### Issue: Hand tracking not working in simulator
**Solution**: Simulator has limited hand tracking. Use keyboard shortcuts:
- Hold `Option` + move mouse to simulate hand
- Click to simulate pinch

### Issue: Entities not visible
**Solution**: Check:
1. Entity has material with color/texture
2. Lighting is present in scene
3. Entity is within camera view frustum
4. Scale is appropriate (not too small/large)

### Issue: Performance drops
**Solution**:
1. Reduce particle emission rates
2. Remove entities that are far from player
3. Use object pooling for bullets/enemies
4. Profile with Instruments

### Issue: Collision not detected
**Solution**: Ensure:
1. Entities have collision components
2. Collision shapes match visual geometry
3. Raycast direction is correct
4. Collision masks are properly set

## 📚 Resources

### Official Documentation
- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit](https://developer.apple.com/documentation/realitykit)
- [ARKit Hand Tracking](https://developer.apple.com/documentation/arkit/tracking_hand_poses)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)
- [CoreML](https://developer.apple.com/documentation/coreml)
- [Create ML](https://developer.apple.com/documentation/createml)
- [Apple Intelligence](https://developer.apple.com/documentation/apple-intelligence)

### Tutorials
- [Apple's Sample Projects](https://developer.apple.com/visionos/sample-code/)
- [WWDC 2025 Sessions](https://developer.apple.com/videos/wwdc2025/)
  - "Build immersive experiences with RealityKit"
  - "Explore hand tracking in visionOS"
  - "Integrate Apple Intelligence into your apps"
  - "Build ML models with Create ML"

### Community
- [Apple Developer Forums - visionOS](https://developer.apple.com/forums/tags/visionos)
- [Swift Forums](https://forums.swift.org/)

## 🎯 Game Balance Constants

```swift
// Located in GameConstants.swift
struct GameConstants {
    // Player
    static let playerStartHealth = 3
    static let playerShootCooldown: Float = 0.2 // seconds
    
    // Enemies
    static let basicEnemySpeed: Float = 1.0
    static let fastEnemySpeed: Float = 2.5
    static let tankEnemySpeed: Float = 0.5
    
    // Spawning
    static let spawnRadius: Float = 5.0 // meters from player
    static let waveCooldown: Float = 12.0 // seconds between waves
    
    // Scoring
    static let basicEnemyPoints = 10
    static let fastEnemyPoints = 25
    static let tankEnemyPoints = 50
    static let comboMultiplier = 1.5
    
    // Power-ups
    static let powerUpSpawnChance: Float = 0.15 // 15% per wave
    static let rapidFireDuration: Float = 10.0
    static let spreadShotDuration: Float = 8.0
    static let freezeTimeDuration: Float = 6.0
}
```

## 🚀 Deployment

### TestFlight
1. Archive build in Xcode
2. Upload to App Store Connect
3. Create TestFlight build
4. Invite beta testers

### App Store
- Requires Apple Vision Pro device for testing
- Submit app review with demo video
- Provide privacy policy
- Set pricing and availability

## 🤝 Contributing

This is a learning project! Contributions welcome:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-enemy-type`)
3. Commit changes (`git commit -m 'Add laser beam enemy'`)
4. Push to branch (`git push origin feature/new-enemy-type`)
5. Open Pull Request

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- Built for Apple Vision Pro
- Created as a comprehensive learning project for visionOS development
- Special thanks to the visionOS developer community

---

## 📞 Support

Questions? Issues? 
- Open an issue on GitHub

**Good luck, and happy spatial coding!** 🥽✨
