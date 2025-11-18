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
    /// **State Management for Animation:**
    /// - @State allows SwiftUI to track changes to variables
    /// - When rotation changes, SwiftUI knows to update the view
    /// - Persists across view updates (doesn't reset each render)
    /// - Each entity gets its own rotation state for independent control
    @State private var cubeRotation: Float = 0.0      // Red cube (basicEnemy)
    @State private var sphereRotation: Float = 0.0    // Yellow sphere (fastEnemy)
    @State private var cylinderRotation: Float = 0.0  // Gray cylinder (tankEnemy)

    var body: some View {
        /// **RealityView Explanation**
        /// - SwiftUI wrapper for RealityKit 3D content
        /// - `content` parameter is a RealityViewContent - the 3D scene container
        /// - All 3D entities must be added to `content` to be visible
        /// - First closure executes once when view appears (setup)
        /// - Second `update:` closure executes every frame (for animations)
        RealityView { content in
            
            /// **AnchorEntity - Scene Root for Game Content**
            /// - **Purpose**: Acts as the root parent for all game entities (enemies, lights, indicators)
            /// - **Benefits**:
            ///   - Provides organized hierarchy instead of adding entities directly to content
            ///   - Allows moving/rotating entire scene as a group by transforming one entity
            ///   - Standard pattern for RealityKit scene organization
            ///   - Makes entity management cleaner (can remove all game content by removing anchor)
            /// - **Coordinate System**: Establishes origin point in immersive space where all game
            ///   entities position relative to
            /// - **Children**: All enemy prototypes, directional light, and circular position indicators
            let sceneAnchor = AnchorEntity()
            
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

            /// **Entity Naming for Lookup:**
            /// - Give entity a unique, descriptive name
            /// - Used to find entity later in update closure
            /// - Names are more reliable than position matching
            /// - Standard practice in game development
            basicEnemy.name = "basicEnemy"

            // MARK: Collision Component - Basic Enemy
            /// **CollisionComponent Purpose:**
            /// - Enables physics-based collision detection for this entity
            /// - Creates an invisible "hitbox" that determines when entities overlap
            /// - Essential for gameplay mechanics (shooting, enemy-player contact)
            /// - Without this, entities pass through each other without detection
            ///
            /// **Why Add Collision Now:**
            /// - Lays groundwork for Phase 5 (shooting system)
            /// - No visible changes yet, but enables future bullet-enemy detection
            /// - Better to add early than retrofit later
            ///
            /// **Performance Note:**
            /// - CollisionComponents have minimal overhead when not actively colliding
            /// - Simple shapes (box, sphere, capsule) are very efficient
            /// - Vision Pro can handle hundreds of simple collision shapes

            /// **Step 1: Define Collision Shape**
            /// - ShapeResource defines the 3D volume used for collision detection
            /// - Must match (or closely approximate) the visual geometry
            /// - Box shape for cubic enemies - most efficient for cubes
            let redEnemySize = GameConstants.Enemy.basicSize // 0.3 meters
            let redCollisionShape = ShapeResource.generateBox(
                size: .init(redEnemySize, redEnemySize, redEnemySize) // 0.3m × 0.3m × 0.3m cube
            )

            /// **Step 2: Create CollisionComponent**
            /// - Wraps the shape with collision behavior settings
            /// - `shapes`: Array of ShapeResources (can have multiple for complex objects)
            /// - `mode`: Collision detection mode
            /// - `filter`: Controls what this entity can collide with
            ///
            /// **Collision Modes Explained:**
            /// - `.default`: Full physics simulation + collision events (chosen for enemies)
            /// - `.trigger`: Collision events only, no physics (good for power-ups)
            /// - `.static`: Immovable objects (good for walls/boundaries)
            ///
            /// **Collision Filters:**
            /// - `.default`: Can collide with everything
            /// - Later: Custom filters for bullet-only or enemy-only collisions
            /// - Phase 5 will teach advanced filtering techniques
            let redCollisionComponent = CollisionComponent(
                shapes: [redCollisionShape],
                mode: .default,  // Full collision detection + physics
                filter: .default // Can collide with all entities
            )

            /// **Step 3: Attach Component to Entity**
            /// - `.components.set()` adds or replaces a component
            /// - Part of RealityKit's Entity-Component-System (ECS) architecture
            /// - Multiple components can coexist: Transform, Model, Collision, etc.
            /// - Entity now has collision detection capability
            basicEnemy.components.set(redCollisionComponent)

            /// **Adding to Anchor Hierarchy:**
            /// - sceneAnchor.addChild() makes entity a child of the anchor (not directly to content)
            /// - Entity position is now RELATIVE to anchor's position (local space, not world space)
            /// - Anchor acts as parent: moving anchor moves all children together
            /// - Better organization: all game entities under one parent for easy management
            sceneAnchor.addChild(basicEnemy)

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

            /// **Entity Naming:**
            /// - Unique name for lookup in update closure
            /// - Consistent naming convention: entityType + "Enemy"
            fastEnemy.name = "fastEnemy"

            // MARK: Collision Component - Fast Enemy
            /// **Sphere Collision Optimization:**
            /// - Sphere-to-sphere collision is THE fastest collision check in 3D physics
            /// - Single distance calculation: if (distance < radius1 + radius2) → collision!
            /// - No complex geometry comparisons needed
            /// - Perfect for fast-moving enemies that need frequent collision checks
            ///
            /// **Why Spheres Are Fast:**
            /// - Box collision: 15+ comparison operations
            /// - Sphere collision: 1 distance calculation + 1 comparison
            /// - Critical for performance when checking many bullets against many enemies

            /// **Step 1: Calculate Collision Sphere**
            /// - GameConstants.Enemy.fastSize = 0.2m (diameter of visual sphere)
            /// - Sphere radius = diameter / 2 = 0.1m
            /// - Must match visual mesh radius for accurate hit detection
            let fastEnemyRadius = GameConstants.Enemy.fastSize // 0.2m diameter
            let fastCollisionShape = ShapeResource.generateSphere(
                radius: fastEnemyRadius / 2 // 0.1m radius, matches visual mesh
            )

            /// **Step 2: Create Collision Component**
            /// - Same pattern as cube enemy but with sphere shape
            /// - Sphere collisions will be used heavily in shooting mechanics
            /// - Fast enemy + fast collision = optimal performance
            let fastCollision = CollisionComponent(
                shapes: [fastCollisionShape],
                mode: .default,  // Full physics and collision detection
                filter: .default // Can collide with all entities
            )

            /// **Step 3: Attach to Entity**
            /// - Fast enemy now has optimal collision detection
            /// - Ready for high-frequency collision checks (bullets!)
            fastEnemy.components.set(fastCollision)

            sceneAnchor.addChild(fastEnemy)

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

            /// **PhysicallyBasedMaterial (PBR) - Realistic Lighting Response:**
            /// - PBR materials respond to lighting like real-world surfaces
            /// - Uses physics-based rendering for accurate light interaction
            /// - Much more expensive than SimpleMaterial but dramatically more realistic
            /// - Shows highlights, shadows, reflections, and environmental lighting
            /// - Essential for realistic/immersive visual styles
            ///
            /// **baseColor Property:**
            /// - The underlying surface color (what color is the material?)
            /// - PhysicallyBasedMaterial.BaseColor(tint:) sets the color
            /// - Similar to SimpleMaterial's color, but interacts with lighting
            /// - Gray chosen for industrial/armored aesthetic
            ///
            /// **metallic Property:**
            /// - Controls how metallic the surface appears (0.0 = non-metal, 1.0 = pure metal)
            /// - Metallic surfaces reflect environment like mirrors
            /// - Non-metallic surfaces diffuse light (like plastic or wood)
            /// - Value of 1.0 = fully metallic (like polished steel or chrome)
            /// - Metal surfaces show colored reflections from lights
            ///
            /// **roughness Property:**
            /// - Controls surface smoothness (0.0 = mirror smooth, 1.0 = completely matte)
            /// - Smooth surfaces (low roughness) = sharp, clear reflections
            /// - Rough surfaces (high roughness) = blurry, diffused reflections
            /// - Value of 0.2 = fairly shiny with slight surface texture
            /// - Balances visual interest with clear reflections
            ///
            /// **Performance Impact:**
            /// - PBR is much more expensive than SimpleMaterial
            /// - Calculates light bounces, reflections, and surface interactions
            /// - Vision Pro can handle it, but be mindful when spawning many enemies
            /// - Future optimization: Consider SimpleMaterial for distant enemies
            //let tankMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            var tankMaterial = PhysicallyBasedMaterial()
            tankMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .gray)
            tankMaterial.metallic = .init(floatLiteral: 1.0)
            tankMaterial.roughness = .init(floatLiteral: 0.2)

            let tankEnemy = ModelEntity(mesh: tankMesh, materials: [tankMaterial])

            /// **Right-side Positioning:**
            /// - [1.5, 1, -2] = Right side of formation
            /// - Creates visual balance: Basic (left), Fast (center), Tank (right)
            /// - 1.5m spacing provides clear separation for identification
            tankEnemy.position = [1.5, 1, -2]

            /// **Entity Naming:**
            /// - Unique name for lookup in update closure
            /// - Allows independent rotation control
            tankEnemy.name = "tankEnemy"

            // MARK: Collision Component - Tank Enemy
            /// **Capsule vs Cylinder Collision:**
            /// - Visual mesh: Cylinder (flat top/bottom)
            /// - Collision shape: Capsule (rounded top/bottom)
            /// - **Why capsule is better:**
            ///   1. Smoother collision response (no sharp edges to catch on)
            ///   2. Better performance than cylinder in most physics engines
            ///   3. Approximates cylinder closely enough for gameplay
            ///   4. Prevents edge-case collision bugs with flat surfaces
            ///
            /// **When to Use Each Shape:**
            /// - Box: Cubes, rectangular objects, walls
            /// - Sphere: Round objects, simple fast checks
            /// - Capsule: Cylinders, characters, tall objects
            /// - Convex/Mesh: Only for complex static geometry (expensive!)

            /// **Step 1: Create Capsule Collision Shape**
            /// - Capsule = cylinder with hemispherical caps on top/bottom
            /// - Height: 0.4m (matches visual cylinder height)
            /// - Radius: 0.2m (matches visual cylinder radius)
            /// - Slight approximation but gameplay-accurate
            let tankSize = GameConstants.Enemy.tankSize // 0.4m
            let tankCollisionShape = ShapeResource.generateCapsule(
                height: tankSize,      // 0.4m tall
                radius: tankSize / 2   // 0.2m radius
            )

            /// **Step 2: Create Collision Component**
            /// - Tank enemy has more health, so accurate collision is important
            /// - Capsule shape ensures bullets hit reliably from all angles
            /// - No frustrating "shots passing through gaps" bugs
            let tankCollision = CollisionComponent(
                shapes: [tankCollisionShape],
                mode: .default,  // Full physics simulation enabled
                filter: .default // Collides with bullets, player, other entities
            )

            /// **Step 3: Attach to Entity**
            /// - Tank now has robust collision detection
            /// - Capsule shape handles rotation well (no edge cases)
            /// - Ready for multi-hit gameplay mechanic
            tankEnemy.components.set(tankCollision)

            sceneAnchor.addChild(tankEnemy)

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
                sceneAnchor.addChild(indicator)
            }
            
            // MARK: - Lighting Setup
            /// **Lighting in RealityKit - Core Concepts:**
            ///
            /// **Why Lighting Matters:**
            /// - Without lights, RealityKit uses only ambient lighting (flat, even illumination)
            /// - Proper lighting reveals 3D depth through shadows and highlights
            /// - Metallic materials REQUIRE lighting to show reflective properties
            /// - Lighting dramatically improves visual quality and gameplay clarity
            /// - https://developer.apple.com/documentation/realitykit/directionallight - Main API reference
            /// - https://developer.apple.com/documentation/realitykit/light - Light properties
            /// - https://developer.apple.com/documentation/realitykit/entity/transform - How to rotate lights
            ///
            /// **DirectionalLight Explained:**
            /// - Simulates distant light source (like the sun)
            /// - Emits parallel rays in one direction
            /// - Position doesn't matter (infinite distance)
            /// - Rotation/orientation DOES matter (sets ray direction)
            /// - Most efficient light type for general scene illumination
            
            /// **Step 1: Create the DirectionalLight entity**
            /// - DirectionalLight() is a convenience initializer
            /// - Creates an Entity with a Light component automatically
            /// - The Light component is configured as a directional light by default
            let mainLight = DirectionalLight()
            
            /// **Step 2: Configure light intensity**
            /// - Intensity is measured in lux (real-world light units)
            /// - Typical values:
            ///   - 500: Dim indoor lighting
            ///   - 1000: Normal indoor lighting
            ///   - 3000: Bright office lighting
            ///   - 5000: Outdoor daylight
            ///   - 10000+: Direct sunlight
            /// - Vision Pro rendering: Sweet spot usually 1000-5000
            mainLight.light.intensity = 4000
            
            /// **Step 3: Set light color (optional)**
            /// - Default is white (neutral)
            /// - Color affects mood and atmosphere
            /// - UIColor for precise control, or named colors for simplicity
            ///
            /// **Color Temperature Guide:**
            /// - Warm (sunset): UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)
            /// - Neutral (daylight): .white
            /// - Cool (moonlight): UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
            /// - Sci-fi (cyan): UIColor(red: 0.7, green: 1.0, blue: 1.0, alpha: 1.0)
            mainLight.light.color = .cyan  // Start with neutral
            
            /// **Step 4: Position the light (optional for directional)**
            /// - For DirectionalLight, position doesn't affect lighting
            /// - Set it anyway for scene organization and future reference
            /// - Common practice: Place it "above" your scene conceptually
            mainLight.position = [0, 3, 0] // 3 meters above origin
            
            /// **Step 5: Orient the light (CRITICAL for directional lights)**
            /// - Rotation determines the direction light rays travel
            /// - Think: "Where is the sun in the sky, and which way does it shine?"
            ///
            /// **Method A: Using look(at:from:relativeTo:)**
            /// - Most intuitive: "Make light look at this target from this position"
            /// - Parameters:
            ///   - at: Point in space to aim at (target)
            ///   - from: Position of the light source
            ///   - relativeTo: Parent entity (nil = world space)
            mainLight.look(
                at: [0, 0, -2],  // Target: Center of enemy formation
                from: [2, 4, 0], // Light position: Upper right front
                relativeTo: nil  // World space coordinates
            )
            
            /// **Method B: Manual rotation (alternative approach)**
            /// - More control but requires understanding of quaternions or Euler angles
            /// - Useful when you want specific angles
            /// - Example: 45° downward angle from front
            // let rotationAngle = Float.pi / 4 // 45 degrees in radians
            // mainLight.orientation = simd_quatf(angle: -rotationAngle, axis: [1, 0, 0])
            
            /// **Step 6: Add light to scene**
            /// - Same as adding any entity
            /// - Light becomes active immediately
            /// - All entities in scene will be affected
            sceneAnchor.addChild(mainLight)
            
            /// **Add Anchor to scene**
            /// - CRITICAL: The anchor and all its children are only visible after adding to content
            /// - This single line makes the entire entity hierachy rendable
            /// - All children (enemies, indicators, light= become visible when anchor is added
            /// - Without this, nothing appears in the 3D scene
            content.add(sceneAnchor)
            

            /// **Phase 2 Completion Status:**
            /// - ✅ Basic 3D entities created (cube, sphere, cylinder)
            /// - ✅ Materials and lighting implemented
            /// - ✅ Rotation animations working
            /// - ✅ Scene hierarchy with AnchorEntity
            /// - ✅ Collision components added to all enemies
            ///
            /// **Future Enhancements (Phase 3-5):**
            /// - Add hand tracking for input (Phase 3)
            /// - Implement enemy spawning and movement systems (Phase 4)
            /// - Add shooting mechanics and particle effects (Phase 5)

        } update: { content in
            // MARK: - Reactive Animation Using @State
            /// **State-Driven Animation Explanation:**
            /// - The @State rotation variables change continuously via Timer
            /// - SwiftUI detects changes and calls this update closure
            /// - We apply the current rotation values to each entity
            /// - Each entity has independent rotation control
            
            /// **Finding Entities in Anchor Hierarchy:**
            /// - First, find the sceneAnchor from content
            /// - Then search the anchor's children (not content's children)
            /// - Entities are nested: content → sceneAnchor → game entities
            /// - Must navigate hierarchy correctly to find entities
            guard let anchor = content.entities.first(where: { $0 is AnchorEntity }) else {
                return
            }

            /// **Rotate Red Cube (Basic Enemy):**
            /// - Rotates around Y-axis (vertical spin)
            /// - Speed: One full rotation every 3 seconds
            /// - Standard "spinning top" rotation
            if let basicEnemy = anchor.children.first(where: { $0.name == "basicEnemy" }) {
                basicEnemy.transform.rotation = simd_quatf(angle: cubeRotation, axis: [0, 1, 0])
            }

            /// **Rotate Yellow Sphere (Fast Enemy):**
            /// - Also rotates around Y-axis (vertical spin)
            /// - Speed: Faster than cube (one rotation per second)
            /// - Sphere rotation is less visible, but demonstrates speed difference
            if let fastEnemy = anchor.children.first(where: { $0.name == "fastEnemy" }) {
                fastEnemy.transform.rotation = simd_quatf(angle: sphereRotation, axis: [0, 1, 0])
            }

            /// **Rotate Gray Cylinder (Tank Enemy):**
            /// - Rotates around X-axis (horizontal tumbling/pitching)
            /// - Speed: Slower rotation (one rotation every 5 seconds)
            /// - Different axis creates visual variety
            /// - X-axis: [1, 0, 0] = forward/backward tumbling
            if let tankEnemy = anchor.children.first(where: { $0.name == "tankEnemy" }) {
                tankEnemy.transform.rotation = simd_quatf(angle: cylinderRotation, axis: [1, 0, 0])
            }
        }
        .onAppear {
            // MARK: - Animation Timer
            /// **Timer-Based Animation:**
            /// - Runs every 1/60th second (60 FPS)
            /// - Updates ALL @State rotation variables
            /// - Each entity has independent rotation speed
            /// - SwiftUI automatically triggers update closure
            /// - Single timer is efficient (better than multiple timers)

            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                /// **Cube Rotation (Basic Enemy):**
                /// - Full rotation (2π radians) in 3 seconds
                /// - Calculation: 2π / 3 seconds / 60 frames = 0.0349 radians per frame
                /// - Result: Moderate speed, easy to see
                cubeRotation += Float.pi * 2.0 / 3.0 / 60.0

                /// **Sphere Rotation (Fast Enemy):**
                /// - Full rotation (2π radians) in 1 second
                /// - Calculation: 2π / 1 second / 60 frames = 0.1047 radians per frame
                /// - Result: 3x faster than cube (matches "fast" enemy type)
                sphereRotation += Float.pi * 2.0 / 1.0 / 60.0

                /// **Cylinder Rotation (Tank Enemy):**
                /// - Full rotation (2π radians) in 5 seconds
                /// - Calculation: 2π / 5 seconds / 60 frames = 0.0209 radians per frame
                /// - Result: Slower, steady rotation (matches "heavy" tank feel)
                cylinderRotation += Float.pi * 2.0 / 5.0 / 60.0

                /// **Keep rotations in 0 to 2π range:**
                /// - After 360° (2π), wrap back to 0°
                /// - Prevents values from growing infinitely large
                /// - Maintains numerical precision
                if cubeRotation > Float.pi * 2 {
                    cubeRotation -= Float.pi * 2
                }
                if sphereRotation > Float.pi * 2 {
                    sphereRotation -= Float.pi * 2
                }
                if cylinderRotation > Float.pi * 2 {
                    cylinderRotation -= Float.pi * 2
                }
            }
        }
    }
}
