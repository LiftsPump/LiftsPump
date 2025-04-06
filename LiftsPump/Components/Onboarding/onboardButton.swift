//
//  Button.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/1/24.
//

import SwiftUI

struct onboardButton: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Theme.Colors.Primary1)
            .overlay(HStack {Text("Next")
                    .font(Theme.Fonts.Body5)
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
            })
            .foregroundStyle(Theme.Colors.NeutralDark)
            .frame(height: 36)
            .cornerRadius(4)
            .padding(.horizontal)
    }
}

#Preview {
    onboardButton()
}
