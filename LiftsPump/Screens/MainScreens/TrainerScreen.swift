import SwiftUI
import AppIntents
import SwiftData
import LiveKit
import LiveKitComponents

struct TrainerScreen: View {
    @AppStorage("TRAINER_NAME_KEY") var trainerName: String = "Ahmed"
    @AppStorage("TRAINER_VIDEOS_KEY") var trainerVideosJson: String = "[]"
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]
    @State private var selectedDate: Date = Date()
    @StateObject private var room: Room = Room()
    @State private var isCalling: Bool = false
    @State private var isConnectingCall: Bool = false
    @State private var callError: String? = nil

    private var videos: [String] {
        if let data = trainerVideosJson.data(using: .utf8),
           let vids = try? JSONDecoder().decode([String].self, from: data) {
            return vids
        }
        return []
    }
    
    private var assignedRoutines: [Routine] {
        routines.filter { $0.type == .assigned }
    }

    private var trainerInitials: String {
        let parts = trainerName.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? String(trainerName.prefix(1)) : initials
    }

    @ViewBuilder
    private func hubTile(title: String, subtitle: String, systemImage: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tint.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(tint.opacity(0.18))
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .font(Theme.Fonts.Body2)
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                    Text(subtitle)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .font(Theme.Fonts.Body6)
                        .foregroundStyle(Theme.Colors.NeutralLight1.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.NeutralLight1.opacity(0.7))
            }
            .padding(14)
        }
        .frame(height: 72)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Theme.Colors.Primary1.opacity(0.35), Theme.Colors.PurpleGradient.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                        Text(trainerInitials.uppercased())
                            .font(Theme.Fonts.SubHeading3)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trainerName.isEmpty ? "Your Coach" : trainerName)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .font(Theme.Fonts.Heading2)
                            .foregroundStyle(Theme.Colors.Primary1)
                        Text(assignedRoutines.isEmpty ? "No plans assigned yet" : "\(assignedRoutines.count) plan(s) assigned to you")
                            .font(Theme.Fonts.Body4)
                            .foregroundStyle(Theme.Colors.NeutralLight1.opacity(0.8))
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        Button(action: {
                            Task { await startCall() }
                        }) {
                            Image(systemName: "phone.fill")
                                .font(Theme.Fonts.SubHeading2)
                                .foregroundStyle(isCalling ? Theme.Colors.NeutralLight1 : Theme.Colors.Primary1.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Text("Call")
                            .font(Theme.Fonts.Body1)
                            .foregroundStyle(isCalling ? Theme.Colors.NeutralLight1 : Theme.Colors.Primary1.opacity(0.85))
                    }
                    .accessibilityElement(children: .combine)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Coach Hub quick actions (client view) – horizontal tiles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick actions")
                        .font(Theme.Fonts.SubHeading2)
                        .foregroundStyle(Theme.Colors.Primary1)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if !videos.isEmpty {
                                NavigationLink { CoachVideosView(videos: videos) } label: {
                                    hubTile(title: "Videos", subtitle: "Coaching clips & tutorials", systemImage: "play.rectangle.fill", tint: Color.red)
                                        .frame(width: 260)
                                }
                            }
                            NavigationLink { CoachExercisesView() } label: {
                                hubTile(title: "Custom Exercises", subtitle: "Exclusive movements & form", systemImage: "list.bullet.rectangle.portrait", tint: Color.orange)
                                    .frame(width: 260)
                            }
                            NavigationLink { CoachTiersView() } label: {
                                hubTile(title: "Membership Tiers", subtitle: "Manage your access level", systemImage: "person.3.sequence", tint: Color.indigo)
                                    .frame(width: 260)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Schedule (calendar) — bottom
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Schedule")
                            .font(Theme.Fonts.SubHeading2)
                            .foregroundStyle(Theme.Colors.Primary1)
                        Spacer()
                    }
                    .padding(.horizontal)

                    CalendarScreen(selectedDate: $selectedDate, trainer: true)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.Colors.Primary1.opacity(0.12), lineWidth: 1))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.NeutralDark)
        .overlay(
            Group {
                if isCalling {
                    ZStack {
                        CallOverlay()
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            // Status / error
                            if isConnectingCall {
                                ProgressView("Connecting to your coach…")
                                    .tint(.white)
                                    .foregroundStyle(.white)
                            }
                            if let callError {
                                Text(callError)
                                    .font(Theme.Fonts.Body3)
                                    .foregroundStyle(.red)
                            }

                            // Remote video (if any participants publish video)
                            ScrollView {
                                LazyVStack {
                                    ForEachParticipant { _ in
                                        VStack {
                                            ForEachTrack(filter: .video) { trackReference in
                                                VideoTrackView(trackReference: trackReference)
                                                    .frame(maxWidth: 600, maxHeight: 400)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 12)

                            // Hangup button (X)
                            Button(action: {
                                Task { await endCall() }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(14)
                                    .background(Circle().fill(Color.red.opacity(0.9)))
                            }
                            .accessibilityLabel("Hang up")
                        }
                        .padding()
                    }
                    .environmentObject(room)
                    .transition(.opacity)
                }
            }
        )
        .syncOnScroll(modelContext: modelContext)
    }

    private func startCall() async {
        if isCalling || isConnectingCall { return }
        isCalling = true
        isConnectingCall = true
        callError = nil
        do {
            try await LiveKitCallService.connect(room: room)
        } catch {
            callError = "Failed to connect: \(error.localizedDescription)"
            // If connect fails, close overlay after showing error briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCalling = false
            }
        }
        isConnectingCall = false
    }

    private func endCall() async {
        await LiveKitCallService.disconnect(room: room)
        isCalling = false
    }
}

#Preview {
    TrainerScreen()
}

