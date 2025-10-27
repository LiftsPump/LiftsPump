//
//  MyFitrackApp.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/7/24.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct LiftsPump: App {
    @StateObject var agentService = AgentService()
    
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
                .environmentObject(agentService)
                .modelContainer(sharedModelContainer)
                .onOpenURL { url in
                    Task { @MainActor in
                        _ = GIDSignIn.sharedInstance.handle(url)
                    }
                }
                .task {
                    let supaManager = SupaBaseManager(context: sharedModelContainer.mainContext)
                    do {
                        try await supaManager.initSync()
                    } catch {
                        print("Failed to initialize SupaBaseManager: \(error)")
                        // Optional: You can add fallback handling or logging here
                    }
                }
        }
    }
}
