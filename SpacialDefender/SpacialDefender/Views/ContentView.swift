//
//  ContentView.swift
//  SpacialDefender
//
//  Created by Sutha on 05/11/2025.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Text("Spacial Defenders")
                .font(.extraLargeTitle)
                .padding(.bottom, 20)
            Button("Start Game") {
                Task {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
