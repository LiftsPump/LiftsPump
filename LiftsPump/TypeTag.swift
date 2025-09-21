import SwiftUI

struct TypeTag: View {
    let type: RoutineType

    private func label(for type: RoutineType) -> String {
        switch type {
        case .preset: return "Preset"
        case .assigned: return "Assigned"
        case .ai: return "AI"
        case .trainer: return "Trainer"
        case .custom: return "Custom"
        case .date: return "Scheduled"
        }
    }

    private func color(for type: RoutineType) -> Color {
        switch type {
        case .preset: return Theme.Colors.Primary1
        case .assigned: return .orange
        case .ai: return .purple
        case .trainer: return .teal
        case .custom: return .indigo
        case .date: return Theme.Colors.NeutralGray1
        }
    }

    var body: some View {
        Text(label(for: type))
            .font(Theme.Fonts.Body6)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color(for: type).opacity(0.95))
            .foregroundStyle(Theme.Colors.NeutralDark)
            .clipShape(Capsule())
            .shadow(radius: 2, x: 0, y: 1)
            .accessibilityLabel("Workout type: \(label(for: type))")
    }
}

#Preview {
    VStack(spacing: 8) {
        TypeTag(type: .preset)
        TypeTag(type: .assigned)
        TypeTag(type: .ai)
        TypeTag(type: .trainer)
        TypeTag(type: .custom)
        TypeTag(type: .date)
    }
    .padding()
    .background(Color.black)
}
