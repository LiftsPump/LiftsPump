import SwiftUI
import GoogleSignIn
import Supabase

struct ContentView: View {
    @AppStorage("ISNEW_KEY") var new: Bool = true
    @AppStorage("APPEARANCE_KEY") private var appearance: String = "system"

    var body: some View {
        Group {
            if new {
                NavigationStack {
                    FirstOnboarding()
                        .onAppear {
                            new = false
                        }
                        .onOpenURL { url in
                            Task { @MainActor in
                                if !GIDSignIn.sharedInstance.handle(url) {
                                    // Forward to ASAuthorizationAppleIDProvider for Apple Sign-In if needed
                                    // Currently Apple Sign-In is handled automatically by AuthenticationServices
                                }
                            }
                        }
                }
            } else {
                NavigationStack {
                    if checkUserLoginStatus() {
                        Tab()
                    } else {
                        SignUp().navigationBarBackButtonHidden(true)
                            .onOpenURL { url in
                                Task { @MainActor in
                                    if !GIDSignIn.sharedInstance.handle(url) {
                                        // Forward to ASAuthorizationAppleIDProvider for Apple Sign-In if needed
                                        // Currently Apple Sign-In is handled automatically by AuthenticationServices
                                    }
                                }
                            }
                    }
                }
            }
        }
        .preferredColorScheme(resolvedScheme())
    }
    func checkUserLoginStatus() -> Bool {
        if (supabase.auth.currentUser != nil) {
            return(true)
        } else {
            return false
        }
    }
    private func resolvedScheme() -> ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Routine.self, Exercise.self, ESet.self, PRData.self])
    }
}
