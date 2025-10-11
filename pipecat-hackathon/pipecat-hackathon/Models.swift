// Models.swift
// Shared models for chat and roles.

import Foundation

enum ChatRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String
    let date: Date
    
    init(id: UUID = UUID(), role: ChatRole, text: String, date: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.date = date
    }
}
