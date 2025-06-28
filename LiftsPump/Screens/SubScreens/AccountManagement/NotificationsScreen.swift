//
//  NotificationsScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/19/24.
//

import SwiftUI

struct NotificationsScreen: View {
    @StateObject var friendsManager = FriendsManager()
    @State private var usernames: [UUID: String] = [:]

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
                ForEach(friendsManager.friendRequests.indices, id: \.self) { index in
                    let friend = friendsManager.friendRequests[index]
                    let username = usernames[friend.creator_id] ?? "Loading..."
                    Person(image: "checkmark", action: "Accept", text: username+" added you", profileImage: "person.crop.circle")
                        .onTapGesture {
                            Task {
                                do {
                                    try await friendsManager.acceptFriend(friendToAdd: friend)
                                } catch {
                                    print("Add friend failed: \(error.localizedDescription)")
                                }
                            }
                        }
                        .onAppear {
                            Task {
                                if usernames[friend.creator_id] == nil {
                                    if let name = await friendsManager.getUsername(profileToFind: friend.creator_id) {
                                        usernames[friend.creator_id] = name
                                    }
                                }
                            }
                        }
                }
            } .onAppear{
                Task {
                    await friendsManager.getFR()
                }
            }
            /*VStack(alignment: .leading) {
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
            }*/
            
        } .background(Theme.Colors.NeutralDark)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
    }
}

#Preview {
    NotificationsScreen()
}
