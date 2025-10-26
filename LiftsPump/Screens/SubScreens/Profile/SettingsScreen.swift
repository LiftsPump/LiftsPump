import SwiftUI

struct SettingsScreen: View {
    @AppStorage("APPEARANCE_KEY") private var appearance: String = "system"

    private let options: [(title: String, value: String)] = [
        ("System", "system"),
        ("Light", "light"),
        ("Dark", "dark")
    ]

    var body: some View {
        ScrollView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(options, id: \.value) { opt in
                            Text(opt.title).tag(opt.value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
        } .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    NavigationStack { SettingsScreen() }
}
