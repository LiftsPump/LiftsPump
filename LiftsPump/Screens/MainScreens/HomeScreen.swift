//
//  HomeScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/11/24.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
    @AppStorage("FIRSTNAME_KEY") var firstName: String = "Derek"
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]
    @State private var showAccessory = false
    
    private func completedRoutines() -> Int {
        var count = 0
        for routine in routines {
            if routine.type == .date {
                count += 1
            }
        }
        return count
    }
    private func userStreak() -> Int {
        guard !routines.isEmpty else { return 0 }

        // Sort routines by date in descending order
        let sortedRoutines = routines.filter { $0.type == .date }.sorted { $0.date ?? Date() > $1.date ?? Date()}
        
        var streak = 0
        var previousDate: Date? = nil
        let calendar = Calendar.current
        
        for routine in sortedRoutines {
            if let routineDate = routine.date {
                if routineDate > Date() {
                    continue
                }
                if previousDate == nil {
                    streak += 1
                } else if let daysDifference = calendar.dateComponents([.day], from: routineDate, to: previousDate!).day, daysDifference == 1 {
                    streak += 1
                } else if let daysDifference = calendar.dateComponents([.day], from: routineDate, to: previousDate!).day, daysDifference > 1 {
                    streak = 0
                    break
                }
                previousDate = routineDate
            }
        }
        
        return streak
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top) {
                Text("hello, \n\(firstName)!")
                    .font(Theme.Fonts.Heading1)
                    .foregroundStyle(Theme.Colors.Primary1)
                Spacer()
                NavigationLink(destination: NotificationsScreen()) {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 26 , height: 30)
                        .padding()
                        .overlay(
                                Text("1")
                                    .foregroundColor(Theme.Colors.NeutralLight1)
                                    .font(Theme.Fonts.Body5)
                                    .padding(4)
                                    .frame(width: 25, height: 25)
                                    .background(Theme.Colors.Primary1)
                                    .clipShape(Circle())
                                    .offset(x: 10),
                                alignment: .top
                            )
                }
            }.padding()
            HStack {
                NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.created).navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: BackButton())) {
                    Text("View your workouts")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 20, weight: .bold))
                }
                Spacer()
            }.padding(.top , 18)
                .padding(.bottom, 3)
            HStack {
                NavigationLink(destination: WorkoutScreen(defaultTab: WorkoutTab.history).navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: BackButton())) {
                        StatView(stat: completedRoutines(), image: "checkmark.circle")
                }
                Spacer()
                VStack{
                    NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.history).navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: BackButton())) {
                            HalfStatView(image: "flame", stat: userStreak(), subText: "days in a row!", title: "Your streak")
                            .padding(.bottom, 8)
                    }
                    Spacer()
                    NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.prs).navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: BackButton()))  {
                        HalfStatView(image: "figure.strengthtraining.traditional", stat: 10, subText: "PRs confirmed!", title: "Your records")
                            .padding(.top, 8)
                    }
                }.frame(height: 175)
                    .padding(.trailing)
            }.padding(-1)
                .frame(maxWidth: .infinity, maxHeight: 200)
            Text("Discover pre-made workouts, individually curated for you.")
                .foregroundStyle(Color.white)
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 23)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            VStack {
                ForEach(routines) { routine in
                    if routine.type == .ai {
                        NavigationLink {
                            WorkoutCompleted(externalRoutine: Binding(
                                                get: { routine },
                                                set: { updatedRoutine in
                                                    modelContext.insert(updatedRoutine)
                                                }
                                            ), plusButton: false).navigationBarBackButtonHidden(true)
                        } label: {
                            WorkoutComponent(title: routine.name, image: "figure.run", description: DataMethods.summarizer(routine: routine))
                                .padding(.horizontal)
                        }
                        Spacer()
                            .padding(3)
                    }
                }
            Spacer()
                .padding(-3)
        }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.NeutralDark)
            .sensoryFeedback(.selection, trigger: showAccessory)
            .task {
                let supaManager = SupaBaseManager(context: modelContext)
                do {
                    try await supaManager.initSync()
                } catch {
                    print("Failed to initialize SupaBaseManager: \(error)")
                }
            }
            .overlay(content: {VStack{Spacer()
                HStack{Spacer()
                    PlusButton(date: .constant(Date()))
                    .onTapGesture {showAccessory.toggle()}}}})
    }
}

#Preview {
    HomeScreen()
}
