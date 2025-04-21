import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import Supabase

struct SignIn: View {
    @AppStorage("EMAIL_KEY") var email: String = ""
    @State var result: Result<Void, Error>?
    @State var password: String = ""
    @State private var isSignInSuccessful = false
    @State private var errorMessage: String?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            Spacer()
            Text("Sign In")
                .foregroundStyle(Theme.Colors.NeutralLight1)
                .font(Theme.Fonts.Heading6)
                .padding()

            VStack {
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
              await supaManager.initSync()
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
