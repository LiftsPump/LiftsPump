import SwiftUI
import UIKit

struct Tab: View {
    @AppStorage("TRAINER_ID_KEY") var trainerId: String = ""
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.11372549019, green: 0.10196078431, blue: 0.12549019607, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            ExerciseScreen(selectedExercises: .constant([]), fromWorkout: false)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                }
            WorkoutScreen(defaultTab: WorkoutTab.history)
                .tabItem {
                    Image(systemName: "calendar")
                }
            if !trainerId.isEmpty {
                TrainerScreen()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                    }
            }
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill").font(.system(size: 26))
                }
        }
        .accentColor(Theme.Colors.Primary1) // Change the selected tab item color
    }
}

#Preview {
    Tab()
}
