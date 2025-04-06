//
//  SignUpButton.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/4/24.
//

import SwiftUI

struct SignUpButton: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Theme.Colors.Primary1)
            .overlay(HStack {Text("Sign Up")
                    .font(Theme.Fonts.Body5)
            })
            .foregroundStyle(Theme.Colors.NeutralDark)
            .frame(height: 36)
            .cornerRadius(4)
            .padding(.horizontal)
    }
}

#Preview {
    SignUpButton()
}
