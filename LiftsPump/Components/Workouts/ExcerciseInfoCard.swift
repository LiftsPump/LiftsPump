//  ExcerciseInfoCard.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/27/24.
//

import SwiftUI
import SwiftData

struct ExcerciseInfoCard: View {
    var editMode: Bool
    @State private var showAccessory = false
    @State private var workoutModal = false
    @Environment(\.modelContext) private var modelContext
    @Binding var exercise: Exercise
    @Binding var active: Int
    
    private func allCompleted() -> Bool {
        for i in 0..<exercise.sets.count {
            if !exercise.sets[i].completed {
                return false
            }
        }
        return true
    }

    var body: some View {
        ZStack {
            Color.white.opacity(0.1)
                .cornerRadius(4)
            VStack {
                HStack {
                    let imageName = "exercise_\(exercise.eCode)_0"
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .background(Theme.Colors.NeutralDark2)
                        .clipShape(Circle())
                    Text("\(exercise.name)")
                        .font(Theme.Fonts.SubHeading5)
                    Spacer()
                    if editMode {
                        Button(action: {
                            SupaBaseManager.deleteExercise(exercise: exercise)
                            modelContext.delete(exercise)
                            showAccessory.toggle()
                        }) {
                            Text("Remove")
                                .font(Theme.Fonts.Body6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Remove exercise")
                    } else {
                        Button(action: { workoutModal.toggle() }) {
                            Image(systemName: ("chevron.down"))
                                .font(.system(size: 25))
                                .rotationEffect(.degrees(workoutModal ? 180 : 0))
                                .padding(10)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Circle())
                        .animation(.easeInOut, value: workoutModal)
                    }
                } .padding([.top, .trailing])
                    .padding(.top, -20)
                    .padding(.bottom, 1)
                
                HStack {
                    let sortedIndices = exercise.sets.indices.sorted { (lhs, rhs) in
                        let l = exercise.sets[lhs].order ?? Int.max
                        let r = exercise.sets[rhs].order ?? Int.max
                        return l < r
                    }
                    VStack {
                        Text("Set")
                            .font(Theme.Fonts.Body5)
                        ForEach(Array(sortedIndices.enumerated()), id: \.element) { displayPosition, originalIndex in
                            VStack {
                                Spacer()
                                Button(action: {
                                    SupaBaseManager.deleteSet(set: exercise.sets[originalIndex])
                                    exercise.sets.remove(at: originalIndex)
                                    if editMode {
                                        showAccessory.toggle()
                                    }
                                }) {
                                    Text("\(displayPosition + 1)")
                                        .font(Theme.Fonts.Body5)
                                        .foregroundStyle(editMode ? Theme.Colors.Red : Theme.Colors.NeutralLight1)
                                }
                                .buttonStyle(.plain)
                                .disabled(!editMode)
                                .accessibilityLabel("Delete set \(displayPosition + 1)")
                            }
                        }
                        if editMode {
                            Button(action: {
                                showAccessory.toggle()
                                let nextOrder = (exercise.sets.compactMap { $0.order }.max() ?? exercise.sets.count) + 1
                                let newSet = ESet(id: UUID(), weight: 0, reps: 0, pr: false, completed: false, exercise: exercise, order: nextOrder)
                                SupaBaseManager.addSet(set: newSet)
                                exercise.sets.append(newSet)
                            }) {
                                Circle()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(Theme.Colors.Primary1)
                                    .overlay(
                                        Text("+")
                                            .font(Theme.Fonts.SubHeading6)
                                            .foregroundStyle(Theme.Colors.NeutralDark)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Add set")
                        }
                    }
                    .padding(.leading)

                    Spacer()

                    VStack {
                        Text("lbs")
                            .font(Theme.Fonts.Body5)
                        ForEach(sortedIndices, id: \.self) { originalIndex in
                            // Binding the weight for each set
                            let set = exercise.sets[originalIndex]
                            TextField("Weight", text: Binding(
                                get: { String(set.weight ?? 0) },
                                set: { newValue in
                                    exercise.sets[originalIndex].weight = Int(newValue) ?? 0
                                }
                            ))
                            .scrollDismissesKeyboard(.interactively)
                            .keyboardType(.numberPad)
                            .font(Theme.Fonts.Body5)
                            .foregroundStyle(Theme.Colors.NeutralDark)
                            .padding()
                            .frame(width: 55, height: 20)
                            .background(Theme.Colors.NeutralGray1)
                            .cornerRadius(4)
                            .overlay(
                                Rectangle().stroke(Theme.Colors.NeutralDark)
                            )
                            .onTapGesture {
                                showAccessory.toggle()
                            }
                        }
                    } .padding(.bottom, editMode ? 30 : 0)

                    Spacer()

                    VStack {
                        Text("Reps")
                            .font(Theme.Fonts.Body5)
                        ForEach(sortedIndices, id: \.self) { originalIndex in
                            // Using a binding to modify each set's reps
                            let set = exercise.sets[originalIndex]
                            TextField("Reps", text: Binding(
                                get: { String(set.reps ?? 0) },
                                set: { newValue in
                                    exercise.sets[originalIndex].reps = Int(newValue) ?? 0
                                }
                            ))
                            .scrollDismissesKeyboard(.interactively)
                            .keyboardType(.numberPad)
                            .onTapGesture {
                                showAccessory.toggle()
                            }
                            .font(Theme.Fonts.Body5)
                            .foregroundStyle(Theme.Colors.NeutralDark)
                            .padding()
                            .frame(width: 48, height: 20)
                            .background(Theme.Colors.NeutralGray1)
                            .cornerRadius(4)
                            .overlay(
                                Rectangle().stroke(Theme.Colors.NeutralDark)
                            )
                        }
                    } .padding(.bottom, editMode ? 30 : 0)
                    Spacer()
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 25))
                            .foregroundStyle(allCompleted() ? Theme.Colors.Primary1 : Theme.Colors.NeutralLight1)
                        ForEach(exercise.sets.sorted(by: { ($0.order ?? Int.max) < ($1.order ?? Int.max) })) { set in
                            Spacer()
                            Button(action: {
                                if active == 3 {
                                    set.completed.toggle()
                                    showAccessory.toggle()
                                }
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18))
                                    .foregroundStyle(set.completed ? Theme.Colors.Primary1 : Theme.Colors.NeutralLight1)
                            }
                            .buttonStyle(.plain)
                            .disabled(active != 3)
                            .accessibilityLabel(set.completed ? "Mark incomplete" : "Mark complete")
                        }
                    }
                    .padding(.bottom, editMode ? 30 : 0)
                    .padding(.trailing)
                }
            }
            .padding() // Padding for content within the ZStack
            .frame(height: workoutModal ? 57 : .infinity, alignment: .top)
                .clipped()
                .animation(.snappy(duration: 0.3), value: workoutModal)
        }
        .padding(.top)
        .padding(.horizontal)
        .sensoryFeedback(.success, trigger: showAccessory)
    }
}

#Preview {
    @Previewable @State var exerc = Exercise(id: UUID(), name: "Becnh Press", eCode: "911", text: "I Am Conf8used", routine: Routine(id: UUID(), name: "", picture: "", text: "", exercises: [], type: RoutineType.preset, days: 1, weekly: 1), sets: [
        ESet(id: UUID(), weight: 180, reps: 10, pr: true, completed: false, exercise: Exercise(id: UUID(), name: "Becnh Press", eCode: "911", text: "I Am Conf8used", routine: Routine(id: UUID(), name: "", picture: "", text: "", exercises: [], type: RoutineType.preset, days: 1, weekly: 1)))
    ])
    ExcerciseInfoCard(editMode: false, exercise: $exerc, active: .constant(3))
}

