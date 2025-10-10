//
//  AddFriends.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 6/29/25.
//
// Archive file for later when implementing contacts

import SwiftUI

struct AddFriends: View {
    @State private var searchText: String = ""
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @StateObject var friendsManager = FriendsManager()

    var body: some View {
        ScrollView {
            HStack {
                Text("Find friends")
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
                .onChange(of: searchText) { query in
                    Task {
                        await friendsManager.searchFriends(searchText: query)
                    }
                }
            if friendsManager.contacts.count > 0, let firstletter = friendsManager.contacts[0].givenName.first {
                LetterSeperator(letter: "\(firstletter.uppercased())")
            }
            ForEach(friendsManager.friendsSearch.indices, id: \.self) { index in
                let friend = friendsManager.friendsSearch[index]
                Rectangle()
                    .fill(Theme.Colors.NeutralDarkGray1)
                    .frame(width: .infinity, height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.horizontal)
                Person(image: "plus", action: "Add", text: "\(friend.username+" ("+friend.first_name+" "+friend.last_name)", profileImage: "person.crop.circle")
                    .onTapGesture {
                        Task {
                            do {
                                try await friendsManager.addFriend(friendToAdd: friend)
                            }
                        }
                    }
            }
            /*ForEach(friendsManager.contacts.indices, id: \.self) { index in
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
            }*/
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
    AddFriends()
}
