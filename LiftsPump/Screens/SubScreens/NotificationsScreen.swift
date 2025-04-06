//
//  NotificationsScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/19/24.
//

import SwiftUI

struct NotificationsScreen: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("Notifications")
                    .font(Theme.Fonts.Heading4)
                    .foregroundStyle(Theme.Colors.Primary1)
                    .padding(.leading)
                Spacer()
            }
            VStack(alignment: .leading) {
                Rectangle()
                    .fill(Theme.Colors.Primary1)
                    .frame(width: .infinity, height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.horizontal)
                Text("Today")
                    .font(Theme.Fonts.SubHeading5)
                    .padding(.leading)
                Person(image: "eye", action: "View", text: "You have one new notification from your friend", profileImage: "person.crop.circle")
                    .padding(.top, -17)
                Person(image: "checkmark", action: "Accept", text: "Some nonsense about adding this confirming this wtv", profileImage: "person.crop.circle")
            }
            VStack(alignment: .leading) {
                Rectangle()
                    .fill(Theme.Colors.Primary1)
                    .frame(width: .infinity, height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.horizontal)
                Text("Last week")
                    .font(Theme.Fonts.SubHeading5)
                    .padding(.leading)
                Person(image: "checkmark", action: "Accept", text: "Some nonsense about adding this confirming this wtv", profileImage: "person.crop.circle")
                    .padding(.top, -17)
                Person(image: "eye", action: "View", text: "Some nonsense about adding this confirming this wtv", profileImage: "person.crop.circle")
            }
            
        } .background(Theme.Colors.NeutralDark)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
    }
}

#Preview {
    NotificationsScreen()
}
