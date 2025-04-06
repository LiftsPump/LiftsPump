//
//  ScheduleWorkOut.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 3/24/25.
//

import SwiftUI

struct ScheduleWorkOut: View {
    @Binding var selectedDate: Date
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
                Image(systemName: "xmark")
                    .padding()
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(.system(size: 16))
                    .onTapGesture {
                        dismiss()
                    }
            }
            GeneralButton(text: "Make recurring", color: Theme.Colors.Primary1, image: "repeat", hollow: true)
                .onTapGesture {
                    recurring = true
                }
            if recurring {
                VStack() {
                    HStack() {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start date")
                                .font(Theme.Fonts.Body6)
                            DatePicker("Start date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(10)
                                .frame(width: .infinity)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                                .scaleEffect(0.6)
                        }.frame(width: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End date")
                                .font(Theme.Fonts.Body6)
                            DatePicker("End date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(10)
                                .font(Theme.Fonts.Body7)
                                .frame(width: .infinity)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                                .scaleEffect(0.6)
                        }.frame(width: .infinity)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeat every")
                                .font(Theme.Fonts.Body6)
                            Picker("Repeat every", selection: $repeatInterval) {
                                ForEach(["Day", "2 days", "3 days", "Week", "Month"], id: \.self) { interval in
                                    Text(interval).tag(interval)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(10)
                            .frame(width: 130)
                            .background(RoundedRectangle(cornerRadius:  8).stroke(Color.green))
                            .scaleEffect(0.6)
                        }.frame(width: .infinity)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
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
            GeneralButton(text: "Schedule workout", color: Theme.Colors.Primary1, image: "calendar")
            Spacer()
        } .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    ScheduleWorkOut(selectedDate: .constant(Date()))
}
