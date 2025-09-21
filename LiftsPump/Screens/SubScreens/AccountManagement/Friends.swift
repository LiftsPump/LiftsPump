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
    @State private var usernames: [UUID: String] = [:]
    @State private var searchOrAdd: Bool = true
    var ont: String?

    var body: some View {
        ScrollView {
            HStack {
                Text("Add collaborators to your workout!")
                    .font(Theme.Fonts.SubHeading9)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .accessibilityLabel("Close")
            } .padding()
            HStack {
                Text("Add friends")
                    .font(Theme.Fonts.SubHeading8)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            } .padding(.horizontal)
            Button(action: {
                withAnimation { searchOrAdd.toggle() }
            }) {
                GeneralButton(text: (searchOrAdd ? "Search for friends" : "My friends"), color: Theme.Colors.Primary1, image: "text.page")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(searchOrAdd ? "Switch to search" : "Show my friends")
            if searchOrAdd {
                HStack {
                    Text("Your friends")
                        .font(Theme.Fonts.SubHeading8)
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                    Spacer()
                } .padding(.horizontal)
                ForEach(friendsManager.friendsList.indices, id: \.self) { index in
                    let friend = friendsManager.friendsList[index]
                    let currentUserId = supabase.auth.currentUser?.id
                    let otherId = (friend.creator_id == currentUserId) ? friend.requestee : friend.creator_id
                    let username = usernames[otherId] ?? "Loading..."
                    if friend.status == 2 {
                        Rectangle()
                            .fill(Theme.Colors.NeutralDarkGray1)
                            .frame(width: .infinity, height: 2)
                            .ignoresSafeArea(edges: .horizontal)
                            .padding(.horizontal)
                        Person(image: "plus", action: "Invite", text: "\(username)", profileImage: "person.crop.circle", onTap: {
                            print("hey")
                        })
                            .onAppear {
                                Task {
                                    if usernames[otherId] == nil {
                                        if let name = await friendsManager.getUsername(profileToFind: otherId) {
                                            usernames[otherId] = name
                                        }
                                    }
                                }
                            }
                    }
                }
            } else {
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
                    .submitLabel(.search)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .onSubmit {
                        Task {
                            await friendsManager.searchFriends(searchText: searchText)
                        }
                    }
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
                        .ignoresSafeArea(edges: .horizontal)
                        .padding(.horizontal)
                    Person(
                        image: "plus",
                        action: "Add",
                        text: "\(friend.first_name + " " + friend.last_name)",
                        profileImage: "person.crop.circle",
                        onTap: {
                            Task {
                                await friendsManager.addFriend(friendToAdd: friend)
                            }
                        }
                    )
                }
            }
            Rectangle()
                .fill(Theme.Colors.NeutralDarkGray1)
                .frame(width: .infinity, height: 2)
                .ignoresSafeArea(edges: .horizontal)
                .padding(.horizontal)
            Spacer()
        } .background(Theme.Colors.NeutralDark)
            .animation(.snappy(duration: 0.3), value: searchOrAdd)
            .sensoryFeedback(.selection, trigger: searchOrAdd)
        .task {
            await friendsManager.getFriends()
        }
    }
}

#Preview {
    Friends()
}
