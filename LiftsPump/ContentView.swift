import SwiftUI
import GoogleSignIn
import Supabase

struct ContentView: View {
    @AppStorage("ISNEW_KEY") var new: Bool = true

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
    }
    func checkUserLoginStatus() -> Bool {
        if (supabase.auth.currentUser != nil) {
            return(true)
        } else {
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Routine.self, Exercise.self, ESet.self, PRData.self])
    }
}
