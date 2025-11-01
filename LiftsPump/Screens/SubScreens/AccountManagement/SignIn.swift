import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import Supabase

struct SignIn: View {
    @AppStorage("EMAIL_KEY") var email: String = ""
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("USERNAME_KEY") var username: String = ""
    @State var result: Result<Void, Error>?
    @State var password: String = ""
    @State private var isSignInSuccessful = false
    @State private var errorMessage: String?
    @State private var isSSOSignInSuccessful = false
    @State private var navigateToCreateUsername = false
    @Environment(\.modelContext) private var modelContext

    private func populateNamesFromSession(_ session: Session) throws {
        if firstName.isEmpty {
            if let given = session.user.userMetadata["given_name"]?.stringValue {
                firstName = given
            } else if let full = session.user.userMetadata["full_name"]?.stringValue {
                firstName = full.split(separator: " ").first.map(String.init) ?? full
            } else if let name = session.user.userMetadata["name"]?.stringValue {
                firstName = name.split(separator: " ").first.map(String.init) ?? name
            }
        }
        if lastName.isEmpty {
            if let family = session.user.userMetadata["family_name"]?.stringValue {
                lastName = family
            } else if let full = session.user.userMetadata["full_name"]?.stringValue {
                let parts = full.split(separator: " ")
                if parts.count > 1 {
                    lastName = parts.dropFirst().joined(separator: " ")
                }
            }
        }
        if email.isEmpty, let authEmail = session.user.email {
            email = authEmail
        }
        if username.isEmpty, !email.isEmpty, let base = email.split(separator: "@").first {
            username = String(base)
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Sign In")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Heading6)
                .padding()

            VStack {
                TextBoxSignUp(placeHolder: "Email", info: $email, password: false)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                TextBoxSignUp(placeHolder: "Password", info: $password, password: true)
                    .textContentType(.password)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }

            Button(action: {
                signInWithEmail()
            }) {
                SignInButton()
                    .padding(.vertical)
            }
            if let result {
                if case .failure(let error) = result {
                    Text(error.localizedDescription)
                } else {
                    
                }
            }

            NavigationLink(destination: Tab().navigationBarBackButtonHidden(true), isActive: $isSignInSuccessful) {
                EmptyView()
            }
            NavigationLink(destination: Tab().navigationBarBackButtonHidden(true), isActive: $isSSOSignInSuccessful) {
                EmptyView()
            }
            NavigationLink(destination: CreateUsername().navigationBarBackButtonHidden(true), isActive: $navigateToCreateUsername) {
                EmptyView()
            }

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal)
                Text("Or")
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.Body5)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            
            GoogleSignInButton(scheme: .dark, style: .wide, state: .normal) {
                Task { @MainActor in
                    do {
                        let session = try await supabase.auth.signInWithOAuth(
                            provider: .google,
                            redirectTo: URL(string: "myapp://auth-callback")!
                        )
                        try? populateNamesFromSession(session)
                        let existing = try await SupaBaseManager.fetchProfiles(creatorId: session.user.id)
                        if existing.isEmpty {
                            navigateToCreateUsername = true
                        } else {
                            isSSOSignInSuccessful = true
                        }
                    } catch {
                        errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                    }
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    Task {
                        do {
                            guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                                return
                            }
                            guard let idToken = credential.identityToken
                                .flatMap({ String(data: $0, encoding: .utf8) }) else {
                                return
                            }

                            let session = try await supabase.auth.signInWithIdToken(
                                credentials: .init(
                                    provider: .apple, idToken: idToken
                                )
                            )
                            if let newEmail = credential.email {
                                email = newEmail
                            }
                            if let fN = credential.fullName?.givenName {
                                firstName = fN
                            }
                            if let lN = credential.fullName?.familyName {
                                lastName = lN
                            }

                            try? populateNamesFromSession(session)

                            let existing = try await SupaBaseManager.fetchProfiles(creatorId: session.user.id, limit: 1)
                            if existing.isEmpty {
                                navigateToCreateUsername = true
                            } else {
                                isSSOSignInSuccessful = true
                            }
                        } catch {
                            errorMessage = "Apple sign-in failed: \(error.localizedDescription)"
                        }
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal)
            .signInWithAppleButtonStyle(.whiteOutline)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onOpenURL(perform: { url in
          Task {
            do {
              try await supabase.auth.session(from: url)
            } catch {
              self.result = .failure(error)
            }
          }
        })
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Theme.Colors.NeutralDark, Theme.Colors.NeutralDark, Theme.Colors.PurpleGradient]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Sign Up with Supabase
    func signInWithEmail() {
        Task {
          do {
              try await supabase.auth.signIn(email: email, password: password)
              _ = try await supabase.auth.session
              result = .success(())
              isSignInSuccessful = true
              let supaManager = SupaBaseManager(context: modelContext)
              try await supaManager.initSync()
              print(supabase.auth.user)
          } catch {
              result = .failure(error)
          }
        }
    }
}

#Preview {
    SignIn()
}
