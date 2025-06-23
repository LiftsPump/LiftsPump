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
            }
        } catch {
            print("Error loading or decoding local JSON file: \(error)")
        }
    }
    
    func searchExercises(query: String) {
        if query.isEmpty {
            selectedExercises = exercises
        } else {
            selectedExercises = exercises.filter {
                $0.name.normalizedSearchText().contains(query.normalizedSearchText())
            }
        }
    }
    func findById(_ id: String) -> ExerciseTemplate? {
        if exercises.isEmpty {
            fetchExercises() // Ensure data is loaded
        }
        return exercises.first(where: { $0.id == id })
    }
}
