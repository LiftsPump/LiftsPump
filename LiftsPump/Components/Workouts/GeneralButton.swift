//
//  RepeatButton.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/26/24.
//

import SwiftUI

import SwiftUI

struct GeneralButton: View {
    var text: String
    var color: Color
    var image: String
    var hollow: Bool?

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(hollow == true ? Theme.Colors.NeutralDark : color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(hollow == true ? color : .clear, lineWidth: 2)
            )
            .overlay(
                HStack {
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .padding(.trailing, -6)
                        .foregroundStyle(hollow == true ? color : Theme.Colors.NeutralDark)
                    Text(text)
                        .font(Theme.Fonts.Body5)
                        .padding(.trailing, 6)
                        .foregroundStyle(hollow == true ? color : Theme.Colors.NeutralDark)
                }
                .foregroundStyle(Theme.Colors.NeutralDark)
            )
            .frame(height: 36)
            .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 12) {
        GeneralButton(text: "Repeat Hollow", color: Theme.Colors.Primary1, image: "repeat", hollow: true)
        GeneralButton(text: "Repeat Solid", color: Theme.Colors.Primary1, image: "repeat", hollow: false)
    }
}
