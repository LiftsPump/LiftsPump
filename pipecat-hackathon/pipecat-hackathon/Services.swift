// Services.swift
// Minimal stub implementations for YouTube, Gemini, and Speech.
// Replace internals with real API calls to YouTube Data API, Gemini, and Pipecat.

import Foundation
import AVFoundation

// MARK: - YouTube
struct YouTubeMetadata {
    let title: String
    let channelName: String
    let presenterName: String?
}

actor YouTubeService {
    func fetchMetadata(for url: URL) async throws -> YouTubeMetadata {
        // TODO: Replace with actual YouTube Data API call or oEmbed fetch.
        // Heuristic placeholders.
        return YouTubeMetadata(title: "YouTube Video", channelName: "Channel", presenterName: nil)
    }
    
    func fetchTranscript(for url: URL) async throws -> String {
        // TODO: Implement transcript fetching using YouTube transcript APIs or 3rd-party service.
        // For hackathon stub, return placeholder.
        return "[Transcript placeholder: replace with real transcript text extracted from the video]"
    }
}

// MARK: - Gemini (LLM)
actor GeminiPersonaService {
    private var systemPrompt: String = ""
    
    func setSystemPrompt(_ prompt: String) {
        systemPrompt = prompt
    }
    
    func buildPersonaSystemPrompt(videoTitle: String, channel: String, transcript: String) -> String {
        // Safety & ethics note: do not impersonate real individuals without consent. Frame as a persona trained on public content.
        """
        You are a helpful assistant adopting the communication style of the presenter from the referenced video. Do not claim to be the real person. You may say "I'm a simulated persona based on the presenter's style." Maintain an educational and respectful tone.
        Video title: \(videoTitle)
        Channel: \(channel)
        Transcript excerpts (may be partial and noisy):
        \(transcript.prefix(8000))
        Style guidance: Mirror vocabulary, pacing, and phrasing patterns from the transcript. Avoid sensitive personal claims.
        """
    }
    
    func generateReply(history: [ChatMessage]) async throws -> String {
        // TODO: Call Gemini API with systemPrompt + history. For now, echo a stylized response.
        let lastUser = history.last { $0.role == .user }?.text ?? ""
        return "(Persona) \(lastUser) — here's a concise answer based on the video's content. [Stubbed Gemini reply]"
    }
}

// MARK: - Speech (Pipecat placeholder)
actor SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) async throws {
        // TODO: Replace with Pipecat streaming TTS. This is a simple local TTS fallback.
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US")
        synthesizer.speak(utterance)
        // Wait until speaking has started briefly (non-blocking best-effort)
        try await Task.sleep(nanoseconds: 150_000_000)
    }
}
