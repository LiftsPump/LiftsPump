//
//  CreateUsername.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 8/31/25.
//

import SwiftUI

struct CreateUsername: View {
    @State private var errorMessage: String?
    @AppStorage("USERNAME_KEY") var username: String = ""
    @State private var navigate = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Create a Username")
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.Heading6)
                    .padding()
                Text("No spaces")
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.Body3)
                    .padding(.horizontal)
                TextBoxSignUp(placeHolder: "Username", info: $username, password: false)
                Button(action: {
                    Task {
                        do {
                            try await SupaBaseManager.usernameCreate(username: username)
                            await MainActor.run {
                                navigate = true
                            }
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    GeneralButton(text: "Create Username", color: Theme.Colors.Primary1, image: "person.circle.fill", hollow: false)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                NavigationLink(destination: Tab().navigationBarHidden(true), isActive: $navigate) {
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Theme.Colors.NeutralDark, Theme.Colors.NeutralDark, Theme.Colors.PurpleGradient]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

#Preview {
    CreateUsername()
}
