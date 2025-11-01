import Foundation
import Supabase
import LiveKit
import AVFAudio

public enum LiveKitCallService {
    // LiveKit WebSocket URL
    private static let wsURL = "wss://liftspump-cksjcf10.livekit.cloud"

    // Token response from dashboard API
    private struct LiveKitTokenResponse: Decodable {
        let token: String
        let roomName: String?
        let trainerId: String?
        let expiresAt: String?
        let agentPresent: Bool?
        let agent: AgentInfo?
        struct AgentInfo: Decodable {
            let suffixPrompt: String?
            let voice: VoiceInfo?
        }
        struct VoiceInfo: Decodable {
            let provider: String?
            let voiceId: String?
        }
    }

    // Fetch a LiveKit access token for the current user
    // - Returns: Decoded token response from the server
    private static func fetchLiveKitToken() async throws -> LiveKitTokenResponse {
        // Require a logged-in Supabase user and use its id as a String
        guard let userId = supabase.auth.currentUser?.id else {
            throw URLError(.userAuthenticationRequired)
        }
        let userIdString = String(describing: userId)

        guard let url = URL(string: "https://dashboard.liftspump.com/api/livekit/token") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // API expects only { "userId": UUID-string }
        let body: [String: String] = [
            "userId": userIdString
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            // Attempt to parse an `{ error: string }` JSON, else fall back to raw body
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            var message = String(data: data, encoding: .utf8) ?? ""
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errStr = obj["error"] as? String {
                message = errStr
            }
            throw NSError(domain: "LiveKitToken", code: code, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch token (status: \(code)) \(message)"])
        }

        let decoder = JSONDecoder()
        // `expiresAt` is an ISO8601 string in the API; we keep it as String in the model.
        let decoded = try decoder.decode(LiveKitTokenResponse.self, from: data)
        return decoded
    }

    /// Connects the provided LiveKit Room using a freshly fetched token.
    /// - Parameter room: The LiveKit `Room` instance to connect.
    public static func connect(room: Room) async throws {
        let tokenResponse = try await fetchLiveKitToken()
        let token = tokenResponse.token
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
        try await room.connect(
            url: wsURL,
            token: token,
            connectOptions: ConnectOptions(enableMicrophone: true)
        )
        try await room.localParticipant.setCamera(enabled: false)
    }

    /// Disconnects the provided LiveKit Room, ignoring any errors.
    /// - Parameter room: The LiveKit `Room` instance to disconnect.
    public static func disconnect(room: Room) async {
        do { try await room.disconnect() } catch { /* ignore */ }
    }
}
