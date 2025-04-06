import SwiftUI
import SwiftData

struct CreatedScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]
    @State private var showAccessory = false
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.init(red: 0.11372549019, green: 0.10196078431, blue: 0.12549019607, alpha: 0)
    }
    
    func deleteRoutine(at offsets: IndexSet) {
        for index in offsets {
            let routineToDelete = routines[index]
            modelContext.delete(routineToDelete)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.NeutralDark
                .edgesIgnoringSafeArea(.all)
            List() {
                ForEach(routines) { routine in
                    if routine.type == .preset {
                        ZStack {
                            WorkoutComponent(title: routine.name, image: "figure.run", description: DataMethods.summarizer(routine: routine))
                            NavigationLink(
                                destination: WorkoutCompleted(
                                    externalRoutine: Binding(
                                        get: { routine },
                                        set: { updatedRoutine in
                                            modelContext.insert(updatedRoutine)
                                        }
                                    ),
                                    plusButton: false
                                )
                                .navigationBarBackButtonHidden(true)
                            ) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(.plain)
                        }
                    }
                }
                .onDelete(perform: deleteRoutine)
                .accentColor(.blue)
                .listRowBackground(Theme.Colors.NeutralDark)
                .listRowSeparator(.hidden)
            }
            .sensoryFeedback(.selection, trigger: showAccessory)
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.NeutralDark)
            .listStyle(.inset)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    CreatedScreen()
}
