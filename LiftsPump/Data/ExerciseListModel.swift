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

    // Current filter state (selected tools)
    @Published var selectedTools: Set<String> = []

    // All available primary muscles from the loaded dataset
    var availableMuscles: [String] {
        let all = exercises.flatMap { $0.primaryMuscles }
        let unique = Set(all.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        return unique.sorted()
    }
    
    // All available tools from the loaded dataset
    // Uses .tools property if present on ExerciseTemplate; falls back to empty array if not.
    var availableTools: [String] {
        let all = exercises.compactMap { $0.equipment?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let unique = Set(all)
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
                self.selectedTools = []
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

            // Filter by selected tools if any chosen
            let exerciseTools = ex.equipment ?? ""
            let matchesTool: Bool
            if selectedTools.isEmpty { matchesTool = true }
            else { matchesTool = !Set(arrayLiteral: exerciseTools).intersection(selectedTools).isEmpty }

            return matchesQuery && matchesMuscle && matchesTool
        }
        selectedExercises = base
    }

    func updateFilters(muscles: Set<String>, tools: Set<String>, currentQuery: String) {
        selectedMuscles = muscles
        selectedTools = tools
        searchExercises(query: currentQuery)
    }
    
    func findById(_ id: String) -> ExerciseTemplate? {
        if exercises.isEmpty {
            fetchExercises() // Ensure data is loaded
        }
        return exercises.first(where: { $0.id == id })
    }
}

