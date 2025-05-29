//
//  GPTManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/28/25.
//

import Foundation
import OpenAI
import SwiftData
import _SwiftData_SwiftUI

let openai = OpenAI(apiToken: "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")
var AiRoutines: [Routine] = []

public class GPTManager {
    var routines: [Routine]

    init(routines: [Routine]) {
        self.routines = routines
    }

    func generateWorkouts() {
        guard let jsonData = try? JSONEncoder().encode(routines), let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to encode routines to JSON")
            return
        }
        let userMessage = [ChatQuery.ChatCompletionMessageParam(role: .user, content: (jsonString))!]
        let threadsQuery = ThreadsQuery(messages: userMessage)
        let threadRunQuery = ThreadRunQuery(assistantId: "asst_76XTrr2TSbRQtnObY9EhqXBv", thread: threadsQuery)
        print("ran")
        openai.threadRun(query: threadRunQuery) { result in
            switch result {
                case .success(let response):
                print(response)
                openai.threadsMessages(threadId: response.threadId) { result in
                    print(result.map(\.data))
                }
                case .failure(let error):
                    print("Thread run error:", error)
            }
        }
    }
}
