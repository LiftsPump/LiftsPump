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

Environment.load()

let supabase: SupabaseClient = {
    guard
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
        let url = URL(string: urlString),
        let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
    else {
        fatalError("Missing Supabase configuration")
    }
    return SupabaseClient(supabaseURL: url, supabaseKey: key)
}()

extension DateFormatter {
    static let dobFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static func flexible(_ formats: [String]) -> JSONDecoder.DateDecodingStrategy {
        return .custom { decoder in
            // Try to decode as String first, then as numeric epoch
            let container = try decoder.singleValueContainer()

            // Helper to attempt parsing a string with many formats
            func parseString(_ raw: String) -> Date? {
                let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if value.isEmpty { return nil }

                // ISO8601 with and without fractional seconds
                let isoFS = ISO8601DateFormatter()
                isoFS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let d = isoFS.date(from: value) { return d }

                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime]
                if let d = iso.date(from: value) { return d }

                // Common SQL-like patterns, with variable fractional precision and optional TZ offset
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(secondsFromGMT: 0)

                // Build a list of patterns to try
                var patterns: [String] = []
                // Space-separated date time
                patterns += [
                    "yyyy-MM-dd HH:mm:ss",
                    "yyyy-MM-dd HH:mm:ssXXXXX",
                ]
                // Fractional seconds 3..6 digits, with and without TZ
                for n in 3...6 {
                    let frac = String(repeating: "S", count: n)
                    patterns.append("yyyy-MM-dd HH:mm:ss.\(frac)")
                    patterns.append("yyyy-MM-dd HH:mm:ss.\(frac)XXXXX")
                    patterns.append("yyyy-MM-dd'T'HH:mm:ss.\(frac)")
                    patterns.append("yyyy-MM-dd'T'HH:mm:ss.\(frac)XXXXX")
                }
                // Bare date
                patterns.append("yyyy-MM-dd")

                for f in formats + patterns {
                    df.dateFormat = f
                    if let d = df.date(from: value) { return d }
                }

                return nil
            }

            if let s = try? container.decode(String.self), let d = parseString(s) {
                return d
            }
            if let epochMs = try? container.decode(Int.self) {
                // Heuristic: treat 13+ digit as milliseconds, else seconds
                if epochMs > 2_000_000_000 { // > ~2033 in seconds means ms
                    return Date(timeIntervalSince1970: TimeInterval(epochMs) / 1000.0)
                } else {
                    return Date(timeIntervalSince1970: TimeInterval(epochMs))
                }
            }
            if let epochD = try? container.decode(Double.self) {
                // Could be seconds or milliseconds with decimals; assume seconds if < 10^11
                if epochD > 100_000_000_000 { // clearly ms
                    return Date(timeIntervalSince1970: epochD / 1000.0)
                } else {
                    return Date(timeIntervalSince1970: epochD)
                }
            }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Date string does not match any expected format"
                )
            )
        }
    }
}

extension Routine: CustomStringConvertible {
    public var description: String {
        return """
        Routine:
          id: \(id)
          name: \(name)
          type: \(type)
          exercises: \(exercises.map { $0.name })
        """
    }
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
    @AppStorage("TRAINER_ID_KEY") private var trainerId: String = ""
    @AppStorage("TRAINER_NAME_KEY") private var trainerName: String = ""
    @AppStorage("TRAINER_VIDEOS_KEY") private var trainerVideos: String = "[]"
    private static var running: Bool = false

    private func applyProfile(_ profile: Profile) {
        firstName = profile.first_name
        lastName = profile.last_name
        email = profile.email ?? "" // Assuming phone_number is stored in EMAIL_KEY
        height = profile.height
        weight = profile.weight
        dob = profile.dob.timeIntervalSince1970
        last_synced = profile.last_synced?.timeIntervalSince1970 ?? 1
        username = profile.username
        trainerId = profile.trainer?.uuidString ?? ""
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
        defer { SupaBaseManager.running = false }
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
        decoder.dateDecodingStrategy = .flexible([
            "yyyy-MM-dd HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd"
        ])

        var routines = try decoder.decode([Routine].self, from: responseR.data)
        var exercises = try decoder.decode([Exercise].self, from: responseE.data)
        var sets = try decoder.decode([ESet].self, from: responseS.data)
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

        if let trainerUUID = profile.trainer {
            do {
                let responseT = try await supabase
                    .from("trainer")
                    .select("*")
                    .eq("trainer_id", value: trainerUUID)
                    .execute()
                let trainers = try JSONDecoder().decode([Trainer].self, from: responseT.data)
                if let trainer = trainers.first {
                    if let vids = trainer.videos,
                       let data = try? JSONEncoder().encode(vids),
                       let json = String(data: data, encoding: .utf8) {
                        trainerVideos = json
                    } else {
                        trainerVideos = "[]"
                    }
                }
            } catch {
                print("Error fetching trainer: \(error)")
            }
        } else {
            trainerName = ""
            trainerVideos = "[]"
        }

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


        // Mirror cloud deletions locally (except .ai routines) and reset PRData
        do {
            // Build cloud ID sets
            let cloudRoutineIDs = Set(routines.filter { $0.type != .ai }.map { $0.id })
            // Delete local routines that no longer exist in cloud (excluding .ai)
            let localRoutines = try modelContext.fetch(FetchDescriptor<Routine>())
            for r in localRoutines where r.type != .ai && !cloudRoutineIDs.contains(r.id) {
                modelContext.delete(r)
            }
            // Reset PRData to avoid duplicates; a fresh PRData will be inserted below
            let existingPRs = try modelContext.fetch(FetchDescriptor<PRData>())
            for p in existingPRs { modelContext.delete(p) }
        } catch {
            print("Error reconciling local deletions: \(error)")
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
                let newPR = PR(date: prsup.date, value: prsup.value, supaId: prsup.id, confirmations: prsup.confirmations ?? [])
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
                let prSupa = PRSupa(id: UUID(), creator_id: userId, eCode: eCode, date: prdata.date, value: prdata.value, confirmations: prdata.confirmations)
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
                print("Error deleting data: \(error)")
            }
        }
    }
    static func deleteExercise(exercise: Exercise) {
        Task {
            do {
                try await supabase
                    .from("exercises")
                    .delete()
                    .eq("id", value: exercise.id)
                    .execute()
                print(exercise.id)
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }
    static func deleteSet(set: ESet) {
        Task {
            do {
                try await supabase
                    .from("sets")
                    .delete()
                    .eq("id", value: set.id)
                    .execute()
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }
    static func addExercise(exercise: Exercise) {
        Task {
            do {
                try await supabase
                    .from("exercises")
                    .insert(exercise)
                    .execute()
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func addSet(set: ESet) {
        Task {
            do {
                try await supabase
                    .from("sets")
                    .insert(set)
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
    static func usernameCreate(username: String) async throws {
        let payload = Username(username: username)
        let options = FunctionInvokeOptions(body: payload)
        try await supabase.functions
            .invoke(
                "set-username",
                options: options
            )
    }
    static func prAcceptOrDeny(requestee_id: UUID, pr_id: UUID, action: String) {
        Task {
            do {
                let payload = PRConfirm(requestee_id: requestee_id, pr_id: pr_id, action: action)
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
    static func saveProfile(first_name: String = "", last_name: String = "", phone_number: String = "", height: Int = 0, weight: Int = 0, dob: Date = Date(), type: Int = 0, last_synced: Date = Date(), username: String = "", email: String = "", trainer: UUID? = nil) {
        Task {
            do {
                let profileData = Profile(first_name: first_name, last_name: last_name, phone_number: phone_number, height: height, weight: weight, dob: dob, type: type, last_synced: last_synced, username: username, email: email, trainer: trainer)
                try await supabase
                    .from("profile")
                    .upsert(profileData)
                    .execute()
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    static func checkPR(pr_id: UUID) async throws -> [PRSupa] {
        do {
            let responsePR = try await supabase
                .from("prdata")
                .select("*")
                .eq("id", value: pr_id)
                .execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .flexible([
                "yyyy-MM-dd",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd HH:mm:ss"
            ])
            let prs = try decoder.decode([PRSupa].self, from: responsePR.data)
            return prs
        } catch {
            print("Can't yield PR from id: \(error)")
            return []
        }
    }
    static func updateRoutine(routine: Routine, id: UUID) {
        Task {
            do {
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
                        .update(exercise)
                        .eq("id", value: exercise.id)
                        .execute()
                    print("Exercise updated successfully!")
                    for set in exercise.sets {
                        set.exercise_id = exercise.id
                        try await supabase
                            .from("sets")
                            .update(set)
                            .eq("id", value: set.id)
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
