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
                        guard let rootController = await UIApplication.getTopViewController() else {
                            errorMessage = "No root view controller found"
                            return
                        }

                        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootController)

                        // Seed local fields from Google profile
                        if let profile = result.user.profile {
                            let mail = profile.email
                            if email.isEmpty { email = mail }
                            if let given = profile.givenName, firstName.isEmpty { firstName = given }
                            if let family = profile.familyName, lastName.isEmpty { lastName = family }
                            if username.isEmpty {
                                if let base = mail.split(separator: "@").first {
                                    username = String(base)
                                }
                            }
                        }

                        guard let idToken = result.user.idToken?.tokenString else {
                            errorMessage = "No idToken found."
                            return
                        }

                        let accessToken = result.user.accessToken.tokenString

                        let session = try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(
                                provider: .google,
                                idToken: idToken,
                                accessToken: accessToken
                            )
                        )

                        print("Signed in with Google, user id: \(session.user.id)")
                        let seededUsername = username.isEmpty ? (email.split(separator: "@").first.map(String.init) ?? "") : username
                        let profileData = Profile(first_name: firstName, last_name: lastName, phone_number: "", height: 0, weight: 0, dob: Date(), type: 1, last_synced: Date(timeIntervalSince1970: 0), username: seededUsername, email: email, trainer: nil)
                        try await supabase
                            .from("profile")
                            .upsert(profileData)
                            .execute()
                        isSSOSignInSuccessful = true
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
                            print(credential.fullName!.givenName)
                            if let newEmail = credential.email {
                                email = newEmail
                            }
                            if let fN = credential.fullName?.givenName {
                                firstName = fN
                            }
                            if let lN = credential.fullName?.familyName {
                                lastName = lN
                            }
                            if username.isEmpty {
                                if !email.isEmpty, let base = email.split(separator: "@").first { username = String(base) }
                            }

                            print("Signed in with Apple, user id: \(session.user.id)")
                            let seededUsername = username.isEmpty ? (email.split(separator: "@").first.map(String.init) ?? "") : username
                            let profileData = Profile(first_name: firstName, last_name: lastName, phone_number: "", height: 0, weight: 0, dob: Date(), type: 1, last_synced: Date(timeIntervalSince1970: 0), username: seededUsername, email: email, trainer: nil)
                            try await supabase
                                .from("profile")
                                .upsert(profileData)
                                .execute()
                            isSSOSignInSuccessful = true
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
