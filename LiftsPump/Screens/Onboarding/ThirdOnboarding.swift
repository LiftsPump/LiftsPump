//
//
//  FirstOnboarding.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/1/24.
//

import SwiftUI

struct ThirdOnboarding: View {
    @State private var showAccessory = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Connect with friends")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Heading6)
                .padding()
            Text("Enjoy our social features that help you stay connected and update your friends on your fitness journey.")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Body3)
                .padding(.horizontal)
            Image("Onboarding3")
                .resizable()
                .frame(width: .infinity, height: (300))
            HStack {
                Spacer()
                Circle()
                    .fill(Theme.Colors.NeutralGray1)
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Theme.Colors.NeutralGray1)
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Theme.Colors.Primary1)
                    .frame(width: 10, height: 10)
                Spacer()
            }
            NavigationLink(destination: SignUp().navigationBarBackButtonHidden(true)) {
                onboardButton()
                    .padding(.vertical)
            }
            Text("Skip")
                .font(Theme.Fonts.Body4)
            Spacer()
        } .frame(width: .infinity, height: .infinity)
            .sensoryFeedback(.impact, trigger: showAccessory)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Theme.Colors.NeutralDark, Theme.Colors.NeutralDark, Theme.Colors.PurpleGradient]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

#Preview {
    ThirdOnboarding()
}
