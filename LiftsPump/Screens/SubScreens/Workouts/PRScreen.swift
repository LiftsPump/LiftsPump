import SwiftUI

struct PRScreen: View {
    @State private var showAccessory = false
    @State private var prHistory: [PRRecord] = [] // PR Data
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ExerciseListModel() // Exercise Data
    @State private var sortByName = true // Toggle between sorting modes
    @State private var isPresented: Bool = false
    @State private var currentSelected: ExerciseTemplate?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(sortByName ? "View by date" : "View by name")
                    .padding(.trailing)
                    .padding(.top, 8)
                    .font(Theme.Fonts.SubHeading5)
                    .onTapGesture {
                        withAnimation {
                            sortByName.toggle()
                        }
                    }
            }
            .sensoryFeedback(.selection, trigger: showAccessory)

            ScrollView {
                HStack {
                    Text("Your PRs (\(sortByName ? "by exercise name" : "by month"))")
                        .font(Theme.Fonts.SubHeading8)
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                    Spacer()
                }
                
                VStack {
                    if sortByName {
                        groupedByExerciseView()
                    } else {
                        groupedByMonthView()
                    }
                }
            }
            .sheet(item: $currentSelected) { exercise in
                ExerciseDetails(defaultTab: ExerciseTabs.prs, exercise: exercise, addExercise: .constant(false))
            }
        }
        .animation(.snappy(duration: 0.2), value: sortByName)
        .onAppear {
            fetchPRHistory()
        }
    }

    private func groupedByExerciseView() -> some View {
        let grouped = Dictionary(grouping: prHistory) { record in
            viewModel.findById(record.eCode)?.name.prefix(1).uppercased() ?? "#"
        }
        let sortedKeys = grouped.keys.sorted()

        return VStack {
            ForEach(sortedKeys, id: \.self) { letter in
                LetterSeperator(letter: letter) // Section Header
                ForEach(grouped[letter] ?? [], id: \.eCode) { record in
                    if let exercise = viewModel.findById(record.eCode) {
                        PRCard(exercise: .constant(exercise), PRRecord: .constant(record), selected: false)
                            .onTapGesture {
                                currentSelected = exercise
                            }
                    }
                }
            }
        }
    }

    private func groupedByMonthView() -> some View {
        let grouped = Dictionary(grouping: prHistory) { record in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            return dateFormatter.string(from: record.realDate) // Convert String date to Date
        }
        let sortedKeys = grouped.keys.sorted { $0 > $1 } // Sort by latest month first
        for key in sortedKeys {
            print("\(key): \(grouped[key] ?? [])")
        }

        return VStack {
            ForEach(sortedKeys, id: \.self) { month in
                LetterSeperator(letter: month) // Section Header
                ForEach(grouped[month] ?? [], id: \.eCode) { record in
                    if let exercise = viewModel.findById(record.eCode) {
                        PRCard(exercise: .constant(exercise), PRRecord: .constant(record), selected: false)
                            .onTapGesture {
                                currentSelected = exercise
                            }
                    }
                }
            }
        }
    }

    /// Fetch PR History and store only the top record per exercise
    private func fetchPRHistory() {
        let prManager = PRManager(context: modelContext)
        let response = prManager.getPRDataFormatted() // [String: [Date: Int]]

        prHistory = response.compactMap { (exerciseId, records) in
            guard let (maxDate, maxWeight, supaId, confirmations) = records.max(by: { $0.1 < $1.1 }) else {
                return nil
            }

            return PRRecord(
                date: maxDate.formatted(.dateTime.year().month(.abbreviated).day()),
                supaId: supaId,
                weight: maxWeight,
                verified: false,
                percentage: String(Int.random(in: 0...100)),
                eCode: exerciseId,
                realDate: maxDate
            )
        }
    }
}

#Preview {
    PRScreen()
}
