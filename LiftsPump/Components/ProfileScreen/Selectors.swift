//
//  Selectors.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/24/24.
//

import SwiftUI

struct Selectors: View {
    var text: String
    var image: String
    var body: some View {
        VStack {
            Rectangle()
                .fill(Theme.Colors.NeutralDarkGray1)
                .frame(width: .infinity, height: 2)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            HStack {
                Image(systemName: "\(image)")
                    .font(.system(size: 25))
                    .padding(.leading, 10)
                    .frame(width: 40)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Text("\(text)")
                    .font(Theme.Fonts.SubHeading5)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
                    .padding(.trailing, 10)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
            }
        }
    }
}

#Preview {
    Selectors(text: "My info", image: "person")
}
