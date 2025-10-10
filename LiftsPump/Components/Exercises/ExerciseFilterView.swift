import SwiftUI

struct ExerciseFilterView: View {
    @Binding var selectedMuscles: Set<String>
    @Binding var selectedTools: Set<String>
    let availableMuscles: [String]
    let availableTools: [String]
    @Binding var searchText: String
    var onApply: (Set<String>) -> Void
    @Environment(\.dismiss) private var dismiss
    private enum Section { case muscles, tools }
    @State private var selectedSection: Section = .muscles

    private func isSelected(_ muscle: String) -> Bool { selectedMuscles.contains(muscle) }
    private func isToolSelected(_ tool: String) -> Bool { selectedTools.contains(tool) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if !availableMuscles.isEmpty {
                    Button(action: { withAnimation(.easeInOut) { selectedSection = .muscles } }) {
                        HStack {
                            Text("Primary muscles")
                                .font(Theme.Fonts.SubHeading7)
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                            Spacer()
                            Image(systemName: selectedSection == .muscles ? "chevron.down" : "chevron.right")
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                if selectedSection == .muscles {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(minimum: 80)), GridItem(.flexible(minimum: 80)), GridItem(.flexible(minimum: 80))], spacing: 12) {
                            ForEach(availableMuscles, id: \.self) { muscle in
                                let active = isSelected(muscle)
                                Text(muscle)
                                    .font(Theme.Fonts.Body5)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(active ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1)
                                    .foregroundStyle(active ? Theme.Colors.NeutralDark : Theme.Colors.NeutralLight1)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        var next = selectedMuscles
                                        if next.contains(muscle) { next.remove(muscle) } else { next.insert(muscle) }
                                        selectedMuscles = next
                                        // Apply immediately so the list updates while the sheet stays open
                                        onApply(next)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                if !availableTools.isEmpty {
                    Button(action: { withAnimation(.easeInOut) { selectedSection = .tools } }) {
                        HStack {
                            Text("Tools")
                                .font(Theme.Fonts.SubHeading7)
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                            Spacer()
                            Image(systemName: selectedSection == .tools ? "chevron.down" : "chevron.right")
                                .foregroundStyle(Theme.Colors.NeutralLight1)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                if selectedSection == .tools {
                    ScrollView() {
                        LazyVGrid(columns: [GridItem(.flexible(minimum: 100)), GridItem(.flexible(minimum: 60)), GridItem(.flexible(minimum: 100))], spacing: 12) {
                            ForEach(availableTools, id: \.self) { tool in
                                let active = isToolSelected(tool)
                                Text(tool)
                                    .font(Theme.Fonts.Body5)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(active ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1)
                                    .foregroundStyle(active ? Theme.Colors.NeutralDark : Theme.Colors.NeutralLight1)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        var next = selectedTools
                                        if next.contains(tool) { next.remove(tool) } else { next.insert(tool) }
                                        selectedTools = next
                                        onApply(selectedMuscles)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        selectedMuscles.removeAll()
                        selectedTools.removeAll()
                        onApply(selectedMuscles)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(selectedMuscles)
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.NeutralDark)
        }
    }
}

#Preview {
    ExerciseFilterView(
        selectedMuscles: .constant(["Chest", "Back"]),
        selectedTools: .constant(["Machine"]),
        availableMuscles: ["Chest", "Back", "Legs", "Shoulders", "Arms", "Core"],
        availableTools: ["Machine", "Dumbbell", "Barbell", "Kettlebell"],
        searchText: .constant("")
    ) { _ in }
}
