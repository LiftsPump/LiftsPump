//
//  ExerciseDetails.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 1/25/25.
//

import SwiftUI
import AVKit

enum ExerciseTabs {
    case about, prs, confirm
}
import SwiftUI
import AVKit

struct ExerciseDetails: View {
    private var defaultTab: ExerciseTabs
    private var exercise: ExerciseTemplate
    @State private var showAccessory = false
    @State private var selectedTab: ExerciseTabs
    @Binding var addExercise: Bool
    @State private var prHistory: [PRRecord] = [] // PR Data
    @State private var prSelected: PRRecord?
    @State private var flipTab: Bool = false
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "video2", withExtension: "mp4")!)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(defaultTab: ExerciseTabs, exercise: ExerciseTemplate, addExercise: Binding<Bool>) {
        self.defaultTab = defaultTab
        self.exercise = exercise
        _selectedTab = State(initialValue: defaultTab)
        self._addExercise = addExercise
        self._prSelected = State(initialValue: nil)
    }
    
    private func genInstructions() -> String {
        var finalString = ""
        var i = 1
        for instruction in exercise.instructions ?? [""] {
            finalString += "\(i). \(instruction)\n\n"
            i += 1
        }
        return finalString
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                    showAccessory.toggle()
                }) {
                    BackButton()
                        .padding()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    addExercise = true
                    showAccessory.toggle()
                    dismiss()
                }) {
                    GeneralButton(text: "Add to workout", color: Theme.Colors.Primary1, image: "plus")
                        .frame(width: 175)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add exercise to workout")
            }
            HStack {
                Text("\(exercise.name)")
                    .font(Theme.Fonts.SubHeading2)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            }
            .padding(.leading)
            
            HStack {
                Button(action: {
                    selectedTab = .about
                    showAccessory.toggle()
                    flipTab = true
                }) {
                    WorkoutTabs(color: selectedTab == .about ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "About", textColor: selectedTab == .about ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("About tab")
                
                Button(action: {
                    selectedTab = .prs
                    showAccessory.toggle()
                    flipTab = false
                }) {
                    WorkoutTabs(color: (selectedTab == .prs || selectedTab == .confirm) ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Personal records", textColor: selectedTab == .prs ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Personal records tab")
            }
            .padding(.horizontal)
            
            if selectedTab == .about {
                ScrollView {
                    /*VideoPlayer(player: player)
                        .frame(width: 350, height: 200, alignment: .center)
                        .padding()*/
                    HStack {
                        Text("Instructions")
                            .font(Theme.Fonts.SubHeading7)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.leading)
                            .padding(.bottom, -10)
                        Spacer()
                    }
                    HStack {
                        Text(genInstructions())
                            .font(Theme.Fonts.Body3)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .multilineTextAlignment(.leading)
                            .padding()
                        Spacer()
                    }
                } .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
            } else if selectedTab == .prs {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Top Record")
                            .font(Theme.Fonts.SubHeading7)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.horizontal)
                            .padding(.top)
                        Rectangle()
                            .fill(Theme.Colors.Primary1)
                            .frame(height: 2)
                            .edgesIgnoringSafeArea(.horizontal)
                            .padding(.horizontal)
                        if let topRecord = prHistory.max(by: { $0.weight < $1.weight }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Date")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 75)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("lbs")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 50)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("top%")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 50)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Verified by")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 75)
                                }
                            } .padding(.horizontal)
                            PRRow(record: topRecord, selectedTab: $selectedTab, prSelected: $prSelected)
                                .padding(.horizontal)
                        } else {
                            Text("No records available.")
                                .font(Theme.Fonts.Body3)
                                .foregroundStyle(Theme.Colors.NeutralGray1)
                                .padding()
                        }
                        if prHistory.count > 1 {
                            Text("Record History")
                                .font(Theme.Fonts.SubHeading7)
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                                .padding(.horizontal)
                            Rectangle()
                                .fill(Theme.Colors.Primary1)
                                .frame(height: 2)
                                .edgesIgnoringSafeArea(.horizontal)
                                .padding(.horizontal)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Date")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 75)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("lbs")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 50)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("top%")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 50)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Verified by")
                                        .font(Theme.Fonts.SubHeading5)
                                        .foregroundStyle(Theme.Colors.NeutralGray1)
                                        .frame(width: 75)
                                }
                            } .padding(.horizontal)
                        }
                        ForEach(prHistory) { record in
                            if record.weight != prHistory.max(by: { $0.weight < $1.weight })?.weight {
                                PRRow(record: record, selectedTab: $selectedTab, prSelected: $prSelected)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
                .onAppear {
                    fetchPRHistory()
                }
            } else if selectedTab == .confirm {
                if let prCurrent = prSelected {
                    YourFriends(selectededTab: $selectedTab, prSelected: prCurrent)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            Spacer()
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.NeutralDark)
        .animation(.snappy(duration: 0.2), value: selectedTab)
    }
    
    private func fetchPRHistory() {
        let prManager = PRManager(context: modelContext)
        let response = prManager.getPRHistory(for: exercise.id)
        prHistory = response.map { pr in
            PRRecord(
                date: pr.date.formatted(.dateTime.year().month(.abbreviated).day()),
                supaId: pr.supaId,
                weight: pr.weight,
                verified: (!pr.confirmations.isEmpty),
                percentage: String(Int.random(in: 0...100)),
                eCode: exercise.id,
                realDate: pr.date
            )
        }
    }
}

struct PRRow: View {
    let record: PRRecord
    @Binding var selectedTab: ExerciseTabs
    @Binding var prSelected: PRRecord?
    
    var body: some View {
        HStack {
            Text(record.date)
                .font(Theme.Fonts.SubHeading5)
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .frame(width: 75)
            Spacer()
            Text("\(record.weight) lbs")
                .font(Theme.Fonts.SubHeading5)
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .frame(width: 50)
            Spacer()
            Text("\(record.percentage)%")
                .font(Theme.Fonts.SubHeading5)
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .frame(width: 50)
            Spacer()
            Button(action: {
                if record.verified == false {
                    prSelected = record
                    withAnimation { selectedTab = .confirm }
                }
            }) {
                Image(systemName: record.verified ? "checkmark.circle" : "x.circle")
                    .foregroundStyle(record.verified ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1)
                    .frame(width: 75)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(record.verified ? "Verified" : "Request verification")
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ExerciseDetails(defaultTab: ExerciseTabs.about, exercise: ExerciseTemplate(id: "12", name: "Arnold press", primaryMuscles: ["Tricep", "Bicep"], instructions: ["Instruction 1", "Instruction 2"], images: ["plus"]), addExercise: .constant(false))
}
