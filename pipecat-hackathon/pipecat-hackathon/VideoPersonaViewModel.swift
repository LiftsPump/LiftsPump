// VideoPersonaViewModel.swift
// High-level orchestration of the pipeline: URL -> transcript -> persona -> chat -> TTS.

import Foundation
import SwiftUI

@MainActor
final class VideoPersonaViewModel: ObservableObject {
    // Input
    @Published var youtubeURL: String = ""
    @Published var currentInput: String = ""
    
    // UI state
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var personaDisplayName: String? = nil
    @Published var messages: [ChatMessage] = []
    
    // Services (simple stubs you can replace with real integrations)
    private let youtube = YouTubeService()
    private let llm = GeminiPersonaService()
    private let speech = SpeechService()
    
    var canStart: Bool {
        guard let url = URL(string: youtubeURL), url.scheme?.hasPrefix("http") == true else { return false }
        return true
    }
    
    func startPipeline() {
        errorMessage = nil
        statusMessage = nil
        guard canStart else {
            errorMessage = "Please paste a valid YouTube URL."
            return
        }
        Task { await runPipeline() }
    }
    
    private func resetConversation() {
        messages.removeAll()
    }
    
    private func appendSystemNote(_ text: String) {
        statusMessage = text
    }
    
    private func runPipeline() async {
        isProcessing = true
        defer { isProcessing = false }
        resetConversation()
        appendSystemNote("Fetching video metadata…")
        do {
            let url = URL(string: youtubeURL)!
            let meta = try await youtube.fetchMetadata(for: url)
            personaDisplayName = meta.presenterName ?? meta.title
            appendSystemNote("Fetching transcript…")
            let transcript = try await youtube.fetchTranscript(for: url)
            appendSystemNote("Building persona with Gemini…")
            let systemPrompt = llm.buildPersonaSystemPrompt(videoTitle: meta.title, channel: meta.channelName, transcript: transcript)
            llm.setSystemPrompt(systemPrompt)
            messages.append(ChatMessage(role: .assistant, text: "Hi, I'm \(personaDisplayName ?? "the presenter"). Ask me anything about this video!"))
            statusMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    func sendUserMessage() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = ChatMessage(role: .user, text: trimmed)
        messages.append(userMsg)
        currentInput = ""
        Task { await respond(to: userMsg) }
    }
    
    private func respond(to userMessage: ChatMessage) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            let history = messages
            let reply = try await llm.generateReply(history: history)
            let assistantMsg = ChatMessage(role: .assistant, text: reply)
            messages.append(assistantMsg)
            // Speak using placeholder TTS. Replace with Pipecat integration.
            try await speech.speak(text: reply)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
