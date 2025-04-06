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
}
