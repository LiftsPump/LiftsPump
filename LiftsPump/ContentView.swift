import SwiftUI
import GoogleSignIn
import Supabase

struct ContentView: View {
    @AppStorage("ISNEW_KEY") var new: Bool = true
    @AppStorage("APPEARANCE_KEY") private var appearance: String = "system"
    @EnvironmentObject private var agentService: AgentService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if new {
                NavigationStack {
                    FirstOnboarding()
                        .onAppear {
                            new = false
                        }
                }
            } else {
                NavigationStack {
                    if checkUserLoginStatus() {
                        Tab()
                    } else {
                        SignUp().navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
        .onChange(of: agentService.agentCompleted) { completed in
            if completed {
                var newRoutine = agentService.AgentRoutine.copy()
                newRoutine.type = .date
                newRoutine.date = Date()
                newRoutine.duration = 0
                newRoutine.id = UUID()
                for exercise in newRoutine.exercises {
                    exercise.id = UUID()
                    exercise.routine_id = newRoutine.id
                    for set in exercise.sets {
                        set.id = UUID()
                        set.exercise_id = exercise.id
                    }
                }
                modelContext.insert(newRoutine)
                SupaBaseManager.saveRoutine(routine: newRoutine)
                try? modelContext.save()
                agentService.agentCompleted = false
            }
        }
        .preferredColorScheme(.dark)
    }
    func checkUserLoginStatus() -> Bool {
        if (supabase.auth.currentUser != nil) {
            return(true)
        } else {
            return false
        }
    }
    private func resolvedScheme() -> ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Routine.self, Exercise.self, ESet.self, PRData.self])
    }
}
