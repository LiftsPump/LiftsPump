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
    var trainer: Bool = false
    let calendar = Calendar.current
    
    private func occurs(_ routine: Routine, on date: Date) -> Bool {
        guard let start = routine.date else { return false }
        let dayStart = calendar.startOfDay(for: start)
        let dateStart = calendar.startOfDay(for: date)
        
        switch routine.type {
        case .assigned:
            if let d = routine.days, d > 0 {
                // every N days starting from start
                let comps = calendar.dateComponents([.day], from: dayStart, to: dateStart)
                if let diff = comps.day, diff >= 0 { return diff % d == 0 }
            }
            if let w = routine.weekly, w > 0 {
                // every N weeks on the same weekday as start
                let comps = calendar.dateComponents([.weekOfYear], from: dayStart, to: dateStart)
                if let weeks = comps.weekOfYear, weeks >= 0 {
                    return (weeks % w == 0) && (calendar.component(.weekday, from: dayStart) == calendar.component(.weekday, from: dateStart))
                }
            }
            return false
        case .date:
            return calendar.isDate(dayStart, inSameDayAs: dateStart)
        case .preset:
            // Recurring logic
            if let d = routine.days, d > 0 {
                // every N days starting from start
                let comps = calendar.dateComponents([.day], from: dayStart, to: dateStart)
                if let diff = comps.day, diff >= 0 { return diff % d == 0 }
            }
            if let w = routine.weekly, w > 0 {
                // every N weeks on the same weekday as start
                let comps = calendar.dateComponents([.weekOfYear], from: dayStart, to: dateStart)
                if let weeks = comps.weekOfYear, weeks >= 0 {
                    return (weeks % w == 0) && (calendar.component(.weekday, from: dayStart) == calendar.component(.weekday, from: dateStart))
                }
            }
            return false
        default:
            return false
        }
    }
    private func isEmpty(routines: [Routine]) -> Bool {
        for routine in routines {
            if routine.type == .assigned {
                return false
            }
        }
        return true
    }

    private var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }
    private var formattedDate: String {
        let df = DateFormatter()
        df.dateStyle = .full
        return df.string(from: selectedDate)
    }

    var body: some View {
        ScrollView {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .padding(.horizontal)
                .datePickerStyle(.graphical)
                .accentColor(Theme.Colors.Primary1)
                .environment(\.colorScheme, .dark) // Forces the view to use dark mode, making text white
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: isToday ? "sun.max.fill" : "calendar")
                            .foregroundStyle(Theme.Colors.Primary1)
                        Text(isToday ? "Today" : formattedDate)
                            .lineLimit(1).minimumScaleFactor(0.8)
                            .font(Theme.Fonts.SubHeading2)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                    }
                    if !isToday {
                        Text("Today is \(Date(), format: Date.FormatStyle().year().month(.abbreviated).day())")
                            .font(Theme.Fonts.Body6)
                            .foregroundStyle(Theme.Colors.NeutralLight1.opacity(0.8))
                    }
                }
                Spacer()
                Text(selectedDate, format: Date.FormatStyle().weekday(.abbreviated))
                    .font(Theme.Fonts.Body6)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .foregroundStyle(Theme.Colors.NeutralLight1)
            }
            .padding(.horizontal)
            VStack {
                let selectedDateString = selectedDate.formatted(.dateTime.year().month(.abbreviated).day())
                let matches = routines.filter { occurs($0, on: selectedDate) }
                ForEach(matches, id: \.id) { routine in
                    if (!trainer || (trainer && (routine.type == .assigned))) {
                        NavigationLink {
                            WorkoutCompleted(externalRoutine: Binding(
                                get: { routine },
                                set: { updatedRoutine in
                                    modelContext.insert(updatedRoutine)
                                }
                            ), plusButton: false).navigationBarBackButtonHidden(true)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.thinMaterial)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Colors.Primary1.opacity(0.12), lineWidth: 1))
                                    .padding()
                                WorkoutHistory(title: routine.name, image: "figure.run", date: selectedDateString, type: routine.type)
                            }
                            .padding(5)
                        }
                    }
                }
                let hasAny: Bool = matches.isEmpty
                if (!trainer && hasAny) || (trainer && isEmpty(routines: matches)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                        VStack(spacing: 8) {
                            Image(systemName: isToday ? "sun.max" : "calendar")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(Theme.Colors.Primary1)
                            Text(isToday ? "No workouts scheduled for today" : "No workouts on this day")
                                .multilineTextAlignment(.center)
                                .font(Theme.Fonts.SubHeading5)
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                            Text("Pick another date or add one from your coach.")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .font(Theme.Fonts.Body6)
                                .foregroundStyle(Theme.Colors.NeutralLight1.opacity(0.85))
                        }
                        .padding(20)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
    }
}

#Preview {
    CalendarScreen(selectedDate: .constant(Date()))
}
