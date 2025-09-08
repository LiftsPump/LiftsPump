//
//  ProfileData.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/27/25.
//

import Foundation
import SwiftData

struct Profile: Codable {
    let first_name: String
    let last_name: String
    let phone_number: String
    let height: Int
    let weight: Int
    let dob: Date
    let type: Int
    var last_synced: Date?
    let username: String
    let email: String?
    let trainer: UUID?
}

struct Username: Codable {
    let username: String
}
