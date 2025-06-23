//
//  ConfirmEmail.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 2/25/25.
//

import SwiftUI
import Supabase

struct ConfirmEmail: View {
    @State private var isEmailConfirmed = false
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("EMAIL_KEY") var email: String = ""
    @AppStorage("USERNAME_KEY") var username: String = ""
    @AppStorage("PASSWORD_KEY") var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 175))
                Text("Check your inbox!")
                    .font(Theme.Fonts.Heading3)
                Text("Once you confirm your email you will be brought to the login screen.")
                    .font(Theme.Fonts.SubHeading3)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Theme.Colors.NeutralDark, Theme.Colors.NeutralDark, Theme.Colors.PurpleGradient]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationDestination(isPresented: $isEmailConfirmed) {
                Tab().navigationBarBackButtonHidden(true)
            }
            .onAppear {
                Task {
                    await checkEmailConfirmation(email: email, password: password)
                }
            }
        }
    }
    
    private func checkEmailConfirmation(email: String, password: String) async {
        print("Checking email confirmation and logging in...")

        while true {
            do {
                let session = try await supabase.auth.signIn(email: email, password: password)
                if session.user.emailConfirmedAt != nil {
                    print("Email confirmed! Navigating...")
                    let profileData = Profile(first_name: firstName, last_name: lastName, phone_number: "", height: 0, weight: 0, dob: Date(), type: 1, last_synced: Date(timeIntervalSince1970: 0), username: username, email: email)
                    try await supabase
                        .from("profile")
                        .upsert(profileData)
                        .execute()
                    isEmailConfirmed = true
                    self.password = ""
                    return
                } else {
                    print("Email not confirmed yet. Retrying login in 0.5s...")
                }
            } catch {
                print("Login failed: \(error)")
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}

#Preview {
    ConfirmEmail()
}
