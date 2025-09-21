import Foundation
import Combine
import Supabase

@MainActor
final class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Initialize from current user
        self.isAuthenticated = (supabase.auth.currentUser != nil)
    }

    func refresh() {
        // Refresh from current user
        self.isAuthenticated = (supabase.auth.currentUser != nil)
    }
}
