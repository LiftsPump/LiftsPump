//
//  DataMethods.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 1/23/25.
//

import Foundation
import SwiftData

public class DataMethods {
    static func summarizer(routine: Routine) -> String {
        var summary: String = ""
        for i in 0..<routine.exercises.count {
            summary += "\(i+1). \(routine.exercises[i].name)"
            summary += " X \(routine.exercises[i].sets.count) "
            summary += "\n"
        }
        if summary == "" {
            return "No data on this routine"
        }
        return summary
    }
    static func getPRsConfirmed(modelContext: ModelContext) -> Int {
        let prManager = PRManager(context: modelContext)
        let response = prManager.getPRDataFormatted()
        var count = 0
        for (_, records) in response {
            if let (_, _, _, confirmations) = records.max(by: { $0.1 < $1.1 }), confirmations.count > 0 {
                count += 1
            }
        }
        return count
    }
    static func completedRoutines(routines: [Routine]) -> Int {
        var count = 0
        for routine in routines {
            if routine.type == .date {
                count += 1
            }
        }
        return count
    }
    static func userStreak(routines: [Routine]) -> Int {
        guard !routines.isEmpty else { return 0 }

        // Sort routines by date in descending order
        let sortedRoutines = routines.filter { $0.type == .date }.sorted { $0.date ?? Date() > $1.date ?? Date()}
        
        var streak = 0
        var previousDate: Date? = nil
        let calendar = Calendar.current
        
        for routine in sortedRoutines {
            if let routineDate = routine.date {
                if routineDate > Date() {
                    continue
                }
                if previousDate == nil {
                    streak += 1
                } else if let daysDifference = calendar.dateComponents([.day], from: routineDate, to: previousDate!).day, daysDifference == 1 {
                    streak += 1
                } else if let daysDifference = calendar.dateComponents([.day], from: routineDate, to: previousDate!).day, daysDifference > 1 {
                    streak = 0
                    break
                }
                previousDate = routineDate
            }
        }
        
        return streak
    }
}
