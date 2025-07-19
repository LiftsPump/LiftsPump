//
//  PRData.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 1/28/25.
//

import Foundation
import SwiftData

// Wrapper struct for the tuple (Date, Int)
struct PR: Codable {
    let date: Date
    let value: Int
    let supaId: UUID

    init(date: Date, value: Int, supaId: UUID) {
        self.date = date
        self.value = value
        self.supaId = supaId
    }
}

struct PRRecord: Identifiable {
    let id = UUID()
    let date: String
    let supaId: UUID
    let weight: Int
    let verified: Bool
    let percentage: String
    var eCode: String
    let realDate: Date
}
struct PRPayload: Codable {
    let requestee_id: UUID
    let pr_id: UUID
}
struct PRRequest: Codable {
    let creator_id: UUID
    let requestee: UUID
    let id: UUID
    let pr_id: UUID
}

struct PRSupa: Codable {
    let id: UUID
    let creator_id: UUID
    let eCode: String
    let date: Date
    let value: Int
}

@Model
class PRData {
    private var PRDictionary: Data?
    
    var dictionary: [String: [PR]] {
        get {
            guard let data = PRDictionary else {
                return [:]
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return (try? decoder.decode([String: [PR]].self, from: data)) ?? [:]
        }
        set {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            PRDictionary = try? encoder.encode(newValue)
        }
    }
    
    init(dictionary: [String: [PR]]) {
        self.dictionary = dictionary
    }
}
