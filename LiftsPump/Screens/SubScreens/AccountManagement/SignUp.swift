import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import Supabase
import GoogleSignIn

struct SignUp: View {
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("EMAIL_KEY") var email: String = ""
    @AppStorage("USERNAME_KEY") var username: String = ""
    @AppStorage("PASSWORD_KEY") var password: String = ""
    @State private var isSignInSuccessful = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer()
            Text("Create an account")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Heading6)
                .padding()
            Text("Sign up to get started!")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Body3)
                .padding(.horizontal)

            VStack {
                HStack {
                    TextBoxSignUp(placeHolder: "First Name", info: $firstName, password: false)
                    TextBoxSignUp(placeHolder: "Last Name", info: $lastName, password: false)
                }
                TextBoxSignUp(placeHolder: "Username", info: $username, password: false)
                TextBoxSignUp(placeHolder: "Email", info: $email, password: false)
                TextBoxSignUp(placeHolder: "Password", info: $password, password: true)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }

            Button(action: {
                signUpWithEmail()
            }) {
                SignUpButton()
                    .padding(.vertical)
            }

            NavigationLink(destination: ConfirmEmail().navigationBarBackButtonHidden(true), isActive: $isSignInSuccessful) {
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
            Button(action: {
                Task {
                    //await googleSignIn()
                }
            }) {
                HStack {
                    GoogleSignInButton(scheme: .dark, style: .wide, state: .normal, action: {})
                    
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                .frame(height: 50)
            }
            .padding(.horizontal)
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            let userIdentifier = appleIDCredential.user
                            let fullName = appleIDCredential.fullName
                            email = appleIDCredential.email ?? ""
                            
                            if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                                firstName = givenName
                                lastName = familyName
                            }
                            print("Apple Sign-In ID: \(userIdentifier)")
                            isSignInSuccessful = true
                        }
                    case .failure(let error):
                        errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal)
            .signInWithAppleButtonStyle(.whiteOutline)

            HStack {
                Text("Already have an account?")
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .font(Theme.Fonts.Body3)
                NavigationLink(destination: SignIn()) {
                    Text("Sign in")
                        .foregroundStyle(Theme.Colors.Primary1)
                        .font(Theme.Fonts.Body3)
                }
            }
            Spacer()
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
    func signUpWithEmail() {
        Task {
            do {
                if supabase == nil {
                    print("Supabase client is not initialized! Make sure you initialized it properly.")
                    return
                }
                // Enforce a timeout of 10 seconds
                let response = try await withTimeout(seconds: 10) {
                    try await supabase.auth.signUp(
                        email: email,
                        password: password
                    )
                }
                print("User created: \(response.user.id)")
                isSignInSuccessful = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "Timeout", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
            }
            return try await group.next()!
        }
    }
}

#Preview {
    SignUp()
}
