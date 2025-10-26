//
//  ExerciseData.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 11/28/24.
//

import Foundation
import SwiftData

// RoutineType Enum to Differentiate Routine Types
enum RoutineType: String, Codable {
    case preset
    case date
    case custom
    case ai
    case assigned
    case trainer
}
class Response: Decodable {
    var message: String
    var status: String
}
@Model
class Routine: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    enum CodingKeys: CodingKey {
        case id, name, picture, text, exercises, type, days, weekly, date, duration
    }
    var name: String
    var picture: String?
    var text: String?
    
    // Relationships
    var exercises: [Exercise] = []
    
    // Routine-specific properties
    @Attribute var type: RoutineType
    var days: Int? // Only for preset routines
    var weekly: Int? // Only for preset routines
    var date: Date? // Only for date routines
    var duration: TimeInterval? // Only for date routines

    init(id: UUID,
         name: String,
         picture: String? = nil,
         text: String? = nil,
         exercises: [Exercise] = [],
         type: RoutineType,
         days: Int? = nil,
         weekly: Int? = nil,
         date: Date? = nil,
         duration: TimeInterval? = nil) {
        self.id = id
        self.name = name
        self.picture = picture
        self.text = text
        self.exercises = exercises
        self.type = type
        self.days = days
        self.weekly = weekly
        self.date = date
        self.duration = duration
    }

    // Copy method
    func copy() -> Routine {
        let copiedExercises = self.exercises.map { $0.copy() }
        return Routine(
            id: self.id,
            name: self.name,
            picture: self.picture,
            text: self.text,
            exercises: copiedExercises,
            type: self.type,
            days: self.days,
            weekly: self.weekly,
            date: self.date,
            duration: self.duration
        )
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        type = try container.decodeIfPresent(RoutineType.self, forKey: .type) ?? .ai
        days = try container.decodeIfPresent(Int.self, forKey: .days)
        weekly = try container.decodeIfPresent(Int.self, forKey: .weekly)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises) ?? []
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(picture, forKey: .picture)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(days, forKey: .days)
        try container.encodeIfPresent(weekly, forKey: .weekly)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(duration, forKey: .duration)
        //try container.encode(exercises, forKey: .exercises)
    }
}

@Model
class Exercise: Identifiable, Codable {
    enum CodingKeys: CodingKey {
        case id, name, eCode, text, sets, routine_id, agent_routine_id, order
    }
    @Attribute(.unique) var id: UUID
    var name: String
    var eCode: String
    var text: String?
    var order: Int?
    
    // Relationships
    @Relationship(inverse: \Routine.exercises)
    var routine: Routine?
    var sets: [ESet] = []
    var routine_id: UUID?
    var agent_routine_id: UUID?

    init(id: UUID, name: String,
         eCode: String = "",
         text: String? = nil,
         routine: Routine? = nil,
         routine_id: UUID? = nil,
         agent_routine_id: UUID? = nil,
         sets: [ESet] = [],
         order: Int = 0) {
        self.id = id
        self.name = name
        self.eCode = eCode
        self.text = text
        self.routine = routine
        self.routine_id = routine_id
        self.agent_routine_id = agent_routine_id
        self.sets = sets
        self.order = order
    }

    // Copy method
    func copy() -> Exercise {
        let copiedSets = self.sets.map { $0.copy() }
        return Exercise(
            id: self.id,
            name: self.name,
            eCode: self.eCode,
            text: self.text,
            routine: nil, // Do not copy the routine to avoid circular references
            routine_id: routine_id,
            agent_routine_id: agent_routine_id,
            sets: copiedSets,
            order: order ?? 0
        )
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        eCode = try container.decode(String.self, forKey: .eCode)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        sets = try container.decodeIfPresent([ESet].self, forKey: .sets) ?? []
        routine_id = try container.decodeIfPresent(UUID.self, forKey: .routine_id)
        agent_routine_id = try container.decodeIfPresent(UUID.self, forKey: .agent_routine_id)
        order = try container.decodeIfPresent(Int.self, forKey: .order)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(eCode, forKey: .eCode)
        try container.encodeIfPresent(text, forKey: .text)
        //try container.encode(sets, forKey: .sets)
        try container.encodeIfPresent(routine_id, forKey: .routine_id)
        try container.encodeIfPresent(agent_routine_id, forKey: .agent_routine_id)
        try container.encodeIfPresent(order, forKey: .order)
    }
}

@Model
class ESet: Identifiable, Codable {
    enum CodingKeys: CodingKey {
        case id, weight, reps, pr, completed, exercise_id, order
    }
    @Attribute(.unique) var id: UUID
    var weight: Int?
    var reps: Int?
    var pr: Bool = false
    var completed: Bool = false
    var exercise_id: UUID?
    var order: Int?
    
    // Relationships
    @Relationship(inverse: \Exercise.sets)
    var exercise: Exercise?

    init(id: UUID,
         weight: Int? = nil,
         reps: Int? = nil,
         pr: Bool = false,
         completed: Bool = false,
         exercise_id: UUID? = nil,
         exercise: Exercise? = nil,
         order: Int? = nil) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.pr = pr
        self.completed = completed
        self.exercise = exercise
        self.exercise_id = exercise_id
        self.order = order
    }

    // Copy method
    func copy() -> ESet {
        return ESet(
            id: self.id,
            weight: self.weight,
            reps: self.reps,
            pr: self.pr,
            completed: self.completed,
            exercise_id: exercise_id,
            exercise: nil,
            order: self.order
        )
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        pr = try container.decode(Bool.self, forKey: .pr)
        completed = try container.decode(Bool.self, forKey: .completed)
        exercise_id = try container.decodeIfPresent(UUID.self, forKey: .exercise_id)
        order = try container.decodeIfPresent(Int.self, forKey: .order)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(reps, forKey: .reps)
        try container.encode(pr, forKey: .pr)
        try container.encode(completed, forKey: .completed)
        try container.encodeIfPresent(exercise_id, forKey: .exercise_id)
        try container.encodeIfPresent(order, forKey: .order)
    }
}

