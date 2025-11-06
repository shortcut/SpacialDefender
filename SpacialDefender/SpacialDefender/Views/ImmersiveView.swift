import SwiftUI
import RealityKit


struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // This is where the 3D Game world will Live
            let mesh = MeshResource.generateBox(size: 0.3)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])

            entity.position = [0, 1, -2] // Position infront of the user in meters

            content.add(entity)
        }
    }
}
