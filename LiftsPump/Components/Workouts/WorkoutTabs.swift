//
//  Tabs.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/24/24.
//

import SwiftUI

struct WorkoutTabs: View {
    var color: Color
    var text: String
    var textColor: Color
    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .overlay(Text("\(text)")
                .font(Theme.Fonts.Body5))
            .foregroundStyle(textColor)
            .frame(height: 28)
            .cornerRadius(25)
    }
}

#Preview {
    WorkoutTabs(color: Theme.Colors.Primary1, text: "Workout History", textColor: Theme.Colors.NeutralDark)
}
