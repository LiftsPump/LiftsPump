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
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Routine.self,
                Exercise.self,
                ESet.self,
                PRData.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try! ModelContainer(for: schema, configurations: [config])
        }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .task {
                    let supaManager = SupaBaseManager(context: sharedModelContainer.mainContext)
                    await supaManager.initSync()
                }
        }
    }
}
