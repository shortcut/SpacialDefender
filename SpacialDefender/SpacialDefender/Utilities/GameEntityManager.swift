import SwiftUI
import RealityKit

/// **GameEntityManager** - Central utility for entity lifecycle management
///
/// **Architecture Role:**
/// - Provides safe, reusable entity removal functionality
/// - Handles complex entity hierarchies with recursive cleanup
/// - Prevents memory leaks by ensuring complete entity removal
/// - Foundation for future entity management features (spawning, pooling, tracking)
///
/// **Design Pattern:**
/// - Utility struct with static methods (stateless operations)
/// - No instantiation needed - call methods directly
/// - Follows Swift convention for utility namespaces
///
/// **Usage Example:**
/// ```swift
/// // Remove a single enemy
/// GameEntityManager.remove(enemyEntity)
///
/// // Remove multiple entities
/// enemies.forEach { GameEntityManager.remove($0) }
/// ```
///
/// **Future Enhancements:**
/// - Entity pooling system (reuse instead of destroy)
/// - Entity spawning factory integration
/// - Active entity tracking and queries
/// - Performance metrics (entities created/destroyed)
struct GameEntityManager {

    // MARK: - Entity Removal

    /// Recursively removes an entity and all of its descendants from the scene graph.
    ///
    /// **How It Works:**
    /// 1. Validates entity has a parent (safety check)
    /// 2. Recursively removes all child entities (depth-first traversal)
    /// 3. Removes the entity from its parent
    /// 4. Entity becomes eligible for garbage collection
    ///
    /// **Why Recursive Removal Matters:**
    /// - Entities can have complex hierarchies (enemy → particle effects → sub-emitters)
    /// - Children must be removed before parent to prevent orphaned entities
    /// - Orphaned entities stay in memory forever (memory leak!)
    /// - Depth-first ensures proper cleanup order
    ///
    /// **Algorithm: Depth-First Traversal**
    /// ```
    /// Example hierarchy:
    ///   Enemy
    ///   ├─ ParticleEffect1
    ///   │  └─ SubEmitter
    ///   └─ ParticleEffect2
    ///
    /// Removal order:
    ///   1. SubEmitter (deepest first)
    ///   2. ParticleEffect1
    ///   3. ParticleEffect2
    ///   4. Enemy (parent last)
    /// ```
    ///
    /// **Performance Characteristics:**
    /// - Time Complexity: O(n) where n = total entities in subtree
    /// - Space Complexity: O(d) where d = depth of tree (call stack)
    /// - Very efficient: Simple entities removed in microseconds
    ///
    /// **Safety Features:**
    /// - Gracefully handles entities with no parent (early return)
    /// - No crashes if entity already removed
    /// - Safe to call multiple times on same entity
    ///
    /// **When to Use:**
    /// - Enemy destroyed by bullet (Phase 5)
    /// - Bullet expires after lifetime (Phase 5)
    /// - Power-up collected by player (Phase 6)
    /// - Game state reset (Phase 6)
    /// - Entity moves out of playable bounds
    ///
    /// **Memory Management:**
    /// - Removal from scene severs parent-child relationship
    /// - Entity still exists in memory if referenced elsewhere
    /// - Swift's ARC handles final cleanup when all references gone
    /// - Best practice: Remove from tracking arrays too
    ///
    /// **Example Usage Patterns:**
    ///
    /// *Pattern 1: Single Entity Removal*
    /// ```swift
    /// // Bullet hits enemy
    /// GameEntityManager.remove(enemyEntity)
    /// ```
    ///
    /// *Pattern 2: Conditional Bulk Removal*
    /// ```swift
    /// // Remove all off-screen enemies
    /// let offscreenEnemies = enemies.filter { isOffscreen($0) }
    /// offscreenEnemies.forEach { GameEntityManager.remove($0) }
    /// ```
    ///
    /// *Pattern 3: Removal with Tracking Array Cleanup*
    /// ```swift
    /// // Remove from scene AND tracking array
    /// GameEntityManager.remove(enemy)
    /// activeEnemies.removeAll { $0 == enemy }
    /// ```
    ///
    /// - Parameter entity: The `Entity` to remove, along with all of its child entities
    /// - Important: This operation mutates the scene graph by detaching entities from their parent
    /// - Note: If the entity is already detached or has no parent, the function returns safely without changes
    /// - Warning: Does not remove entity from tracking arrays - handle that separately
    /// - SeeAlso: `Entity.removeChild(_:)`, `Entity.children`, `Entity.parent`
    static func remove(_ entity: Entity) {
        /// **Step 1: Safety Check - Validate Parent Exists**
        /// - Entities without parents cannot be removed (nothing to remove from!)
        /// - Root entities added directly to RealityView content need special handling
        /// - Early return prevents crashes and is computationally free
        /// - Guard pattern: If condition fails, exit gracefully
        guard let parent = entity.parent else {
            return  // Entity has no parent, nothing to do
        }

        /// **Step 2: Recursive Child Removal**
        /// - Iterate through all immediate children of this entity
        /// - Call remove() recursively on each child (depth-first)
        /// - Ensures grandchildren removed before children, children before parent
        /// - Critical for preventing memory leaks in complex hierarchies
        ///
        /// **Why Children First:**
        /// - Parent removal doesn't automatically remove children in memory
        /// - Children can hold references to components, resources, textures
        /// - Proper cleanup order: deepest entities first, working up to root
        ///
        /// **Recursion Termination:**
        /// - Base case: Entity with no children (loop doesn't execute)
        /// - Recursive case: Entity with children (calls remove on each)
        /// - Guaranteed to terminate: Finite entity hierarchy, no cycles
        for child in entity.children {
            remove(child)  // Recursive call - removes entire subtree
        }

        /// **Step 3: Remove Entity from Parent**
        /// - Now that all children are removed, safe to remove this entity
        /// - removeChild() severs the parent-child relationship
        /// - Entity is removed from scene graph (no longer rendered)
        /// - Components are deactivated (collision, physics, etc.)
        /// - Entity memory eligible for cleanup via Swift ARC
        ///
        /// **What Happens After Removal:**
        /// - Entity no longer visible in scene
        /// - No collision detection performed
        /// - No physics calculations
        /// - Not included in entity queries
        /// - If no other references exist, memory is freed
        parent.removeChild(entity)
    }

    // MARK: - Future Entity Management Methods

    /// Future: Entity pooling for performance optimization
    // static func pool(_ entity: Entity) { }

    /// Future: Spawn entity from factory at position
    // static func spawn(_ type: EntityType, at position: SIMD3<Float>) -> Entity { }

    /// Future: Find entities by name pattern
    // static func find(named pattern: String, in root: Entity) -> [Entity] { }

    /// Future: Count active entities of specific type
    // static func count(_ type: EntityType) -> Int { }
}
