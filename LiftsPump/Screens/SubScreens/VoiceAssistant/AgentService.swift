//
//  AgentService.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 10/25/25.
//

import Foundation
import Realtime
import Auth

// MARK: - Database models

/// Session status has only two states in our schema
enum SessionStatus: String, Equatable, Sendable, Codable {
    case active
    case completed

    init(_ raw: String) {
        switch raw.lowercased() {
        case "active": self = .active
        case "completed": self = .completed
        default:
            self = .active
        }
    }
}

/// Row model for public.agent_session
struct AgentSessionRow: Codable {
    let id: UUID
    let creator_id: UUID?
    let start: Date?
    let end: Date?
    let status: SessionStatus
}

/// Row model for public.agent_routine
struct AgentRoutineRow: Codable {
    let id: UUID
    let agent_session_id: UUID
    let creator_id: UUID?
    let name: String?
    let date: Date?
    let duration: Int64?
}

// MARK: - Supabase timestamp decoding

extension JSONDecoder.DateDecodingStrategy {
    /// Parses Supabase/Postgres timestamptz strings like
    /// "2025-10-26T05:56:44.740814" (microseconds) and common ISO8601 fallbacks.
    static var supabaseTS: JSONDecoder.DateDecodingStrategy {
        .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            // microseconds, no "Z"
            if let d = DateFormatter.supabaseMicroseconds.date(from: raw) {
                return d
            }
            // standard ISO8601 with or without timezone suffix
            if let d = DateFormatter.supabaseISO.date(from: raw) {
                return d
            }
            // numeric epoch seconds fallback
            if let seconds = Double(raw) {
                return Date(timeIntervalSince1970: seconds)
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format \(raw)"
            )
        }
    }
}

extension DateFormatter {
    /// "2025-10-26T05:56:44.740814"
    static let supabaseMicroseconds: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return df
    }()

    /// "2025-10-26T05:56:44.740Z", "2025-10-26T05:56:44Z", etc.
    static let supabaseISO: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return df
    }()
}

@MainActor
final class AgentService: ObservableObject {
    @Published var AgentRoutine: Routine = Routine(id: UUID(), name: "", type: .agent)
    @Published var agentCompleted: Bool = false
    
    private var currentSessionId: UUID?
    private var realtimeChannel: RealtimeChannelV2?
    @Published private(set) var isRunning: Bool = false
    
    func startAgent() async throws {
        // Prevent multiple subscriptions if already running
        guard !isRunning else {
            print("AgentService already running; ignoring startAgent call.")
            return
        }
        isRunning = true
        
        // Create a unique channel name to avoid conflicts
        let channel = supabase.realtimeV2.channel("realtime:public")
        self.realtimeChannel = channel
        self.AgentRoutine = Routine(id: UUID(), name: "", type: .ai)
        
        // Set up all listeners BEFORE subscribing
        
        // Listen for agent_session inserts
        let sessionStream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "agent_session"
        )
        
        // Listen for agent_routine inserts
        let routineStream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "agent_routine"
        )
        
        // Listen for exercises inserts
        let exerciseStream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "exercises"
        )
        
        // Listen for sets inserts
        let setStream = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "sets"
        )
        
        // Update and delete listeners for routine, exercises, and sets
        let routineUpdateStream = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "agent_routine"
        )
        let routineDeleteStream = channel.postgresChange(
            DeleteAction.self,
            schema: "public",
            table: "agent_routine"
        )

        let exerciseUpdateStream = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "exercises"
        )
        let exerciseDeleteStream = channel.postgresChange(
            DeleteAction.self,
            schema: "public",
            table: "exercises"
        )

        let setUpdateStream = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "sets"
        )
        let setDeleteStream = channel.postgresChange(
            DeleteAction.self,
            schema: "public",
            table: "sets"
        )
        
        // Listen for agent_session updates (to detect completion)
        let sessionUpdateStream = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "agent_session"
        )
        
        // Subscribe to the channel
        await channel.subscribe()
        
        print("Channel status: \(channel.status)")
        
        // Process session changes
        Task { @MainActor in
            for await change in sessionStream {
                await self.handleSessionChange(change)
            }
        }
        
        // Process routine changes
        Task { @MainActor in
            for await change in routineStream {
                await self.handleRoutineChange(change)
            }
        }
        
        // Process exercise changes
        Task { @MainActor in
            for await change in exerciseStream {
                await self.handleExerciseChange(change)
            }
        }
        
        // Process set changes
        Task { @MainActor in
            for await change in setStream {
                await self.handleSetChange(change)
            }
        }
        
        // Process routine updates
        Task { @MainActor in
            for await change in routineUpdateStream {
                await self.handleRoutineUpdate(change)
            }
        }

        // Process routine deletions
        Task { @MainActor in
            for await change in routineDeleteStream {
                await self.handleRoutineDelete(change)
            }
        }

        // Process exercise updates
        Task { @MainActor in
            for await change in exerciseUpdateStream {
                await self.handleExerciseUpdate(change)
            }
        }

        // Process exercise deletions
        Task { @MainActor in
            for await change in exerciseDeleteStream {
                await self.handleExerciseDelete(change)
            }
        }

        // Process set updates
        Task { @MainActor in
            for await change in setUpdateStream {
                await self.handleSetUpdate(change)
            }
        }

        // Process set deletions
        Task { @MainActor in
            for await change in setDeleteStream {
                await self.handleSetDelete(change)
            }
        }
        
        // Process session updates (completion)
        Task { @MainActor in
            for await change in sessionUpdateStream {
                await self.handleSessionUpdate(change)
            }
        }
    }
    
    @MainActor
    private func handleSessionChange(_ change: InsertAction) async {
        let action = change

        do {
            // 1. pull id from realtime payload
            guard
                let anyId = action.record["id"],                  // AnyJSON?
                case let .string(idString) = anyId,               // extract the String inside
                let sessionUUID = UUID(uuidString: idString)
            else {
                print("SessionChange missing valid id:", action.record["id"] as Any)
                return
            }

            // 2. fetch canonical row from DB
            let response = try await supabase
                .from("agent_session")
                .select("*")
                .eq("id", value: sessionUUID)
                .single()
                .execute()

            // 3. decode into AgentSessionRow
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let session = try decoder.decode(AgentSessionRow.self, from: response.data)

            self.currentSessionId = session.id
            print("New session created: \(session.id)")
        } catch {
            print("Failed to load session from DB: \(error)")
        }
    }
    
    @MainActor
    private func handleSessionUpdate(_ change: UpdateAction) async {
        let action = change
        do {
            guard
                let anyId = action.record["id"],
                case let .string(idString) = anyId,
                let sessionUUID = UUID(uuidString: idString)
            else {
                print("SessionUpdate missing valid id:", action.record["id"] as Any)
                return
            }

            let response = try await supabase
                .from("agent_session")
                .select("*")
                .eq("id", value: sessionUUID)
                .single()
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let session = try decoder.decode(AgentSessionRow.self, from: response.data)

            if session.status == .completed {
                self.agentCompleted = true
                print("Agent session completed: \(session.id)")
            }
        } catch {
            print("Failed to load session update from DB: \(error)")
        }
    }
    
    @MainActor
    private func handleRoutineChange(_ change: InsertAction) async {
        let action = change

        do {
            // 1. pull id from realtime payload
            // print(action) line removed here

            // pull "id" from record which is [String: AnyJSON?]
            guard
                let anyId = action.record["id"],                  // AnyJSON?
                case let .string(idString) = anyId,               // extract the String inside
                let routineUUID = UUID(uuidString: idString)
            else {
                print("RoutineChange missing valid id:", action.record["id"] as Any)
                return
            }

            // 2. fetch canonical row
            print(routineUUID)
            let response = try await supabase
                .from("agent_routine")
                .select("*")
                .eq("id", value: routineUUID)
                .single()
                .execute()

            // 3. decode into AgentRoutineRow
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let routine = try decoder.decode(AgentRoutineRow.self, from: response.data)

            self.AgentRoutine.type = .agent
            self.AgentRoutine.name = routine.name ?? ""
            self.AgentRoutine.date = routine.date
            self.AgentRoutine.id = routine.id

            print("Routine updated: \(routine.name ?? "unnamed")")
        } catch {
            print("Failed to load routine from DB: \(error)")
        }
    }
    
    @MainActor
    private func handleExerciseChange(_ change: InsertAction) async {
        let action = change
        
        do {
            // 1. pull id from realtime payload
            guard
                let anyId = action.record["id"],                  // AnyJSON?
                case let .string(idString) = anyId,               // extract the String inside
                let exerciseUUID = UUID(uuidString: idString)
            else {
                print("ExerciseChange missing valid id:", action.record["id"] as Any)
                return
            }

            // 2. fetch canonical row
            let response = try await supabase
                .from("exercises")
                .select("*")
                .eq("id", value: exerciseUUID)
                .single()
                .execute()

            // 3. decode into Exercise
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let exercise = try decoder.decode(Exercise.self, from: response.data)
            self.AgentRoutine.exercises.append(exercise)
            print("Exercise added: \(exercise.name ?? "unnamed")")
        } catch {
            print("Failed to load exercise from DB: \(error)")
        }
    }
    
    @MainActor
    private func handleSetChange(_ change: InsertAction) async {
        let action = change

        do {
            // 1. pull id from realtime payload
            guard
                let anyId = action.record["id"],                  // AnyJSON?
                case let .string(idString) = anyId,               // extract the String inside
                let setUUID = UUID(uuidString: idString)
            else {
                print("SetChange missing valid id:", action.record["id"] as Any)
                return
            }

            // 2. fetch canonical row
            let response = try await supabase
                .from("sets")
                .select("*")
                .eq("id", value: setUUID)
                .single()
                .execute()

            // 3. decode into ESet
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let newSet = try decoder.decode(ESet.self, from: response.data)

            // Find matching exercise and append set
            if let index = self.AgentRoutine.exercises.firstIndex(where: { $0.id == newSet.exercise_id }) {
                self.AgentRoutine.exercises[index].sets.append(newSet)
                print("Set added to exercise: \(newSet.id)")
            } else {
                print("No exercise found for set exercise_id: \(newSet.exercise_id)")
            }
        } catch {
            print("Failed to load set from DB: \(error)")
        }
    }

    @MainActor
    private func handleRoutineUpdate(_ change: UpdateAction) async {
        let action = change
        do {
            guard
                let anyId = action.record["id"],
                case let .string(idString) = anyId,
                let routineUUID = UUID(uuidString: idString)
            else {
                print("RoutineUpdate missing valid id:", action.record["id"] as Any)
                return
            }

            // Only update if this is the currently tracked routine
            guard routineUUID == self.AgentRoutine.id else { return }

            let response = try await supabase
                .from("agent_routine")
                .select("*")
                .eq("id", value: routineUUID)
                .single()
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let routine = try decoder.decode(AgentRoutineRow.self, from: response.data)

            self.AgentRoutine.name = routine.name ?? self.AgentRoutine.name
            self.AgentRoutine.date = routine.date
            print("Routine updated (update): \(routine.name ?? "unnamed")")
        } catch {
            print("Failed to update routine from DB: \(error)")
        }
    }

    @MainActor
    private func handleRoutineDelete(_ change: DeleteAction) async {
        let action = change
        // Try to extract id from delete payload
        guard
            let anyId = action.oldRecord["id"],
            case let .string(idString) = anyId,
            let routineUUID = UUID(uuidString: idString)
        else {
            print("RoutineDelete missing valid id:", action.oldRecord["id"] as Any)
            return
        }

        if routineUUID == self.AgentRoutine.id {
            // Reset routine to empty state
            self.AgentRoutine = Routine(id: UUID(), name: "", type: .ai)
            print("Routine deleted; cleared current AgentRoutine")
        }
    }

    @MainActor
    private func handleExerciseUpdate(_ change: UpdateAction) async {
        let action = change
        do {
            guard
                let anyId = action.record["id"],
                case let .string(idString) = anyId,
                let exerciseUUID = UUID(uuidString: idString)
            else {
                print("ExerciseUpdate missing valid id:", action.record["id"] as Any)
                return
            }

            let response = try await supabase
                .from("exercises")
                .select("*")
                .eq("id", value: exerciseUUID)
                .single()
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let exercise = try decoder.decode(Exercise.self, from: response.data)

            if let idx = self.AgentRoutine.exercises.firstIndex(where: { $0.id == exercise.id }) {
                self.AgentRoutine.exercises[idx] = exercise
            } else {
                // If not present and it belongs to current routine, append
                if exercise.routine_id == self.AgentRoutine.id {
                    self.AgentRoutine.exercises.append(exercise)
                }
            }
            print("Exercise updated: \(exercise.name ?? "unnamed")")
        } catch {
            print("Failed to update exercise from DB: \(error)")
        }
    }

    @MainActor
    private func handleExerciseDelete(_ change: DeleteAction) async {
        let action = change
        guard
            let anyId = action.oldRecord["id"],
            case let .string(idString) = anyId,
            let exerciseUUID = UUID(uuidString: idString)
        else {
            print("ExerciseDelete missing valid id:", action.oldRecord["id"] as Any)
            return
        }

        if let idx = self.AgentRoutine.exercises.firstIndex(where: { $0.id == exerciseUUID }) {
            self.AgentRoutine.exercises.remove(at: idx)
            print("Exercise deleted: \(exerciseUUID)")
        }
    }

    @MainActor
    private func handleSetUpdate(_ change: UpdateAction) async {
        let action = change
        do {
            guard
                let anyId = action.record["id"],
                case let .string(idString) = anyId,
                let setUUID = UUID(uuidString: idString)
            else {
                print("SetUpdate missing valid id:", action.record["id"] as Any)
                return
            }

            let response = try await supabase
                .from("sets")
                .select("*")
                .eq("id", value: setUUID)
                .single()
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .supabaseTS
            let updatedSet = try decoder.decode(ESet.self, from: response.data)

            if let exIdx = self.AgentRoutine.exercises.firstIndex(where: { $0.id == updatedSet.exercise_id }) {
                if let setIdx = self.AgentRoutine.exercises[exIdx].sets.firstIndex(where: { $0.id == updatedSet.id }) {
                    self.AgentRoutine.exercises[exIdx].sets[setIdx] = updatedSet
                } else {
                    self.AgentRoutine.exercises[exIdx].sets.append(updatedSet)
                }
                print("Set updated: \(updatedSet.id)")
            }
        } catch {
            print("Failed to update set from DB: \(error)")
        }
    }

    @MainActor
    private func handleSetDelete(_ change: DeleteAction) async {
        let action = change
        guard
            let anyId = action.oldRecord["id"],
            case let .string(idString) = anyId,
            let setUUID = UUID(uuidString: idString)
        else {
            print("SetDelete missing valid id:", action.oldRecord["id"] as Any)
            return
        }

        // Find exercise containing this set and remove it
        for exIndex in self.AgentRoutine.exercises.indices {
            if let setIdx = self.AgentRoutine.exercises[exIndex].sets.firstIndex(where: { $0.id == setUUID }) {
                self.AgentRoutine.exercises[exIndex].sets.remove(at: setIdx)
                print("Set deleted: \(setUUID)")
                break
            }
        }
    }
    
    func stopAgent() async {
        // Unsubscribe from the channel when done
        await realtimeChannel?.unsubscribe()
        realtimeChannel = nil
        isRunning = false
    }
    
    deinit {
        Task { @MainActor in
            await stopAgent()
        }
    }
}

