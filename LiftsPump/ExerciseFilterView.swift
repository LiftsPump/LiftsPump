import SwiftUI

struct ExerciseFilterView: View {
    @Binding var selectedMuscles: Set<String>
    let availableMuscles: [String]
    @Binding var searchText: String
    var onApply: (Set<String>) -> Void
    @Environment(\.dismiss) private var dismiss

    private func isSelected(_ muscle: String) -> Bool { selectedMuscles.contains(muscle) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if !availableMuscles.isEmpty {
                    Text("Primary muscles")
                        .font(Theme.Fonts.SubHeading7)
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                        .padding(.horizontal)
                }
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
                Spacer()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        selectedMuscles.removeAll()
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
    ExerciseFilterView(selectedMuscles: .constant(["Chest", "Back"]), availableMuscles: ["Chest", "Back", "Legs", "Shoulders", "Arms", "Core"], searchText: .constant("")) { _ in }
}
