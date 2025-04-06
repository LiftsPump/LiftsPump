//
//  MyFitrackApp.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/7/24.
//

import SwiftUI
import SwiftData

@main
struct LiftsPump: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Routine.self, Exercise.self, ESet.self, PRData.self])
    }
}
