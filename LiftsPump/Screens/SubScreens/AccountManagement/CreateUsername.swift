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
    
    @AppStorage("FIRSTNAME_KEY") private var firstName: String = ""
    @AppStorage("LASTNAME_KEY") private var lastName: String = ""
    @AppStorage("EMAIL_KEY") private var email: String = ""
    @AppStorage("HEIGHT_KEY") private var height: Int = 0
    @AppStorage("WEIGHT_KEY") private var weight: Int = 0
    @AppStorage("DOB_KEY") private var dob: Double = Date().timeIntervalSince1970
    
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
                HStack {
                    TextBoxSignUp(placeHolder: "First Name (optional)", info: $firstName, password: false)
                    TextBoxSignUp(placeHolder: "Last Name (optional)", info: $lastName, password: false)
                }
                HStack {
                    NumberTextbox(title: "Height (In)", placeHolder: "74\"", info: $height)
                    NumberTextbox(title: "Weight (Lb)", placeHolder: "170", info: $weight)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth date (optional)")
                            .font(Theme.Fonts.Body4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.horizontal, 10)
                        DatePicker("Birth date", selection: Binding(
                            get: { Date(timeIntervalSince1970: dob) },
                            set: { dob = $0.timeIntervalSince1970 }
                        ), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(10)
                            .frame(width: 100)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                            .scaleEffect(0.9)
                    }
                }
                Button(action: {
                    Task {
                        do {
                            try await SupaBaseManager.usernameCreate(username: username)
                            // Optionally upsert profile with provided fields
                            await MainActor.run {
                                navigate = true
                                SupaBaseManager.saveProfile(first_name: firstName, last_name: lastName, phone_number: "", height: height, weight: weight, dob: Date(timeIntervalSince1970: dob), type: 1, last_synced: Date(timeIntervalSince1970: 1), username: username, email: email)
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
