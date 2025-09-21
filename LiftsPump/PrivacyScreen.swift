import SwiftUI

struct PrivacyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy")
                    .font(.title)
                    .bold()
                Text("We value your privacy. This is a placeholder for your privacy information. Add details about data collection, usage, and controls.")
                Link("View full Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack { PrivacyScreen() }
}
