//
//  PRManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 1/28/25.
//

import Foundation
import SwiftData

public class PRManager {
    private var prData: PRData
    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        self.prData = PRManager.getPRData(context: context)
    }
    static func getPRData(context: ModelContext) -> PRData {
        if let existingPRData = try? context.fetch(FetchDescriptor<PRData>()).first {
            return existingPRData
        } else {
            let newPRData = PRData(dictionary: [:])
            try? context.insert(newPRData)
            try? context.save()
            return newPRData
        }
    }
    func getPRHistory(for exerciseCode: String) -> [(date: Date, weight: Int)] {
        guard let exercisePRs = prData.dictionary[exerciseCode] else {
            return []
        }
        return exercisePRs.map { ($0.date, $0.value) }
    }
    func getPRDataFormatted() -> [String: [Date: Int]] {
        var formattedData: [String: [Date: Int]] = [:]

        for (exerciseId, prEntries) in prData.dictionary {
            formattedData[exerciseId] = Dictionary(uniqueKeysWithValues: prEntries.map { ($0.date, $0.value) })
        }

        return formattedData
    }

    func checkForPRs(routine: Routine) {
        for exercise in routine.exercises {
            guard !exercise.sets.isEmpty else { continue }
            if let maxSet = exercise.sets.filter({ $0.completed && $0.weight != nil }).max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }) {
                let exerciseName = exercise.eCode
                let newWeight = maxSet.weight ?? 0
                let currentDate = Date()
                var exercisePRs = prData.dictionary[exerciseName] ?? []
                if let latestPR = exercisePRs.last {
                    if newWeight > latestPR.value {
                        let newPR = PR(date: currentDate, value: newWeight)
                        SupaBaseManager.savePR(eCode: exerciseName, prdata: newPR)
                        exercisePRs.append(newPR)
                        prData.dictionary[exerciseName] = exercisePRs
                        maxSet.pr = true
                    }
                } else {
                    let newPR = PR(date: currentDate, value: newWeight)
                    SupaBaseManager.savePR(eCode: exerciseName, prdata: newPR)
                    exercisePRs.append(newPR)
                    prData.dictionary[exerciseName] = exercisePRs
                    maxSet.pr = true
                }
                do {
                    try context.save()
                } catch {
                    print("Error saving PR data: \(error)")
                }
            }
        }
    }
}
