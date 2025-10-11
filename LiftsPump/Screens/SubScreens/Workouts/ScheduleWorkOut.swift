//
//  ScheduleWorkOut.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 3/24/25.
//

import SwiftUI

struct ScheduleWorkOut: View {
    @Binding var selectedDate: Date
    @Binding var isDismissed: Bool
    @Binding var routine: Routine
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var recurring: Bool = false
    @State var endDate: Date = Date()
    @State var repeatInterval: String = "Day"
    
    var body: some View {
        VStack {
            HStack {
                Text("Schedule your workout")
                    .padding()
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.SubHeading6)
                Spacer()
                Button(action: {
                    isDismissed = true
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .padding()
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .accessibilityLabel("Close")
            }
            Button(action: { recurring.toggle() }) {
                GeneralButton(text: "Make recurring", color: Theme.Colors.Primary1, image: "repeat", hollow: true)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle recurring")
            if recurring {
                VStack() {
                    HStack() {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start date")
                                .font(Theme.Fonts.Body6)
                                .padding(.leading, 20)
                            DatePicker("Start date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(10)
                                .frame(width: .infinity)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                                .scaleEffect(0.7)
                                .edgesIgnoringSafeArea(.all)
                        }.frame(width: .infinity)
                            .padding(.vertical, -20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End date")
                                .font(Theme.Fonts.Body6)
                                .padding(.leading, 20)
                            DatePicker("End date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(10)
                                .font(Theme.Fonts.Body7)
                                .frame(width: .infinity)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                                .scaleEffect(0.7)
                                .edgesIgnoringSafeArea(.all)
                        }.frame(width: .infinity)
                            .padding(.vertical, -20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeat every")
                                .font(Theme.Fonts.Body6)
                                .padding(.leading, 15)
                                .edgesIgnoringSafeArea(.all)
                                .frame(width: 100)
                            Picker("Repeat every", selection: $repeatInterval) {
                                ForEach(["Day", "2 days", "3 days", "Week"], id: \.self) { interval in
                                    Text(interval).tag(interval)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(10)
                            .frame(width: 130)
                            .background(RoundedRectangle(cornerRadius:  8).stroke(Color.green))
                            .scaleEffect(0.7)
                            .edgesIgnoringSafeArea(.all)
                        }.frame(width: .infinity)
                            .padding(.vertical, -20)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.top, 23)
            }

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal)
                Text("or")
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.Body5)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal)
            } .padding(.vertical)
            HStack {
                Text("Select a date for a single occurance:")
                    .font(Theme.Fonts.SubHeading5)
                    .foregroundStyle(Theme.Colors.Primary1)
                    .padding(.horizontal)
                Spacer()
            }
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
            Button(action: {
                // Persist the schedule to the bound routine
                if recurring {
                    // Use preset type with recurrence, store selectedDate as the start date
                    routine.type = .preset
                    routine.date = selectedDate
                    // Map repeatInterval to days/weekly
                    switch repeatInterval {
                    case "Day":
                        routine.days = 1
                        routine.weekly = nil
                    case "2 days":
                        routine.days = 2
                        routine.weekly = nil
                    case "3 days":
                        routine.days = 3
                        routine.weekly = nil
                    case "Week":
                        routine.weekly = 1
                        routine.days = nil
                    default:
                        routine.days = 1
                        routine.weekly = nil
                    }
                    SupaBaseManager.saveRoutine(routine: routine)
                } else {
                    // Single occurrence date-based routine
                    routine.type = .date
                    routine.date = selectedDate
                    routine.days = nil
                    routine.weekly = nil
                }
                isDismissed = false
                dismiss()
            }) {
                GeneralButton(text: "Schedule workout", color: Theme.Colors.Primary1, image: "calendar")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Schedule workout")
            Spacer()
        } .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    @Previewable @State var date = Date()
    @Previewable @State var dismissed = false
    @Previewable @State var rout = Routine(id: UUID(), name: "Test", type: .preset)
    ScheduleWorkOut(selectedDate: $date, isDismissed: $dismissed, routine: $rout)
}
