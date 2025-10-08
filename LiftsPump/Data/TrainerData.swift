//
//  TrainerData.swift
//  LiftsPump
//
//  Created by OpenAI Assistant on 2025-??-??.
//
import Foundation

struct Trainer: Codable {
    let trainer_id: UUID
    let display_name: String?
    let videos: [String]?
}

struct TrainerSession: Decodable, Identifiable {
    let id: UUID
    let trainer: UUID
    let user_id: UUID
    let user_email: String?
    let title: String?
    let start_at: Date
    let end_at: Date?
    let meet_url: String?
    let created_at: Date?
}

struct CustomExerciseRow: Decodable, Identifiable {
    let id: UUID
    let trainer: UUID
    let name: String
    let category: String?
    let equipment: String?
    let primary_muscles: [String]?
    let secondary_muscles: [String]?
    let instructions: [String]?
    let images: [String]?
    let created_at: Date?
    let updated_at: Date?
    let ecode: String
}

struct TierRow: Decodable, Identifiable {
    let id: UUID
    let trainer: UUID
    let price: Int?
    let key: String?
    let name: String
    let active: Bool?
    let stripe_price_id: String?
}
