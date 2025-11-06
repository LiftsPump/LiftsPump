//
//  WeightManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 11/5/25.
//

import Foundation
import Supabase
import SwiftData
import SwiftUI

struct WeightLog: Codable, Identifiable {
    let id = UUID()
    let created_at: Date?
    let weight_kg: Double
    let source: String
    let bf_percent: Double? // percent, optional

    private enum CodingKeys: String, CodingKey {
        case created_at
        case weight_kg
        case source
        case bf_percent
    }
}

public class WeightManager {
    static func logWeight(weightLog: WeightLog) async throws {
        try await supabase
            .from("weight_entry")
            .insert(weightLog)
            .execute()
    }
    static func getWeightLogs() async throws -> [WeightLog] {
        let data = try await supabase
            .from("weight_entry")
            .select("*")
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let weights = try decoder.decode([WeightLog].self, from: data.data)
        return weights
    }
}
