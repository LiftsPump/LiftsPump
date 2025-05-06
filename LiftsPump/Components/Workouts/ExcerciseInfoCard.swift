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
                        Text("Remove")
                            .font(Theme.Fonts.Body6)
                            .onTapGesture {
                                modelContext.delete(exercise)
                                showAccessory.toggle()
                            }
                    } else {
                        Image(systemName: ("chevron.down"))
                            .font(.system(size: 25))
                            .rotationEffect(.degrees(workoutModal ? 180 : 0))
                                .animation(.easeInOut, value: workoutModal)
                            .onTapGesture {
                                workoutModal.toggle()
                            }
                            .padding(10)
                            .contentShape(Circle())
                    }
                } .padding([.top, .trailing])
                    .padding(.top, -20)
                    .padding(.bottom, 1)
                
                HStack {
                    VStack {
                        Text("Set")
                            .font(Theme.Fonts.Body5)
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                            VStack {
                                Spacer()
                                Text("\(index + 1)")
                                    .font(Theme.Fonts.Body5)
                                    .foregroundStyle(editMode ? Theme.Colors.Red : Theme.Colors.NeutralLight1)
                                    .onTapGesture {
                                        // Remove the set at the specified index
                                        exercise.sets.remove(at: index)
                                        if editMode {
                                            showAccessory.toggle()
                                        }
                                    }
                            }
                        }
                        if editMode {
                            Circle()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Theme.Colors.Primary1)
                                .overlay(
                                    Text("+")
                                        .font(Theme.Fonts.SubHeading6)
                                        .foregroundStyle(Theme.Colors.NeutralDark)
                                )
                                .onTapGesture {
                                    showAccessory.toggle()
                                    exercise.sets.append(ESet(weight: 0, reps: 0, pr: false, completed: false, exercise: exercise))
                                }
                        }
                    }
                    .padding(.leading)

                    Spacer()

                    VStack {
                        Text("lbs")
                            .font(Theme.Fonts.Body5)
                        ForEach(exercise.sets.indices, id: \.self) { index in
                            // Binding the weight for each set
                            let set = exercise.sets[index]
                            TextField("Weight", text: Binding(
                                get: { String(set.weight ?? 0) },
                                set: { newValue in
                                    exercise.sets[index].weight = Int(newValue) ?? 0
                                }
                            ))
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
                        ForEach(exercise.sets.indices, id: \.self) { index in
                            // Using a binding to modify each set's reps
                            let set = exercise.sets[index]
                            TextField("Reps", text: Binding(
                                get: { String(set.reps ?? 0) },
                                set: { newValue in
                                    exercise.sets[index].reps = Int(newValue) ?? 0
                                }
                            ))
                            .keyboardType(.numberPad)
                            .onTapGesture {
                                showAccessory.toggle()
                                exercise.sets[index].reps = 0
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
                        ForEach(exercise.sets) { set in
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 18))
                                .foregroundStyle(set.completed ? Theme.Colors.Primary1 : Theme.Colors.NeutralLight1)
                                .onTapGesture {
                                    if active == 3 {
                                        set.completed = !set.completed
                                        showAccessory.toggle()
                                    }
                                }
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
    @Previewable @State var exerc = Exercise(name: "Becnh Press", eCode: "911", text: "I Am Conf8used", routine: Routine(name: "", picture: "", text: "", exercises: [], type: RoutineType.preset, days: 1, weekly: 1), sets: [
        ESet(weight: 180, reps: 10, pr: true, completed: false, exercise: Exercise(name: "Becnh Press", eCode: "911", text: "I Am Conf8used", routine: Routine(name: "", picture: "", text: "", exercises: [], type: RoutineType.preset, days: 1, weekly: 1)))
    ])
    ExcerciseInfoCard(editMode: false, exercise: $exerc, active: .constant(3))
}
