import SwiftUI

struct FourthOnboarding: View {
    @Environment(\.openURL) private var openURL
    @State private var showDisclaimer = false
    @State private var showAccessory = false
    @State private var agreeDisclaimer = false
    @State private var agreePrivacy = false
    
    var body: some View {
        ZStack {
            Theme.Colors.NeutralDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Medical Disclaimer & Privacy")
                    .font(Theme.Fonts.Heading6)
                    .foregroundColor(Theme.Colors.NeutralLight1)
                    .multilineTextAlignment(.center)
                
                Text("By continuing, you agree to our Medical Disclaimer and Privacy Policy.")
                    .font(Theme.Fonts.Body3)
                    .foregroundColor(Theme.Colors.NeutralLight1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                VStack(spacing: 12) {
                    Button {
                        showDisclaimer = true
                    } label: {
                        Text("View Medical Disclaimer")
                            .font(Theme.Fonts.Body3)
                            .foregroundColor(Theme.Colors.NeutralLight1)
                            .underline()
                    }
                    .sheet(isPresented: $showDisclaimer) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Medical Disclaimer")
                                    .font(Theme.Fonts.Heading6)
                                    .foregroundColor(Theme.Colors.NeutralLight1)
                                
                                Text("""
                                Liftspump does not provide medical advice.
                                All content and AI-generated responses are for informational purposes only and are not a substitute for professional medical guidance.
                                """)
                                .font(Theme.Fonts.Body3)
                                .foregroundColor(Theme.Colors.NeutralLight1)

                                Text("""
                                Before beginning any fitness, nutrition, or exercise program, you agree to consult a licensed physician to confirm it is safe for you.

                                By using Liftspump, you acknowledge and accept all risks associated with physical activity. You are fully responsible for your own health decisions and outcomes.

                                Liftspump, its trainers, and its AI systems are not liable for any injuries, health complications, or damages resulting from use of the platform.

                                AI outputs may be inaccurate, incomplete, or outdated. You agree to verify all information independently.

                                Trainers are not medical professionals and may not be certified. They cannot diagnose, treat, or prescribe.

                                Stop exercising immediately if you feel pain, dizziness, or discomfort and contact emergency services (911 or local equivalent).

                                This agreement may be updated. Continued use signifies acceptance.

                                Not intended for users under 18 without parental consent.
                                """)
                                .font(Theme.Fonts.Body3)
                                .foregroundColor(Theme.Colors.NeutralLight1)
                                .font(Theme.Fonts.Body3)
                                .foregroundColor(Theme.Colors.NeutralLight1)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .background(
                            Theme.Colors.NeutralDark
                                .ignoresSafeArea()
                        )
                    }
                    
                    Button {
                        // will open external privacy policy URL
                        openURL(URL(string: "https://liftspump.com/privacy-policy")!)
                    } label: {
                        Text("View Privacy Policy")
                            .font(Theme.Fonts.Body3)
                            .foregroundColor(Theme.Colors.NeutralLight1)
                            .underline()
                    }
                }
                
                Image("Onboarding4")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(Theme.Colors.NeutralGray1)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Theme.Colors.NeutralGray1)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Theme.Colors.NeutralGray1)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Theme.Colors.Primary1)
                        .frame(width: 10, height: 10)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    CheckmarkRow(
                        title: "I agree to the Medical Disclaimer",
                        isOn: $agreeDisclaimer
                    )
                    CheckmarkRow(
                        title: "I agree to the Privacy Policy",
                        isOn: $agreePrivacy
                    )
                }
                .padding(.horizontal, 4)

                NavigationLink {
                    SignUp()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    onboardButton()
                        .opacity((agreeDisclaimer && agreePrivacy) ? 1 : 0.5)
                }
                .disabled(!(agreeDisclaimer && agreePrivacy))
                
                Text("Skip")
                    .font(Theme.Fonts.Body4)
                    .foregroundColor(Theme.Colors.NeutralLight1)
                    .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.impact, trigger: showAccessory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FourthOnboarding()
}

private struct CheckmarkRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: 12) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isOn ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1)
                Text(title)
                    .font(Theme.Fonts.Body3)
                    .foregroundColor(Theme.Colors.NeutralLight1)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
