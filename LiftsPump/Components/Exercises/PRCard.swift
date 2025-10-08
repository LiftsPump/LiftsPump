//
//  ExcerciseCard.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 2/01/25.
//

import SwiftUI
import Foundation

struct PRCard: View {
    @Binding var exercise: ExerciseTemplate
    @Binding var PRRecord: PRRecord
    var selected: Bool
    
    var body: some View {
        VStack {
            HStack {
                // Construct the image name dynamically using exercise.id
                let imageName = "exercise_\(exercise.id)_0"
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .background(Theme.Colors.NeutralDark2)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("\(exercise.name)")
                        .font(Theme.Fonts.SubHeading7)
                    Text("\(String(PRRecord.weight)) lbs | \(PRRecord.percentage) % | \(PRRecord.date)")
                        .font(Theme.Fonts.Body3)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                    .foregroundStyle(Theme.Colors.NeutralLight2)
            }
            Rectangle()
                .fill(Theme.Colors.NeutralDark2)
                .frame(width: .infinity, height: 2)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.horizontal)
        }
        .frame(width: 380, height: 100)
        .padding(.leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: selected
                    ? [Theme.Colors.Primary1, Theme.Colors.NeutralDark]
                    : [Theme.Colors.NeutralDark, Theme.Colors.NeutralDark]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

#Preview {
}
