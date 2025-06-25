//
//  File.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 6/23/25.
//

import Foundation
import SwiftData

public struct Friend: Codable {
    let creator_id: UUID
    let first_name: String
    let last_name: String
    let username: String
}
public struct FriendRequest: Codable {
    let requestee: UUID
    let status: Int
    let creator_id: UUID
    let date: Date
}
public struct FriendsPayload: Codable {
    let creatorId: UUID
    let requesteeId: UUID
    let action: String
}
