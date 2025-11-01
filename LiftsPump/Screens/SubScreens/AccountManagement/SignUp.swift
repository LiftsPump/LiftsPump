import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import Supabase
import GoogleSignIn

extension UIApplication {
    static func getTopViewController(base: UIViewController? =
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return tab.selectedViewController.flatMap { getTopViewController(base: $0) }
        }

        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }

        return base
    }
}

struct SignUp: View {
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("EMAIL_KEY") var email: String = ""
    @AppStorage("USERNAME_KEY") var username: String = ""
    @AppStorage("PASSWORD_KEY") var password: String = ""
    @State private var isSignInSuccessful = false
    @State private var isSSOSignInSuccessful = false
    @State private var errorMessage: String?
    @State private var navigateToCreateUsername = false

    private func populateNamesFromSession(_ session: Session) throws {
        // Prefer provider metadata, do not overwrite if already set
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
                TextBoxSignUp(placeHolder: "Email", info: $email, password: false)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                TextBoxSignUp(placeHolder: "Password", info: $password, password: true)
                    .textContentType(.newPassword)
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
                        print("Signed in with Google, user id: \(session.user.id)")

                        // Populate local fields from provider metadata when available
                        try? populateNamesFromSession(session)

                        // Check if profile exists for this user; if not, navigate to username creation
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
                    request.requestedScopes = [.email, .fullName]
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

                            // Sign in with Supabase using the Apple ID token
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

                            print("Signed in with Apple, user id: \(session.user.id)")

                            // Populate local fields from provider metadata when available
                            try? populateNamesFromSession(session)

                            // Check if profile exists for this user; if not, navigate to username creation
                            let existing = try await SupaBaseManager.fetchProfiles(creatorId: session.user.id)
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

    private func ensureProfileIfNew(user: UUID) async throws {
        // Build a username from email if none provided
        let seededUsername = username.isEmpty ? (email.split(separator: "@").first.map(String.init) ?? "") : username

        // Check if a profile already exists for this email
        let existing: [Profile] = try await supabase
            .from("profile")
            .select()
            .eq("creator_id", value: user)
            .limit(1)
            .execute()
            .value

        // Only create if new
        if existing.isEmpty {
            let profileData = Profile(
                first_name: firstName,
                last_name: lastName,
                phone_number: "",
                height: 0,
                weight: 0,
                dob: Date(),
                type: 1,
                last_synced: Date(timeIntervalSince1970: 0),
                username: seededUsername,
                email: email,
                trainer: nil
            )
            try await supabase
                .from("profile")
                .upsert(profileData)
                .execute()
        }
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

