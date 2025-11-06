import SwiftUI
import RealityKit
import Foundation // provides access to mathematical constants like .pi


/// **ImmersiveView** - The 3D game environment for SpatialDefender
///
/// **Architecture Role:**
/// - Primary 3D rendering container using RealityView
/// - Demonstrates enemy prototype creation for future factory patterns
/// - Integrates with GameConstants for consistent sizing and behavior
/// - Serves as testing ground for 3D positioning and materials
///
/// **Learning Objectives:**
/// 1. **RealityView Usage**: Understanding SwiftUI → RealityKit bridge
/// 2. **Entity-Component System**: How 3D objects are composed
/// 3. **Mesh Generation**: Different 3D primitive shapes
/// 4. **Material Systems**: Visual appearance and rendering properties
/// 5. **3D Coordinate System**: Spatial positioning in visionOS
/// 6. **GameConstants Integration**: Centralized configuration usage
///
/// **Performance Considerations:**
/// - Each ModelEntity has rendering overhead
/// - Materials affect GPU performance (metallic vs simple)
/// - Position calculations happen on main thread
/// - Future optimization: Entity pooling and culling systems
struct ImmersiveView: View {
    var body: some View {
        /// **RealityView Explanation**
        /// - SwiftUI wrapper for RealityKit 3D content
        /// - `content` parameter is a RealityViewContent - the 3D scene container
        /// - All 3D entities must be added to `content` to be visible
        /// - Closure executes once when view appears (not on every frame)
        RealityView { content in
            /// **MeshResource.generateBox() Explanation:**
            /// - Creates cubic 3D geometry with equal width/height/depth
            /// - `size` parameter: Float value in meters (real-world scale)
            /// - GameConstants.Enemy.basicSize = 0.3 meters (30 centimeters)
            /// - Returns MeshResource: GPU-optimized vertex data
            let basicMesh = MeshResource.generateBox(size: GameConstants.Enemy.basicSize)

            /// **SimpleMaterial Explanation:**
            /// - Basic material type for solid colors without complex shading
            /// - `color`: SwiftUI Color type (.red, .blue, etc.)
            /// - `isMetallic: false`: Non-reflective surface, faster rendering
            /// - Alternative: PhysicallyBasedMaterial for realistic lighting
            let material = SimpleMaterial(color: .red, isMetallic: false)

            // MARK: - Basic Enemy Prototype (Red Cube)
            /// **Purpose**: Most common enemy type with balanced stats
            /// **Game Design**: Players see this enemy most frequently
            /// **Visual Identity**: Red color = danger, cube = basic/common
            /// **ModelEntity Creation:**
            /// - Combines mesh (shape) + materials (appearance) = visible object
            /// - Entity-Component pattern: Entity holds Components (mesh, material, transform)
            /// - Multiple materials possible: [material1, material2] for multi-colored objects
            let basicEnemy = ModelEntity(mesh: basicMesh, materials: [material])

            /// **3D Positioning Explanation:**
            /// - Coordinate System: Right-handed (standard in 3D graphics)
            ///   - X-axis: Left (-) to Right (+)
            ///   - Y-axis: Down (-) to Up (+)
            ///   - Z-axis: Away (-) to Toward (+) user
            /// - Position units: Meters (real-world scale for Vision Pro)
            /// - [-1.5, 1, -2] = 1.5m left, 1m up, 2m away from user
            /// - SIMD3<Float> format: [x, y, z] array notation
            basicEnemy.position = [-1.5, 1, -2]


            /// **Adding to Scene:**
            /// - content.add() makes entity visible in 3D space
            /// - Entity becomes child of RealityView's root entity
            /// - Participates in rendering, collision detection, etc.
            content.add(basicEnemy)

            // MARK: - Fast Enemy Prototype (Yellow Sphere)
            /// **Purpose**: Quick, agile enemy that's harder to hit
            /// **Game Design**: Higher difficulty, higher point reward
            /// **Visual Identity**: Yellow = speed/energy, sphere = movement/agility

            /// **MeshResource.generateSphere() Explanation:**
            /// - Creates spherical 3D geometry with specified radius
            /// - `radius`: Distance from center to surface (half the diameter)
            /// - GameConstants.Enemy.fastSize = 0.2m, so radius = 0.1m
            /// - More vertices than cube = slightly higher rendering cost
            /// - Smooth surface = better for movement/rolling animations
            let fastMesh = MeshResource.generateSphere(radius: GameConstants.Enemy.fastSize / 2) // since its the radius

            /// **Color Psychology in Game Design:**
            /// - Yellow: Associated with speed, energy, caution
            /// - High contrast against typical backgrounds
            /// - Easily distinguishable from red (basic) and gray (tank)
            let fastMaterial = SimpleMaterial(color: .yellow, isMetallic: false)

            let fastEnemy = ModelEntity(mesh: fastMesh, materials: [fastMaterial])

            /// **Center Positioning Strategy:**
            /// - [0, 1, -2] = Dead center, eye level, comfortable viewing distance
            /// - Y=1: Above ground plane, matches user's standing eye level
            /// - Z=-2: Close enough to see details, far enough to not feel invasive
            fastEnemy.position = [0, 1, -2]
            content.add(fastEnemy)

            // MARK: - Tank Enemy Prototype (Gray Cylinder)
            /// **Purpose**: High-health enemy requiring multiple hits
            /// **Game Design**: Slow but tough, creates tactical decisions
            /// **Visual Identity**: Gray = armor/metal, cylinder = tank/industrial

            /// **MeshResource.generateCylinder() Explanation:**
            /// - Creates cylindrical 3D geometry (like a can or barrel)
            /// - `height`: Vertical dimension along Y-axis
            /// - `radius`: Distance from center axis to curved surface
            /// - Cylinder orientation: Y-axis is up (default behavior)
            /// - Good for representing mechanical/armored objects
            let tankMesh = MeshResource.generateCylinder(
                height: GameConstants.Enemy.tankSize, // 0.4m tall
                radius: GameConstants.Enemy.tankSize / 2  // 0.2m radius
            )

            /// **Metallic Material Properties:**
            /// - `isMetallic: true`: Reflects environment, appears shiny
            /// - More expensive rendering due to reflection calculations
            /// - Gray + metallic = realistic metal appearance
            /// - Communicates "armored" or "industrial" to player
            let tankMaterial = SimpleMaterial(color: .gray, isMetallic: true)

            let tankEnemy = ModelEntity(mesh: tankMesh, materials: [tankMaterial])

            /// **Right-side Positioning:**
            /// - [1.5, 1, -2] = Right side of formation
            /// - Creates visual balance: Basic (left), Fast (center), Tank (right)
            /// - 1.5m spacing provides clear separation for identification
            tankEnemy.position = [1.5, 1, -2]
            content.add(tankEnemy)

            // MARK: - Advanced: Circular Formation Demo
            /// **Purpose**: Demonstrate mathematical positioning for future spawning
            /// **Learning**: Trigonometry in game development
            /// **Application**: Enemy spawn locations, patrol paths, formations

            /// **Circle Math Explanation:**
            /// - Circle formula: x = radius × cos(angle), y = radius × sin(angle)
            /// - Angle in radians: 0 to 2π (0° to 360°)
            /// - Even distribution: divide 2π by number of positions

            let circleRadius: Float = 3.0 // 3 meter radius circle
            let enemyCount = 6 // 6 position around circle

            /// **For Loop with Trigonometry:**
            /// - Iterate through each position index (0, 1, 2, 3, 4, 5)
            /// - Calculate angle for even spacing
            /// - Convert angle to X,Z coordinates using trigonometry
            for i in 0..<enemyCount {
                /// **Angle Calculation:**
                /// - 2π radians = full circle (360°)
                /// - Divide by enemyCount for even spacing
                /// - Float() conversion needed for mathematical operations
                let angle = Float(i) * (2 * .pi / Float(enemyCount))

                /// **Coordinate Conversion:**
                /// - cos(angle): X-axis position (left/right)
                /// - sin(angle): Z-axis position (forward/back)
                /// - Y-axis: Fixed at 0.5m (lower than main enemies)
                let x = circleRadius * cos(angle)
                let z = circleRadius * sin(angle) - 5  // -5 offset: further from user

                /// **Visual Indicators:**
                /// - Small blue cubes to visualize circular mathematics
                /// - 0.1m size: Small enough to not interfere with main enemies
                /// - Blue color: Distinct from enemy colors
                let indicatorMesh = MeshResource.generateBox(size: 0.1)
                let indicatorMaterial = SimpleMaterial(color: .blue, isMetallic: false)
                let indicator = ModelEntity(mesh: indicatorMesh, materials: [indicatorMaterial])
                indicator.position = [x, 0.5, z]
                content.add(indicator)
            }
            /// **Future Enhancements (Phase 2 continuation):**
            /// - Add collision components for hit detection
            /// - Implement rotation animations
            /// - Add particle effects for visual appeal
            /// - Create anchor entity for organized hierarchy
            /// - Add lighting for better visual depth
        }
    }
}
