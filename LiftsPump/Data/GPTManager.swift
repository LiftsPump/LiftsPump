//
//  GPTManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/28/25.
//

import Foundation
import OpenAI
import SwiftData
import SwiftUI

let openai = OpenAI(apiToken: "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")

public class GPTManager {
    @Published var routines: [Routine]
    private var modelContext: ModelContext
    @AppStorage("FIRSTNAME_KEY") private var firstName: String = ""
    @AppStorage("LASTNAME_KEY") private var lastName: String = ""
    @AppStorage("EMAIL_KEY") private var email: String = ""
    @AppStorage("HEIGHT_KEY") private var height: Int = 0
    @AppStorage("WEIGHT_KEY") private var weight: Int = 0
    @AppStorage("DOB_KEY") private var dob: Double = Date().timeIntervalSince1970

    init(routines: [Routine], context: ModelContext) {
        self.routines = routines
        self.modelContext = context
    }

    @MainActor
    public func generateWorkouts() async throws {
        let profile = Profile(first_name: firstName, last_name: lastName, phone_number: "", height: height, weight: weight, dob: Date(timeIntervalSince1970: dob), type: 0)
        guard let jsonData = try? JSONEncoder().encode(profile),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to encode profile to JSON")
            return
        }
        for routine in routines {
            if routine.type == .ai {
                print("generated previously")
                return
            }
        }

            let userMessage = [ChatQuery.ChatCompletionMessageParam(role: .user, content: jsonString)!]
            let threadsQuery = ThreadsQuery(messages: userMessage)
            let runQuery: RunsQuery = .init(assistantId: "asst_76XTrr2TSbRQtnObY9EhqXBv")

            let thread = try await openai.threads(query: threadsQuery)
            let run = try await openai.runs(threadId: thread.id, query: runQuery)
            var runStatus = run.status
            while runStatus.rawValue != "completed" && runStatus.rawValue != "failed" && runStatus.rawValue != "cancelled" {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                let updatedRun = try await openai.runRetrieve(threadId: thread.id, runId: run.id)
                runStatus = updatedRun.status
                print("Run status: \(runStatus)")
            }

            if runStatus.rawValue == "completed" {
                let messages = try await openai.threadsMessages(threadId: thread.id)
                for message in messages.data {
                    if message.role == .assistant {
                        print(message.content)
                        if let firstContent = message.content.first,
                            case let (textContent) = firstContent,
                            var rawValue = textContent.text?.value {
                                
                            // Clean markdown formatting if present
                            rawValue = rawValue
                                .replacingOccurrences(of: "```json", with: "")
                                .replacingOccurrences(of: "```", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)

                            if let cleanedData = rawValue.data(using: .utf8) {
                                do {
                                    let decodedRoutines = try JSONDecoder().decode([Routine].self, from: cleanedData)
                                    print(decodedRoutines)
                                    for decoded in decodedRoutines {
                                        // 1) Create a fresh managed Routine instance
                                        let routine = Routine(
                                            name: decoded.name,
                                            picture: decoded.picture,
                                            text: decoded.text,
                                            type: .ai,
                                            days: decoded.days,
                                            weekly: decoded.weekly,
                                        )
                                        routine.id = UUID()
                                        
                                        // 2) Copy over every Exercise → Set and insert each one so SwiftData tracks them
                                        for sourceExercise in decoded.exercises {
                                            let exercise = Exercise(
                                                name: sourceExercise.name,
                                                eCode: sourceExercise.eCode,
                                                text: sourceExercise.text
                                            )
                                            exercise.id = UUID()
                                            exercise.routine = routine
                                            
                                            for sourceSet in sourceExercise.sets {
                                                let set = ESet(
                                                    weight: sourceSet.weight,
                                                    reps: sourceSet.reps,
                                                    pr: sourceSet.pr,
                                                    completed: sourceSet.completed
                                                )
                                                set.id = UUID()
                                                set.exercise = exercise
                                                modelContext.insert(set)        // ← child object must be inserted
                                                exercise.sets.append(set)
                                            }
                                            
                                            modelContext.insert(exercise)       // ← child object must be inserted
                                            routine.exercises.append(exercise)
                                        }
                                        
                                        modelContext.insert(routine)            // ← finally insert the parent
                                    }
                                    print("Successfully assigned decoded routines")
                                } catch {
                                    print("Failed to decode routines: \(error)")
                                }
                            } else {
                                print("Failed to convert cleaned JSON string to Data")
                            }
                        }
                        print("CHATGPT THANK YOU")
                    }
                }
            } else {
                print("Run ended with status: \(runStatus)")
            }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        }
}
