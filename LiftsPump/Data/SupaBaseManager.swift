//
//  SupaBaseManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 2/2/25.
//

import Foundation
import Supabase
import SwiftData
import SwiftUI

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://dupuztvhoifyczvqyjbk.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1cHV6dHZob2lmeWN6dnF5amJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1MzM2OTYsImV4cCI6MjA1NDEwOTY5Nn0.eXwBsJA33-aPiz_I1Q4sQEX2Z7yxMg0Q7ERMuT-BRtQ"
)

public class SupaBaseManager {
    private var modelContext: ModelContext

    public init(context: ModelContext) {
        self.modelContext = context
    }

    @MainActor public func initSync() async throws {
        let responseR = try await supabase.from("routines").select("*").execute()
        let responseE = try await supabase.from("exercises").select("*").execute()
        let responseS = try await supabase.from("sets").select("*").execute()
        let responseP = try await supabase.from("prdata").select("*").execute()

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)

        let routines = try decoder.decode([Routine].self, from: responseR.data)
        let exercises = try decoder.decode([Exercise].self, from: responseE.data)
        let sets = try decoder.decode([ESet].self, from: responseS.data)
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let prs = try decoder.decode([PRSupa].self, from: responseP.data)

        // Merge data
        for routine in routines {
            for exercise in exercises {
                if exercise.routine_id == routine.id {
                    exercise.routine = routine
                    for set in sets {
                        if set.exercise_id == exercise.id {
                            set.exercise = exercise
                            exercise.sets.append(set)
                        }
                    }
                    routine.exercises.append(exercise)
                }
            }
        }

        // Clear old data
        let currentRoutines = try modelContext.fetch(FetchDescriptor<Routine>())
        let currentPRData = try modelContext.fetch(FetchDescriptor<PRData>())
        for routine in currentRoutines {
            modelContext.delete(routine)
        }
        for PRData in currentPRData {
            modelContext.delete(PRData)
        }

        // Save new routines
        for routine in routines {
            modelContext.insert(routine)
        }
        let prd: PRData = PRData(dictionary: [:])
        for prsup in prs {
            var exercisePRs = prd.dictionary[prsup.eCode] ?? []
            let newPR = PR(date: prsup.date, value: prsup.value)
            exercisePRs.append(newPR)
            prd.dictionary[prsup.eCode] = exercisePRs
        }
        print(prd.dictionary)
                
        modelContext.insert(prd)
        try modelContext.save()
    }
    static func saveRoutine(routine: Routine) {
        Task {
            do {
                try await supabase
                    .from("routines")
                    .insert(routine)
                    .execute()
                print("Routine inserted successfully!")
                for exercise in routine.exercises {
                    exercise.routine_id = routine.id
                    try await supabase
                        .from("exercises")
                        .insert(exercise)
                        .execute()
                    print("Exercise inserted successfully!")
                    for set in exercise.sets {
                        set.exercise_id = exercise.id
                        try await supabase
                            .from("sets")
                            .insert(set)
                            .execute()
                        print("Set inserted successfully!")
                    }
                }
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func savePR(eCode: String, prdata: PR) {
        Task {
            do {
                let prSupa = PRSupa(eCode: eCode, date: prdata.date, value: prdata.value)
                try await supabase
                    .from("prdata")
                    .insert(prSupa)
                    .execute()
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func updateRoutine(routine: Routine, id: UUID) {
        Task {
            do {
                print(id)
                if let currentUser = supabase.auth.currentUser {
                    print("Supabase User ID: \(currentUser.id)")
                } else {
                    print("No user is currently logged in.")
                }
                try await supabase
                    .from("routines")
                    .update(routine)
                    .eq("id", value: id)
                    .execute()
                print("Routine updated successfully!")
                for exercise in routine.exercises {
                    exercise.routine_id = routine.id
                    try await supabase
                        .from("exercises")
                        .upsert(exercise)
                        .execute()
                    print("Exercise updated successfully!")
                    for set in exercise.sets {
                        set.exercise_id = exercise.id
                        try await supabase
                            .from("sets")
                            .upsert(set)
                            .execute()
                        print("Set updated successfully!")
                    }
                }
            } catch {
                print("Error updating data: \(error)")
            }
        }
    }
}
