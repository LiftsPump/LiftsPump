//
//  WorkoutHistory.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/26/24.
//

import SwiftUI

struct WorkoutHistory: View {
    var title: String
    var image: String
    var date: String
    var type: RoutineType
    
    var body: some View {
        VStack() {
            HStack {
                Image(systemName: "\(image)")
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.init(red: 0.5333333333333333, green: 0.996078431372549, blue: 0.7686274509803922), Color.gray]),
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(10)
                    .font(.system(size: 35))
                    .padding(13)
                VStack {
                    HStack {
                        Text("\(title)")
                            .font(Theme.Fonts.SubHeading6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.vertical, 5)
                    }
                    HStack {
                        Text("\(date) | 2 PRs |")
                            .font(Theme.Fonts.Body2)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.vertical, 5)
                        Image(systemName: "person.circle")
                        TypeTag(type: type)
                        Spacer()
                    }

                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.NeutralDark2)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, -7.0)
    }
}

#Preview {
    WorkoutHistory(title: "Chest & Back", image: "figure.run", date: "8/12/24", type: .preset)
}
