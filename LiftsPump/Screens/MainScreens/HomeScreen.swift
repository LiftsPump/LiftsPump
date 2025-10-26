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

    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Hello, \n\(firstName)!")
                        .font(Theme.Fonts.Heading1)
                        .foregroundStyle(Theme.Colors.Primary1)
                }
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
                                    .frame(width: 0, height: 25)
                                    .background(Theme.Colors.Primary1)
                                    .clipShape(Circle())
                                    .offset(x: 10),
                                alignment: .top
                            )
                }
            }.padding()
            HStack {
                NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.created).navigationBarBackButtonHidden(true)) {
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
                NavigationLink(destination: WorkoutScreen(defaultTab: WorkoutTab.history).navigationBarBackButtonHidden(true)) {
                        StatView(stat: DataMethods.completedRoutines(routines: routines), image: "checkmark.circle")
                }
                Spacer()
                VStack{
                    NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.history).navigationBarBackButtonHidden(true)) {
                            HalfStatView(image: "flame", stat: DataMethods.userStreak(routines: routines), subText: "days in a row!", title: "Your streak")
                            .padding(.bottom, 8)
                    }
                    Spacer()
                    NavigationLink(destination:     WorkoutScreen(defaultTab: WorkoutTab.prs).navigationBarBackButtonHidden(true))  {
                            HalfStatView(image: "figure.strengthtraining.traditional", stat: DataMethods.getPRsConfirmed(modelContext: modelContext), subText: "PRs confirmed!", title: "Your records")
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
                            ZStack {
                                WorkoutComponent(title: routine.name, image: "figure.run", description: DataMethods.summarizer(routine: routine))
                            }
                            .overlay(alignment: .bottomTrailing) {
                                TypeTag(type: routine.type)
                                    .padding(10)
                            }
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
            .syncOnScroll(modelContext: modelContext)
            .task {
                let supaManager = SupaBaseManager(context: modelContext)
                Task.detached {
                    do {
                        try await supaManager.initSync()
                    } catch {
                        print("Failed to initialize SupaBaseManager: \(error)")
                    }
                }
            }
            .task {
                await NotificationManager.shared.requestAuthorizationIfNeeded()
            }
            .overlay(content: { VStack { Spacer()
                HStack { Spacer()
                    Button(action: { showAccessory.toggle() }) {
                        PlusButton(ifCreateScreen: true, date: .constant(Date()))
                    }
                    .buttonStyle(.plain)
                }
            }})
    }
}

#Preview {
    HomeScreen()
}
