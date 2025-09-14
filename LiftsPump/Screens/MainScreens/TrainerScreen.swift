import SwiftUI
import AppIntents
import SwiftData

struct TrainerScreen: View {
    @AppStorage("TRAINER_NAME_KEY") var trainerName: String = "Ahmed"
    @AppStorage("TRAINER_VIDEOS_KEY") var trainerVideosJson: String = "[]"
    @Environment(\.modelContext) private var modelContext
    @Query var routines: [Routine]

    private var videos: [String] {
        if let data = trainerVideosJson.data(using: .utf8),
           let vids = try? JSONDecoder().decode([String].self, from: data) {
            return vids
        }
        return []
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(trainerName)
                    .font(Theme.Fonts.Heading1)
                    .foregroundStyle(Theme.Colors.Primary1)
                    .padding(.horizontal)
                if !videos.isEmpty {
                    Text("Videos")
                        .font(Theme.Fonts.Body2)
                        .foregroundStyle(Theme.Colors.Primary1)
                        .padding(.horizontal)
                    ForEach(videos, id: \.self) { link in
                        if let id = extractYouTubeID(from: link) {
                            YouTubeView(videoID: id)
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                }
                ForEach(routines) { routine in
                    if routine.type == .assigned {
                        NavigationLink {
                            WorkoutCompleted(
                                externalRoutine: Binding(
                                    get: { routine },
                                    set: { updatedRoutine in
                                        modelContext.insert(updatedRoutine)
                                    }
                                ),
                                plusButton: false
                            ).navigationBarBackButtonHidden(true)
                        } label: {
                            WorkoutComponent(
                                title: routine.name,
                                image: "figure.run",
                                description: DataMethods.summarizer(routine: routine)
                            )
                            .padding(.horizontal)
                        }
                        Spacer().padding(3)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    TrainerScreen()
}
