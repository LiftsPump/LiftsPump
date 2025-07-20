//
//  NotificationsScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/19/24.
//

import SwiftUI

struct NotificationsScreen: View {
    @StateObject var friendsManager = FriendsManager()
    @StateObject private var exerciseManager = ExerciseListModel()
    @Environment(\.modelContext) private var modelContext
    @State private var usernames: [UUID: String] = [:]
    @State private var prInfo: [UUID: PRSupa] = [:]
    @State private var prRequests: [PRRequest] = []

    var body: some View {
        let prManager = PRManager(context: modelContext)
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
                    if friend.status == 1 {
                        Person(image: "checkmark", action: "Accept", text: username+" added you", profileImage: "person.crop.circle", onTap: {
                            Task {
                                do {
                                    await friendsManager.acceptFriend(friendToAdd: friend)
                                    await friendsManager.getFR()
                                }
                            }
                        })
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
                }
                ForEach(prRequests.indices, id: \.self) { index in
                    let request = prRequests[index]
                    let username = usernames[request.creator_id] ?? "Loading..."
                    let weight = prInfo[request.pr_id]?.value ?? 0
                    let name = exerciseManager.findById(prInfo[request.pr_id]?.eCode ?? "")?.name  ?? "Loading..."
                    
                    Person(image: "checkmark", action: "Confirm", text: "\(username) wants you to confirm a \(weight)lb PR in \(name)", profileImage: "person.crop.circle", onTap: {
                            Task {
                                do {
                                    SupaBaseManager.prAcceptOrDeny(requestee_id: request.requestee, pr_id: request.pr_id, action: "accept")
                                    prRequests = await prManager.getPRConfirms()
                                }
                            }
                        })
                            .onAppear {
                                Task {
                                    if usernames[request.creator_id] == nil {
                                        if let name = await friendsManager.getUsername(profileToFind: request.creator_id) {
                                            usernames[request.creator_id] = name
                                        }
                                    }
                                    if prInfo[request.pr_id] == nil {
                                        let prs = try await SupaBaseManager.checkPR(pr_id: request.pr_id)
                                        if let pr = prs.first {
                                            prInfo[request.pr_id] = pr
                                        }
                                    }
                                }
                            }
                }
            } .onAppear{
                Task {
                    await friendsManager.getFR()
                    prRequests = await prManager.getPRConfirms()
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
