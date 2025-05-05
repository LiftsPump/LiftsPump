//
//  Friends.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 4/21/25.
//

import SwiftUI

struct Friends: View {
    @State private var searchText: String = ""
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject var friendsManager = FriendsManager()

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
                    .onTapGesture {
                        dismiss()
                    }
            } .padding()
            HStack {
                Text("Find friends")
                    .font(Theme.Fonts.SubHeading8)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            } .padding(.horizontal)
            GeneralButton(text: "Find from contacts", color: Theme.Colors.Primary1, image: "text.page")
                .onTapGesture {
                    Task{
                        await friendsManager.requestAccessAndFetchContacts()
                    }
                }
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
            if friendsManager.contacts.count > 0, let firstletter = friendsManager.contacts[0].givenName.first {
                LetterSeperator(letter: "\(firstletter.uppercased())")
            }
            ForEach(friendsManager.contacts.indices, id: \.self) { index in
                let contact = friendsManager.contacts[index]
                if let firstCharacter = contact.givenName.first {
                    let currentChar = String(firstCharacter).uppercased()
                    if index > 0 && String(friendsManager.contacts[index-1].givenName.first ?? "#").uppercased() != currentChar {
                        LetterSeperator(letter: currentChar)
                    }
                }
                Person(image: "plus", action: "Invite", text: "\(contact.givenName+" "+contact.familyName)", profileImage: "person.crop.circle")
                    .onTapGesture {
                        let contact = friendsManager.contacts[index]
                        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                            let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if let url = URL(string: "sms:\(cleanNumber)&body=Join%20\(firstName)%20on%20this%20app:%20https://liftspump.com") {
                                    UIApplication.shared.open(url)
                                }
                        }
                    }
            }
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
