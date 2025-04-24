//
//  Friends.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 4/21/25.
//

import SwiftUI

struct Friends: View {
    @State private var searchText: String = ""
    var body: some View {
        ScrollView {
            HStack {
                Text("Add collaborators to your workout!")
                    .font(Theme.Fonts.SubHeading9)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.Colors.NeutralLight1)
            } .padding()
            HStack {
                Text("Find friends")
                    .font(Theme.Fonts.SubHeading8)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            } .padding(.horizontal)
            GeneralButton(text: "Find from contacts", color: Theme.Colors.Primary1, image: "text.page")
            HStack {
                Text("Your friends")
                    .font(Theme.Fonts.SubHeading8)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            } .padding(.horizontal)
            TextField("Search friends...", text: $searchText)
                .padding(8)
                .background(Theme.Colors.NeutralLight1)
                .cornerRadius(8)
                .foregroundStyle(Theme.Colors.NeutralDark)
                .accentColor(Theme.Colors.Primary1)
                .padding(.horizontal)
                .padding(.bottom, 30)
            LetterSeperator(letter: "A")
            Person(image: "plus", action: "Add", text: "Mr. Somebody", profileImage: "person.crop.circle")
            Rectangle()
                .fill(Theme.Colors.NeutralDarkGray1)
                .frame(width: .infinity, height: 2)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.horizontal)

            Spacer()
        } .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    Friends()
}
