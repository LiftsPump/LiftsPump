import SwiftUI
import SwiftData

// Cache once
extension DateFormatter {
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = .current
        return f
    }()
}

struct CompletedScreen: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Query var routines: [Routine] = []
    @State private var showAccessory = false
    @Environment(\.modelContext) var modelContext

    // Pre-group + pre-sort so the body stays dumb
    var groupedRoutines: [(key: String, value: [Routine])] {
        let grouped = Dictionary(grouping: routines) { routine in
            routine.date.map { DateFormatter.monthYear.string(from: $0) } ?? "No Date"
        }

        return grouped
            // sort items in each month: newest → oldest
            .map { (key: $0.key,
                    value: $0.value.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }) }
            // sort months: newest → oldest
            .sorted {
                let d1 = DateFormatter.monthYear.date(from: $0.key) ?? .distantPast
                let d2 = DateFormatter.monthYear.date(from: $1.key) ?? .distantPast
                return d1 > d2
            }
    }

    var body: some View {
        ScrollView {
            ForEach(groupedRoutines, id: \.key) { section in
                Section {
                    ForEach(section.value) { routine in
                        if routine.type == .date || routine.type == .assigned {
                            NavigationLink {
                                WorkoutCompleted(
                                    externalRoutine: Binding(
                                        get: { routine },
                                        set: { updated in modelContext.insert(updated) }
                                    ),
                                    plusButton: false
                                )
                                .navigationBarBackButtonHidden(true)
                            } label: {
                                ZStack {
                                    WorkoutHistory(
                                        title: routine.name,
                                        image: "figure.run",
                                        date: routine.date?
                                            .formatted(.dateTime.year().month(.abbreviated).day())
                                            ?? "No Date Available",
                                        type: routine.type
                                    )
                                    .padding(.vertical)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(section.key)
                            .font(Theme.Fonts.SubHeading4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
        .background(Theme.Colors.NeutralDark)
        .syncOnScroll()
    }
}

#Preview { CompletedScreen() }
