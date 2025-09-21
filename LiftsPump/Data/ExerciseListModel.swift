//
//  ExerciseListModel.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 12/31/24.
//

import Foundation
extension String {
    func normalizedSearchText() -> String {
        self.lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

class ExerciseListModel: ObservableObject {
    @Published var exercises: [ExerciseTemplate] = []
    @Published var selectedExercises: [ExerciseTemplate] = []
    
    // Current filter state (selected primary muscle groups)
    @Published var selectedMuscles: Set<String> = []

    // All available primary muscles from the loaded dataset
    var availableMuscles: [String] {
        let all = exercises.flatMap { $0.primaryMuscles }
        let unique = Set(all.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        return unique.sorted()
    }
    
    func fetchExercises() {
        if !exercises.isEmpty {
            return
        }
        // Load the JSON file from the app bundle
        guard let fileURL = Bundle.main.url(forResource: "exercisesList", withExtension: "json") else {
            print("Failed to locate exercisesList.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode([ExerciseTemplate].self, from: data)
            DispatchQueue.main.async {
                self.exercises = decodedData
                self.selectedExercises = decodedData
                self.selectedMuscles = []
            }
        } catch {
            print("Error loading or decoding local JSON file: \(error)")
        }
    }
    
    func searchExercises(query: String) {
        // Normalize query and perform combined search + filter
        let q = query.normalizedSearchText()

        let base = exercises.filter { ex in
            // Filter by name match if query provided
            let matchesQuery: Bool
            if q.isEmpty { matchesQuery = true }
            else { matchesQuery = ex.name.normalizedSearchText().contains(q) }

            // Filter by selected muscles if any chosen
            let matchesMuscle: Bool
            if selectedMuscles.isEmpty { matchesMuscle = true }
            else { matchesMuscle = !Set(ex.primaryMuscles).intersection(selectedMuscles).isEmpty }

            return matchesQuery && matchesMuscle
        }
        selectedExercises = base
    }

    func updateFilters(muscles: Set<String>, currentQuery: String) {
        selectedMuscles = muscles
        searchExercises(query: currentQuery)
    }
    
    func findById(_ id: String) -> ExerciseTemplate? {
        if exercises.isEmpty {
            fetchExercises() // Ensure data is loaded
        }
        return exercises.first(where: { $0.id == id })
    }
}

