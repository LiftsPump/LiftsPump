//
//  CalendarScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/30/24.
//

import SwiftUI
import SwiftData

struct CalendarScreen: View {
    @Binding var selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]
    @State private var showAccessory = false
    let calendar = Calendar.current

    var body: some View {
        ScrollView {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .padding(.horizontal)
                .datePickerStyle(.graphical)
                .accentColor(Theme.Colors.Primary1)
                .environment(\.colorScheme, .dark) // Forces the view to use dark mode, making text white
            HStack{
                Text(selectedDate, format: Date.FormatStyle()
                    .year().month(.abbreviated).day())
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.SubHeading2)
                    .padding(.horizontal)
                Spacer()
            }
            VStack {
                let selectedDateString = selectedDate.formatted(.dateTime.year().month(.abbreviated).day())
                ForEach(routines) { routine in
                    if let routineDate = routine.date,
                       calendar.isDate(routineDate, inSameDayAs: selectedDate) {
                        NavigationLink {
                            WorkoutCompleted(externalRoutine: Binding(
                                                get: { routine },
                                                set: { updatedRoutine in
                                                    modelContext.insert(updatedRoutine)
                                                }
                                            ), plusButton: false).navigationBarBackButtonHidden(true)
                        } label: {
                            WorkoutHistory(title: routine.name, image: "figure.run", date: selectedDateString)
                                .padding(.vertical)
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
    }
}

#Preview {
    CalendarScreen(selectedDate: .constant(Date()))
}
