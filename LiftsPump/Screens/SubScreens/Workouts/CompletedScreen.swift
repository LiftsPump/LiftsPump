//
//  CalendarScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/30/24.
//

import SwiftUI
import SwiftData

struct CompletedScreen: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date()) // Current year
    @Query var routines: [Routine] = []
    @State private var showAccessory = false
    @Environment(\.modelContext) var modelContext

    var groupedRoutines: [String: [Routine]] {
        Dictionary(grouping: routines) { routine in
            routine.date?.formatted(.dateTime.year().month(.wide)) ?? "No Date"
        }
    }

    var body: some View {
        ScrollView {
            ForEach(groupedRoutines.keys.sorted(), id: \.self) { monthYear in
                Section {
                    ForEach(groupedRoutines[monthYear] ?? []) { routine in
                        if routine.type == .date {
                            NavigationLink {
                                WorkoutCompleted(externalRoutine: Binding(
                                                    get: { routine },
                                                    set: { updatedRoutine in
                                                        modelContext.insert(updatedRoutine)
                                                    }
                                                ), plusButton: false).navigationBarBackButtonHidden(true)
                            } label: {
                                ZStack {
                                    WorkoutHistory(
                                        title: routine.name,
                                        image: "figure.run",
                                        date: routine.date?.formatted(.dateTime.year().month(.abbreviated).day()) ?? "No Date Available"
                                    )
                                    .padding(.vertical)
                                }
                                .overlay(alignment: .topTrailing) {
                                    TypeTag(type: routine.type)
                                        .padding(10)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(monthYear)
                            .font(Theme.Fonts.SubHeading4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
        .background(Theme.Colors.NeutralDark)
        .syncOnScroll()
    }
}

#Preview {
    CompletedScreen()
}
