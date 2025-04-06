//
//  StatView.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/11/24.
//

import SwiftUI

struct StatView: View {
    var stat: Int
    var image: String
    
    var body: some View {
        VStack() {
            HStack {
                Image(systemName: image)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 25))
                Text("Completed")
                    .foregroundStyle(Color.white)
                    .font(Theme.Fonts.SubHeading3)
            }.padding(.top, -2.0)
            Text("\(stat)")
                .foregroundStyle(Color.white)
                .font(Theme.Fonts.Heading1)
            Text("workouts\ncomplete")
                .foregroundStyle(Color.gray)
                .font(Theme.Fonts.Body4)
                
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.NeutralDark)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding(4)
            .padding(.leading, 10)
            .shadow(color: Color(red: 0.3, green: 0.3, blue: 0.3), radius: 20)            .padding(.top, -7.0)
    }
}

#Preview {
    StatView(stat: 21, image: "checkmark.circle")
}
