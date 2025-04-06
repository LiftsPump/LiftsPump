//
//  ExerciseType.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 12/31/24.
//

import Foundation

struct ExerciseTemplate: Identifiable, Codable {
    var id: String
    var name: String
    var force: String?
    var level: String?
    var mechanic: String?
    var equipment: String?
    var primaryMuscles: [String]
    var secondaryMuscles: [String]?
    var instructions: [String]?
    var category: String?
    var images: [String]
}
