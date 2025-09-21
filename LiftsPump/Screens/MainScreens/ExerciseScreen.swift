import SwiftUI

struct ExerciseScreen: View {
    @StateObject private var viewModel = ExerciseListModel() // Create an instance of the model
    @State private var searchText = ""
    @Binding var selectedExercises: [ExerciseTemplate] // Binding to the selected exercises
    @Environment(\.dismiss) private var dismiss
    @State private var showAccessory = false
    @State var fromWorkout: Bool
    @State private var addExercise: Bool = false
    @State private var isPresented = false // Dictionary to track sheet state per exercise
    @State private var currentSelected = ExerciseTemplate(id: "12", name: "Arnold press", primaryMuscles: ["Tricep", "Bicep"], instructions: ["Instruction 1", "Instruction 2"], images: ["plus"])
    @State private var isFilterPresented: Bool = false
    @State private var selectedMuscles: Set<String> = []

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Exercises")
                        .font(Theme.Fonts.Heading4)
                        .padding()
                        .foregroundStyle(Theme.Colors.Primary1)
                    Spacer()
                    if !selectedExercises.isEmpty { // Check if there are selected exercises
                        GeneralButton(text: "Add", color: Theme.Colors.Primary1, image: "plus")
                            .frame(width: 120)
                            .onTapGesture {
                                dismiss()
                                showAccessory.toggle()
                            }
                    }
                }
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.Colors.NeutralDark2)
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Search")
                                    .foregroundColor(Theme.Colors.NeutralDark)
                                    .padding(8)
                            }
                            TextField("", text: $searchText)
                                .padding(8)
                                .foregroundStyle(Theme.Colors.NeutralDark)
                                .accentColor(Theme.Colors.Primary1)
                                .onChange(of: searchText) { query in
                                    viewModel.searchExercises(query: query)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .background(Theme.Colors.NeutralLight1)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    Spacer()
                    Image(systemName: "line.horizontal.3.decrease")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.Colors.NeutralLight1)
                        .padding(.trailing)
                        .onTapGesture {
                            isFilterPresented = true
                        }
                }
            }
            .background(Theme.Colors.NeutralDark)
            
            ScrollView {
                LazyVStack {
                    @State var lastnum: Character?
                    LetterSeperator(letter: viewModel.selectedExercises.first?.name.first?.uppercased() ?? "")
                        .padding(.top)
                    ForEach(viewModel.selectedExercises.indices, id: \.self) { index in
                        let exercise = viewModel.selectedExercises[index]
                        if let firstCharacter = exercise.name.first {
                            let currentChar = String(firstCharacter).uppercased()
                            if index > 0 && String(viewModel.selectedExercises[index-1].name.first ?? "#").uppercased() != currentChar {
                                LetterSeperator(letter: currentChar)
                            }
                        }
                        ExcerciseCard(
                            exercise: Binding(
                                get: { viewModel.selectedExercises[index] },
                                set: { viewModel.selectedExercises[index] = $0 }
                            ),
                            selected: selectedExercises.contains(where: { $0.id == exercise.id }) // Check if already selected
                        )
                        .onTapGesture {
                            showAccessory.toggle()
                            currentSelected = exercise
                            isPresented = true // Set the presentation state
                        }
                    }
                }
            }
            .background(Theme.Colors.NeutralDark)
            .syncOnScroll()
        }
        .background(Theme.Colors.NeutralDark)
        .sensoryFeedback(.selection, trigger: showAccessory)
        .sheet(isPresented: $isPresented, onDismiss: {
            if addExercise {
                if let existingIndex = selectedExercises.firstIndex(where: { $0.id == currentSelected.id }) {
                    selectedExercises.remove(at: existingIndex) // Remove if already selected
                } else {
                    selectedExercises.append(currentSelected) // Add to selection
                }
            }
        }) {
            ExerciseDetails(defaultTab: ExerciseTabs.about, exercise: currentSelected, addExercise: $addExercise)
        }
        .sheet(isPresented: $isFilterPresented) {
            ExerciseFilterView(
                selectedMuscles: Binding(
                    get: { selectedMuscles },
                    set: { newValue in
                        selectedMuscles = newValue
                    }
                ),
                availableMuscles: viewModel.availableMuscles,
                searchText: $searchText,
                onApply: { muscles in
                    selectedMuscles = muscles
                    viewModel.updateFilters(muscles: muscles, currentQuery: searchText)
                }
            )
            .presentationDetents([.fraction(0.5), .medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.fetchExercises() // Fetch exercises on view load
            selectedExercises = [] // Initialize with an empty array
            selectedMuscles = viewModel.selectedMuscles
        }
    }
}

#Preview {
    // Provide a binding array for previewing
    ExerciseScreen(selectedExercises: .constant([]), fromWorkout: false)
}
