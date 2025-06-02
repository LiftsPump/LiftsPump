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
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @State private var isPresented: Bool = false
    @State private var type = 1
    @State private var selExercise: [ExerciseTemplate]?
    @State private var showAccessory = false
    @State private var modalType: ModalPopUp?
    @StateObject private var timerthing = TimerManager()
    @State private var routine: Routine
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
                    BackButton()
                        .onTapGesture {
                            showAccessory.toggle()
                            dismiss()
                        }
                        .padding(.horizontal)
                    Spacer()
                }
            }
            VStack {
                HStack {
                    if (type == 1) {
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
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                    }
                    
                    if (type == 1) {
                        GeneralButton(text: "Save", color: Theme.Colors.Primary1, image: "square.and.arrow.down.fill")
                            .frame(width: 100)
                            .onTapGesture {
                                try? modelContext.save()
                                SupaBaseManager.updateRoutine(routine: routine, id: routine.id)
                                type += 1
                                showAccessory.toggle()
                            }
                    }
                    if (type == 2 || type == 3) {
                        if routine.type == .ai {
                            GeneralButton(text: "Add", color: Theme.Colors.Primary1, image: "square.and.arrow.down.fill")
                                .frame(width: 100)
                                .onTapGesture {
                                    let newRoutine = routine.copy()
                                    newRoutine.type = .preset
                                    modelContext.insert(newRoutine)
                                    routine = newRoutine
                                    externalRoutine = newRoutine
                                    SupaBaseManager.saveRoutine(routine: newRoutine)
                                    try? modelContext.save()
                                    type = 2
                                    showAccessory.toggle()
                                }
                        } else {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                                .onTapGesture {
                                    type = 1
                                    showAccessory.toggle()
                                }
                        }
                    }
                    Image(systemName: "ellipsis")
                        .onTapGesture {
                            showAccessory.toggle()
                            modalType = .Ellipsis
                            isPresented.toggle()
                        }
                    
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
                                GeneralButton(text: "Repeat", color: Theme.Colors.Primary1, image: "repeat")
                                    .frame(width: 130)
                                    .onTapGesture {
                                        type = 2
                                        showAccessory.toggle()
                                        resetCompleted(routineUpdate: routine)
                                    }
                                Spacer()
                            }
                        } else if (type == 3) {
                            VStack {
                                HStack {
                                    Spacer()
                                    GeneralButton(text: "Pause", color: Theme.Colors.NeutralGray1, image: "pause")
                                        .frame(width: 105)
                                        .padding(.trailing, -20)
                                        .onTapGesture {
                                            type = 2
                                            timerthing.toggleTimer(startOrStop: true)
                                        }
                                    GeneralButton(text: "End", color: Theme.Colors.Red, image: "xmark")
                                        .frame(width: 115)
                                        .padding(.trailing, -10)
                                        .onTapGesture {
                                            let prManager = PRManager(context: modelContext)
                                            prManager.checkForPRs(routine: routine)
                                            showAccessory.toggle()
                                            timerthing.toggleTimer(startOrStop: true)
                                            let newRoutine = routine.copy()
                                            newRoutine.type = .date
                                            newRoutine.date = Date()
                                            newRoutine.duration = timerthing.elapsedTime
                                            modelContext.insert(newRoutine)
                                            resetCompleted(routineUpdate: routine)
                                            routine = newRoutine
                                            externalRoutine = newRoutine
                                            SupaBaseManager.saveRoutine(routine: newRoutine)
                                            try? modelContext.save
                                            type = 4
                                        }
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    timerView
                                }
                            }
                        } else if (type == 2 && routine.type != .ai) {
                            VStack {
                                HStack {
                                    Spacer()
                                    GeneralButton(text: "Begin Workout", color: Theme.Colors.Primary1, image: "play.fill")
                                        .frame(width: 170)
                                        .padding(.trailing, -10)
                                        .onTapGesture {
                                            showAccessory.toggle()
                                            type += 1
                                            timerthing.toggleTimer(startOrStop: false)
                                        }
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
                        Text("Collaborators:")
                            .font(Theme.Fonts.Body4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.bottom, 0)
                        Spacer()
                    } .padding(.horizontal)
                }
                ForEach($routine.exercises) { $exercise in
                    ExcerciseInfoCard(editMode: type == 1, exercise: $exercise, active: $type)
                } .padding(.bottom)
                if (type == 1) {
                    HStack {
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
                            .onTapGesture {
                                showAccessory.toggle()
                                modalType = .Exercise
                                isPresented.toggle()
                            }
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
                                        .presentationDetents([.fraction(0.5)])

                                case .Friends:
                                    Friends()
                                case .Schedule:
                                    Friends()
                                }
                            }
                        Spacer()
                    }
                }
            }
            .background(Theme.Colors.NeutralDark2)
            .cornerRadius(12)
            .shadow(radius: 4, x: 0, y: 2)
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .background(Theme.Colors.NeutralDark)
        .sensoryFeedback(.impact, trigger: showAccessory)
        .onAppear{
            if !routine.exercises.isEmpty {
                type = 2
            }
            if (routine.type == .date && (routine.date ?? Date()) < Date()) {
                type = 4
            }
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
        private func addExercise(exercise: ExerciseTemplate) {
            let newExercise = Exercise(
                name: exercise.name,
                eCode: exercise.id,
                text: exercise.instructions?.first ?? "",
                routine: routine,
                routine_id: routine.id,
                sets: []
            )
            let newSet = ESet(
                weight: 0,
                reps: 0,
                pr: false,
                completed: false,
                exercise_id: newExercise.id,
                exercise: newExercise
            )
            newExercise.sets.append(newSet)
            routine.exercises.append(newExercise)
        }
}

#Preview {
    @Previewable @State var rout = Routine(name: "Test", type: RoutineType.preset)
    WorkoutCompleted(externalRoutine: $rout, plusButton: true)
}
