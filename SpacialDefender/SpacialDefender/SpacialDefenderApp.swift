//
//  SpacialDefenderApp.swift
//  SpacialDefender
//
//  Created by Sutha on 05/11/2025.
//

import SwiftUI

@main
struct SpacialDefenderApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
