//
//  WorkoutLiveActivity.swift
//  Workout
//
//  Created by Ahmed Abushagur on 4/8/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WorkoutAttributes {
    fileprivate static var preview: WorkoutAttributes {
        WorkoutAttributes(name: "World")
    }
}

extension WorkoutAttributes.ContentState {
    fileprivate static var smiley: WorkoutAttributes.ContentState {
        WorkoutAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WorkoutAttributes.ContentState {
         WorkoutAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WorkoutAttributes.preview) {
   WorkoutLiveActivity()
} contentStates: {
    WorkoutAttributes.ContentState.smiley
    WorkoutAttributes.ContentState.starEyes
}
