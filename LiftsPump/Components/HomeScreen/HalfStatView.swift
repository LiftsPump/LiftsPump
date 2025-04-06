//
//  HalfStatView.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/11/24.
//

import SwiftUI

struct HalfStatView: View {
    var image: String
    var stat: Int
    var subText: String
    var title: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: image)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 25))
                Text(title)
                    .foregroundStyle(Color.white)
            }.padding([.top, .bottom], -2.0)
                .padding(.leading, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text("\(stat)")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 20, weight: .bold))
                Text(subText)
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 15, weight: .light))
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.NeutralDark)
            .cornerRadius(10)
            .padding(2)
            .shadow(color: Color(red: 0.3, green: 0.3, blue: 0.3), radius: 20)            .padding(.top, -7.0)

    }
}

#Preview {
    HalfStatView(image: "flame", stat: 10, subText: "days in a row!", title: "Your streak")
}
