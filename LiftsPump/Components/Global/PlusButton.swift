import SwiftUI
import SwiftData

struct PlusButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]
    @State private var isPresented: Bool = false
    @State private var isPresented2: Bool = false
    @State private var newRoutine: Routine = Routine(name: "New Routine", type: .preset)
    @State private var cancelled: Bool = false
    var ifCreateScreen: Bool = false
    @Binding var date: Date
    let calendar = Calendar.current

    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(Theme.Colors.Primary1)
                .frame(width: 46)
                .shadow(color: Color(red: 1, green: 1, blue: 1, opacity: 0.4), radius: 10)
                .onTapGesture {
                    if ifCreateScreen {
                        modelContext.insert(newRoutine)
                        SupaBaseManager.saveRoutine(routine: newRoutine)
                        isPresented = true
                    } else {
                        newRoutine.type = .date
                        newRoutine.date = date
                        isPresented2 = true
                    }
                }
            Image(systemName: "plus")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.Colors.NeutralDark)
        }
        .padding()
        .fullScreenCover(isPresented: $isPresented) {
            WorkoutCompleted(externalRoutine: $newRoutine, plusButton: true)
        }
        .sheet(isPresented: $isPresented2, onDismiss: {
            if cancelled == false {
                modelContext.insert(newRoutine)
                newRoutine.date = date
                SupaBaseManager.saveRoutine(routine: newRoutine)
                isPresented = true
            } else {
                cancelled = false
            }
        }){
            ScheduleWorkOut(selectedDate: $date, isDismissed: $cancelled)
        }
    }
}

#Preview {
    PlusButton(date: .constant(Date()))
        .modelContainer(for: Routine.self)
}
