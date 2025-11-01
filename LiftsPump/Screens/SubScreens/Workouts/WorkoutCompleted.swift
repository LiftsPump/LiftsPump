//
//  WorkoutCompleted.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/23/24.
//

import SwiftUI

enum ModalPopUp: Identifiable {
    case Exercise, Ellipsis, Schedule, Friends

    var id: Int {
        switch self {
        case .Exercise: return 0
        case .Ellipsis: return 1
        case .Schedule: return 2
        case .Friends: return 3
        }
    }
}

struct WorkoutCompleted: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @State private var isPresented: Bool = false
    @State private var type = 1
    @State private var selExercise: [ExerciseTemplate]?
    @State private var showAccessory = false
    @State private var modalType: ModalPopUp?
    @StateObject private var timerthing = TimerManager()
    @State private var showEndConfirm: Bool = false
    @State private var selectedDateForSchedule: Date = Date()
    @State private var scheduleCancelled: Bool = false
    @State private var routine: Routine
    @EnvironmentObject private var agentService: AgentService
    @Binding var externalRoutine: Routine
    var plusButton: Bool
    
    init(externalRoutine: Binding<Routine>, plusButton: Bool) {
        self._externalRoutine = externalRoutine
        self._routine = State(initialValue: externalRoutine.wrappedValue)
        self.plusButton = plusButton
    }
    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "MM/d/yyyy" // Ensures the format is Month/Day/Year
        return formatter
    }
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            let timerView = TimerView(timerManager: timerthing)
            if plusButton {
                HStack {
                    Button(action: {
                        showAccessory.toggle()
                        dismiss()
                    }) {
                        BackButton()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    Spacer()
                }
            }
            VStack {
                if agentService.isRunning {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.yellow)
                        Text("Live agent is running — editing is temporarily disabled")
                            .font(Theme.Fonts.Body5)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                }
                HStack {
                    if (type == 1 && !agentService.isRunning) {
                        TextField("", text: $routine.name)
                            .foregroundStyle(Theme.Colors.Primary1)
                            .font(Theme.Fonts.SubHeading2)
                            .frame(width: 195, alignment: .leading)
                            .padding(.leading, 5)
                            .padding(.bottom)
                    } else {
                        Text("\(routine.name)")
                            .foregroundStyle(Theme.Colors.Primary1)
                            .font(Theme.Fonts.SubHeading2)
                            .frame(width: 195, alignment: .leading)
                            .padding(.leading, 5)
                    }
                    Spacer()
                    if !(type == 1) {
                        Button(action: {
                            // TODO: Implement share action
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                        .accessibilityLabel("Share")
                    }
                    
                    if (type == 1 && !agentService.isRunning) {
                        Button(action: {
                            try? modelContext.save()
                            SupaBaseManager.updateRoutine(routine: routine, id: routine.id)
                            withAnimation { type += 1 }
                            showAccessory.toggle()
                        }) {
                            GeneralButton(text: "Save", color: Theme.Colors.Primary1, image: "square.and.arrow.down.fill")
                                .frame(width: 100)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Save routine")
                    }
                    if ((type == 2 || type == 3) && !agentService.isRunning) {
                        if routine.type == .agent {
                            Button(action: {
                                let newRoutine = routine.copy()
                                newRoutine.type = .preset
                                modelContext.insert(newRoutine)
                                routine = newRoutine
                                externalRoutine = newRoutine
                                SupaBaseManager.saveRoutine(routine: newRoutine)
                                try? modelContext.save()
                                withAnimation { type = 2 }
                                showAccessory.toggle()
                            }) {
                                GeneralButton(text: "Add", color: Theme.Colors.Primary1, image: "square.and.arrow.down.fill")
                                    .frame(width: 100)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Add routine")
                        } else {
                            Button(action: {
                                withAnimation {
                                    type = 1
                                }
                                showAccessory.toggle()
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .accessibilityLabel("Edit")
                        }
                    }
                    if (routine.type == .preset) && ((routine.days ?? 0) > 0 || (routine.weekly ?? 0) > 0) {
                        Button(action: {
                            stopRecurring()
                            showAccessory.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 20, weight: .bold))
                                    .overlay {
                                        Image(systemName: "rectangle.slash")
                                            .font(.system(size: 32))
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                        .accessibilityLabel("Stop recurring")
                    }
                    
                    Button(action: {
                        showAccessory.toggle()
                        modalType = .Ellipsis
                        isPresented.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("More options")
                    
                } .padding(.horizontal, 10)
                .padding(.top)
                HStack {
                    HStack {
                        Image(systemName: "figure.run")
                            .foregroundStyle(Color.white)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.init(red: 0.5333333333333333, green: 0.996078431372549, blue: 0.7686274509803922), Color.gray]),
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(minWidth: 65, minHeight: 65)
                            .cornerRadius(4)
                            .font(.system(size: 35))
                            .padding(.bottom, 10)
                            .padding(.leading, 10)
                        if (type == 4) {
                            VStack(alignment: .leading) {
                                Text(routine.date ?? Date(), formatter: dateFormatter())
                                    .font(Theme.Fonts.Body4)
                                Spacer()
                                Text("\(formatDuration(routine.duration ?? 0)) | 2 PRs")
                                    .font(Theme.Fonts.Body4)
                                Spacer()
                                Text("Completed by "+firstName)
                                    .font(Theme.Fonts.Body4)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .padding(.bottom, 10)
                            }
                        }
                        Spacer()
                        if (type == 4) {
                            VStack {
                                Button(action: {
                                    withAnimation { type = 2 }
                                    showAccessory.toggle()
                                    resetCompleted(routineUpdate: routine)
                                }) {
                                    GeneralButton(text: "Repeat", color: Theme.Colors.Primary1, image: "repeat")
                                        .frame(width: 130)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Repeat workout")
                                Spacer()
                            }
                        } else if (type == 3) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation { type = 2 }
                                        timerthing.toggleTimer(startOrStop: true)
                                    }) {
                                        GeneralButton(text: "Pause", color: Theme.Colors.NeutralGray1, image: "pause")
                                            .frame(width: 105)
                                            .padding(.trailing, -20)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Pause workout")
                                    Button(action: {
                                        showAccessory.toggle()
                                        showEndConfirm = true
                                    }) {
                                        GeneralButton(text: "End", color: Theme.Colors.Red, image: "xmark")
                                            .frame(width: 115)
                                            .padding(.trailing, -10)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("End workout")
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    timerView
                                }
                            }
                        } else if (type == 2 && routine.type != .agent && !agentService.isRunning) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showAccessory.toggle()
                                        withAnimation { type += 1 }
                                        timerthing.toggleTimer(startOrStop: false)
                                    }) {
                                        GeneralButton(text: "Begin Workout", color: Theme.Colors.Primary1, image: "play.fill")
                                            .frame(width: 170)
                                            .padding(.trailing, -10)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Begin workout")
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    timerView
                                }
                            }
                        }
                    }
                    Spacer()
                } .padding(.leading, 7)
                if !(type == 4) {
                    HStack {
                        /*Text("Collaborators:")
                            .font(Theme.Fonts.Body4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.bottom, 0)
                        Spacer()*/
                    } .padding(.horizontal)
                }
                let sortedExerciseIndices = routine.exercises.indices.sorted { (lhs, rhs) in
                    let l = routine.exercises[lhs].order ?? Int.max
                    let r = routine.exercises[rhs].order ?? Int.max
                    return l < r
                }
                ForEach(sortedExerciseIndices, id: \.self) { exerciseIndex in
                    ExcerciseInfoCard(editMode: type == 1, exercise: $routine.exercises[exerciseIndex], active: $type)
                }
                .padding(.bottom)
                if (type == 1 && !agentService.isRunning) {
                    HStack {
                        Button {
                            showAccessory.toggle()
                            modalType = .Exercise
                            isPresented.toggle()
                        } label: {
                            Rectangle()
                                .foregroundColor(Theme.Colors.Primary1)
                                .overlay(HStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20))
                                        .padding(.trailing, -6)
                                    Text("Add exercises")
                                        .font(Theme.Fonts.Body5)
                                        .padding(.trailing, 6)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 20))
                                        .padding(.trailing, -1)
                                })
                                .foregroundStyle(Theme.Colors.NeutralDark)
                                .frame(width: 150, height: 36)
                                .cornerRadius(4)
                                .padding()
                        }
                        .tint(Theme.Colors.Primary1)
                        Spacer()
                    }
                }
            }
            .background(Theme.Colors.NeutralDark2)
            .cornerRadius(12)
            .shadow(radius: 4, x: 0, y: 2)
            .padding()
            .sheet(item: $modalType, onDismiss: {
                addSelectedExercises()
            }) { type in
                switch type {
                case .Exercise:
                    ExerciseScreen(selectedExercises: Binding(
                        get: { selExercise ?? [] },
                        set: { selExercise = $0 }
                    ), fromWorkout: true)

                case .Ellipsis:
                    EllipsisView(modalType: $modalType)
                        .presentationDetents([.fraction(0.4)])

                case .Friends:
                    Friends()
                case .Schedule:
                    ScheduleWorkOut(selectedDate: $selectedDateForSchedule, isDismissed: $scheduleCancelled, routine: $routine)
                }
            }
        }
        .animation(.snappy(duration: 0.3), value: type)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
        .background(Theme.Colors.NeutralDark)
        .sensoryFeedback(.impact, trigger: showAccessory)
        .onAppear{
            if !routine.exercises.isEmpty {
                withAnimation {
                    type = 2
                }
            }
            if (routine.type == .date && (routine.date ?? Date()) < Date()) {
                withAnimation {
                    type = 4
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                timerthing.refresh()
            }
        }
        .alert("End workout?", isPresented: $showEndConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                let prManager = PRManager(context: modelContext)
                prManager.checkForPRs(routine: routine)
                timerthing.toggleTimer(startOrStop: true)
                let newRoutine = routine.copy()
                newRoutine.type = .date
                newRoutine.date = Date()
                newRoutine.duration = timerthing.elapsedTime
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
                resetCompleted(routineUpdate: routine)
                routine = newRoutine
                externalRoutine = newRoutine
                SupaBaseManager.saveRoutine(routine: newRoutine)
                try? modelContext.save()
                withAnimation { type = 4 }
            }
        } message: {
            Text("This will save your workout as a dated routine and sync it to Supabase.")
        }
    }
    private func resetCompleted(routineUpdate: Routine) {
        for exercise in routineUpdate.exercises {
            for set in exercise.sets {
                set.completed = false
            }
        }
    }
    private func addSelectedExercises() {
        if let exercisesSel = selExercise {
            for exerciseTemplate in exercisesSel {
                addExercise(exercise: exerciseTemplate)
            }
            selExercise = nil
        }
    }
    private func stopRecurring() {
        // Convert recurring preset into a single-occurrence date routine.
        // Keep the current start date if present; otherwise, use today.
        routine.days = nil
        routine.weekly = nil
        // If it was a template with a start date, make it a single-date routine
        if routine.date == nil { routine.date = Date() }
        routine.type = .date
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after stopping recurrence: \(error)")
        }
        SupaBaseManager.updateRoutine(routine: routine, id: routine.id)
    }
    private func addExercise(exercise: ExerciseTemplate) {
        let nextExerciseOrder = (routine.exercises.compactMap { $0.order }.max() ?? routine.exercises.count) + 1
        let newExercise = Exercise(
            id: UUID(),
            name: exercise.name,
            eCode: exercise.id,
            text: exercise.instructions?.first ?? "",
            routine: routine,
            routine_id: routine.id,
            sets: [],
            order: nextExerciseOrder
        )
        let newSet = ESet(
            id: UUID(),
            weight: 0,
            reps: 0,
            pr: false,
            completed: false,
            exercise_id: newExercise.id,
            exercise: newExercise
        )
        newExercise.sets.append(newSet)
        routine.exercises.append(newExercise)
        SupaBaseManager.addExercise(exercise: newExercise)
    }
}

#Preview {
    @Previewable @State var rout = Routine(id: UUID(), name: "Test", type: RoutineType.preset)
    WorkoutCompleted(externalRoutine: $rout, plusButton: true)
}

