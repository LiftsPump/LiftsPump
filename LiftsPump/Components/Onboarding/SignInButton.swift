//
//  SignUpButton.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/4/24.
//

import SwiftUI

struct SignInButton: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Theme.Colors.Primary1)
            .overlay(HStack {Text("Sign In")
                    .font(Theme.Fonts.Body5)
            })
            .foregroundStyle(Theme.Colors.NeutralDark)
            .frame(height: 36)
            .cornerRadius(4)
            .padding(.horizontal)
    }
}

#Preview {
    SignInButton()
}
