//
//  YourFriends.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 7/6/25.
//

import SwiftUI

struct YourFriends: View {
    @StateObject private var friendsManager = FriendsManager()
    @State private var usernames: [UUID: String] = [:]
    @Binding var selectededTab: ExerciseTabs
    @State var prSelected: PRRecord

    var body: some View {
        VStack {
            HStack {
                Text("Ask friends to confirm your PR!")
                    .font(Theme.Fonts.SubHeading9)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .onTapGesture {
                        selectededTab = .prs
                    }
            } .padding()
            ForEach(friendsManager.friendsList.indices, id: \.self) { index in
                let friend = friendsManager.friendsList[index]
                let currentUserId = supabase.auth.currentUser?.id
                let otherId = (friend.creator_id == currentUserId) ? friend.requestee : friend.creator_id
                let username = usernames[otherId] ?? "Loading..."
                if friend.status == 2 {
                    Rectangle()
                        .fill(Theme.Colors.NeutralDarkGray1)
                        .frame(width: .infinity, height: 2)
                        .edgesIgnoringSafeArea(.horizontal)
                        .padding(.horizontal)
                    Person(image: "plus", action: "Ask", text: "\(username)", profileImage: "person.crop.circle", onTap: {
                        SupaBaseManager.prConfirmsSend(requestee_id: otherId, pr_id: prSelected.supaId)
                        withAnimation{
                            selectededTab = .prs
                        }
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
            Spacer()
        } .onAppear {
            Task {
                await friendsManager.getFriends()
            }
        }
    }
}

#Preview {
    //YourFriends(friendToSend: .constant(Friend()))
}
