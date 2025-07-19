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

extension DateFormatter {
    static let dobFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

public class SupaBaseManager {
    @AppStorage("FIRSTNAME_KEY") private var firstName: String = ""
    @AppStorage("LASTNAME_KEY") private var lastName: String = ""
    @AppStorage("EMAIL_KEY") private var email: String = ""
    @AppStorage("HEIGHT_KEY") private var height: Int = 0
    @AppStorage("WEIGHT_KEY") private var weight: Int = 0
    @AppStorage("DOB_KEY") private var dob: Double = Date().timeIntervalSince1970
    @AppStorage("LS_KEY") private var last_synced: Double = Date().timeIntervalSince1970
    @AppStorage("USERNAME_KEY") var username: String = ""
    private static var running: Bool = false

    private func applyProfile(_ profile: Profile) {
        firstName = profile.first_name
        lastName = profile.last_name
        email = profile.email // Assuming phone_number is stored in EMAIL_KEY
        height = profile.height
        weight = profile.weight
        dob = profile.dob.timeIntervalSince1970
        last_synced = profile.last_synced?.timeIntervalSince1970 ?? 1
        username = profile.username
    }
    private var modelContext: ModelContext

    public init(context: ModelContext) {
        self.modelContext = context
    }

    @MainActor public func initSync() async throws {
        if SupaBaseManager.running {
            return
        }
        SupaBaseManager.running = true
        let responseR = try await supabase.from("routines").select("*").execute()
        let responseE = try await supabase.from("exercises").select("*").execute()
        let responseS = try await supabase.from("sets").select("*").execute()
        let responseP = try await supabase.from("prdata").select("*").execute()
        let responseProfile = try await supabase
            .from("profile")
            .select("*")
            .eq("creator_id", value: supabase.auth.currentUser?.id ?? "")
            .execute()
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)

        var routines = try decoder.decode([Routine].self, from: responseR.data)
        var exercises = try decoder.decode([Exercise].self, from: responseE.data)
        var sets = try decoder.decode([ESet].self, from: responseS.data)
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let prs = try decoder.decode([PRSupa].self, from: responseP.data)
        let profiles = try decoder.decode([Profile].self, from: responseProfile.data)
        guard var profile = profiles.first else {
            print("No profile found in Supabase.")
            SupaBaseManager.running = false
            return
        }
        let synced = profile.last_synced ?? Date(timeIntervalSince1970: 1)
        do {
            if (Date().timeIntervalSince1970-synced.timeIntervalSince1970) > 86400 {
                print("Yurrp")
                let currentRoutines = try modelContext.fetch(FetchDescriptor<Routine>())
                let options = FunctionInvokeOptions(body: profile)
                let airesponse: Response = try await supabase.functions
                    .invoke(
                        "AiRoutines",
                        options: options
                    )
                for routine in currentRoutines {
                    if routine.type == .ai {
                        modelContext.delete(routine)
                    }
                }
                var rawValue = (airesponse.message)
                rawValue = rawValue
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let aiDecoded = try JSONDecoder().decode([Routine].self, from: rawValue.data(using: .utf8) ?? Data())
                for routine in aiDecoded {
                    routine.type = .ai
                    routines.append(routine)
                    for exercise in routine.exercises {
                        exercise.routine_id = routine.id
                        exercises.append(exercise)
                        for set in exercise.sets {
                            set.exercise_id = exercise.id
                            sets.append(set)
                        }
                    }
                }
            }
            profile.last_synced = Date()
            SupaBaseManager.saveProfile(first_name: firstName, last_name: lastName, phone_number: "", height: height, weight: weight, dob: Date(timeIntervalSince1970: dob), type: 1, last_synced: Date(), username: username)
        } catch {
            print("Error with AI \(error)")
            SupaBaseManager.running = false
        }
        applyProfile(profile)

        // Merge data
        for routine in routines {
            if routine.type == .ai { continue }
            for exercise in exercises {
                if exercise.routine_id == routine.id {
                    let copyE = exercise.copy()
                    copyE.routine = routine

                    for set in sets {
                        if set.exercise_id == exercise.id {
                            let copy = set.copy()
                            copy.exercise = copyE  // should be copyE, not exercise
                            copyE.sets.append(copy)
                        }
                    }

                    routine.exercises.append(copyE)  // append only once
                }
            }
        }


        // Clear old data
        let currentRoutines = try modelContext.fetch(FetchDescriptor<Routine>())
        let currentPRData = try modelContext.fetch(FetchDescriptor<PRData>())
        for routine in currentRoutines {
            if routine.type != .ai {
                modelContext.delete(routine)
            }
        }
        for PRData in currentPRData {
            modelContext.delete(PRData)
        }

        // Save new routines
        for routine in routines {
            modelContext.insert(routine)
        }
        let prd: PRData = PRData(dictionary: [:])
        guard let userId = supabase.auth.currentUser?.id else {
            print("User not logged in!")
            SupaBaseManager.running = false
            return
        }
        for prsup in prs {
            if prsup.creator_id == userId {
                var exercisePRs = prd.dictionary[prsup.eCode] ?? []
                let newPR = PR(date: prsup.date, value: prsup.value, supaId: prsup.id)
                exercisePRs.append(newPR)
                prd.dictionary[prsup.eCode] = exercisePRs
            }
        }
        modelContext.insert(prd)
        try modelContext.save()
        SupaBaseManager.running = false
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
                guard let userId = supabase.auth.currentUser?.id else {
                    print("User not logged in!")
                    return
                }
                let prSupa = PRSupa(id: UUID(), creator_id: userId, eCode: eCode, date: prdata.date, value: prdata.value)
                try await supabase
                    .from("prdata")
                    .insert(prSupa)
                    .execute()
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func deleteRoutine(routine: Routine) {
        Task {
            do {
                try await supabase
                    .from("routines")
                    .delete()
                    .eq("id", value: routine.id)
                    .execute()
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func prConfirmsSend(requestee_id: UUID, pr_id: UUID) {
        Task {
            do {
                let payload = PRPayload(requestee_id: requestee_id, pr_id: pr_id)
                let options = FunctionInvokeOptions(body: payload)
                try await supabase.functions
                    .invoke(
                      "prconfirm",
                      options: options
                    )
            } catch {
                print("Error sending request: \(error)")
            }
        }
    }
    static func saveProfile(first_name: String = "", last_name: String = "", phone_number: String = "", height: Int = 0, weight: Int = 0, dob: Date = Date(), type: Int = 0, last_synced: Date = Date(), username: String = "", email: String = "") {
        Task {
            do {
                let profileData = Profile(first_name: first_name, last_name: last_name, phone_number: phone_number, height: height, weight: weight, dob: dob, type: type, last_synced: last_synced, username: username, email: email)
                try await supabase
                    .from("profile")
                    .upsert(profileData)
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
