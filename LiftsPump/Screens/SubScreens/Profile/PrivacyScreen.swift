import SwiftUI

struct PrivacyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy")
                    .font(Theme.Fonts.Heading1)
                Text("We value your privacy. For the full privacy policy please open the link below:")
                    .font(Theme.Fonts.Body1)
                Link("View full Privacy Policy", destination: URL(string: "https://liftspump.com/privacy-policy")!)
            }
            .padding()
        }
        .background(Color(Theme.Colors.NeutralDark))
    }
}

#Preview {
    NavigationStack { PrivacyScreen() }
}
