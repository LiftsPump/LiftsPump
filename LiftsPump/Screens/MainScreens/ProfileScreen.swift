//
//  ProfileScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/17/24.
//

import SwiftUI
import Supabase

struct ProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("EMAIL_KEY") var email: String = ""
    @State private var showAccessory = false
    @State private var isLoggedOut = false
    @State private var isPresented = false

    var body: some View {
        ScrollView {
            HStack {
                Text("Profile")
                    .font(Theme.Fonts.Heading4)
                    .padding()
                    .foregroundStyle(Theme.Colors.Primary1)
                Spacer()
            }
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 65))
                    .padding(.horizontal, 10)
                Text("\(firstName) \(lastName)")
                    .font(Theme.Fonts.SubHeading4)
                Spacer()
            }
            VStack {
                NavigationLink(destination: MyInfoScreen()) {
                    Selectors(text: "My info", image: "person.fill")
                }
                NavigationLink(destination: Friends().navigationBarBackButtonHidden(true)) {
                    Selectors(text: "My friends", image: "person.2.fill")
                }
                NavigationLink(destination: SettingsScreen()) {
                    Selectors(text: "Settings", image: "gearshape.fill")
                }
                NavigationLink(destination: PrivacyScreen()) {
                    Selectors(text: "Privacy", image: "lock.fill")
                }
                Selectors(text: "Delete account", image: "trash.fill")
                    .onTapGesture {
                        withAnimation { isPresented = true }
                    }
                Selectors(text: "Help & Support", image: "questionmark")
                    .onTapGesture {
                        showAccessory.toggle()
                    }
                Selectors(text: "Log Out", image: "rectangle.portrait.and.arrow.right")
                    .onTapGesture {
                        showAccessory.toggle()
                        Task {
                            do {
                                try await supabase.auth.signOut()
                                isLoggedOut = true
                                firstName = ""
                                lastName = ""
                                email = ""
                            } catch {
                                print("failed")
                            }
                        }
                    }
                NavigationLink(destination: SignUp().navigationBarBackButtonHidden(true), isActive: $isLoggedOut) {
                    EmptyView()
                }
                Rectangle()
                    .fill(Theme.Colors.NeutralDarkGray1)
                    .frame(width: .infinity, height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .padding(.top, 10)
            }
        }
        .background(Theme.Colors.NeutralDark)
        .syncOnScroll()
        .sensoryFeedback(.selection, trigger: showAccessory)
        .popUp(
            isPresented: $isPresented,
            title: "Delete your account",
            message: "Are you sure you want to delete your account? You can't get your data back.",
            yesLabel: "Delete",
            noLabel: "Cancel",
            onYes: {
                // TODO: Implement account deletion. Requires a secure backend or Admin API.
                // For now, sign out and clear local keys.
                Task {
                    do {
                        try await supabase.functions
                          .invoke(
                            "delete-account",
                            options: FunctionInvokeOptions(
                              body: ["name": "Functions"]
                            )
                          )
                        try await supabase.auth.signOut()
                        isLoggedOut = true
                        firstName = ""
                        lastName = ""
                        email = ""
                    } catch {
                        print("Sign out failed: \(error)")
                    }
                }
            },
            onNo: {}
        )
    }
}

#Preview {
    ProfileScreen()
}
