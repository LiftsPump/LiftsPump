//
//  SupaBaseManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 2/2/25.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://dupuztvhoifyczvqyjbk.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1cHV6dHZob2lmeWN6dnF5amJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1MzM2OTYsImV4cCI6MjA1NDEwOTY5Nn0.eXwBsJA33-aPiz_I1Q4sQEX2Z7yxMg0Q7ERMuT-BRtQ"
)
        
public class SupaBaseManager {
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
