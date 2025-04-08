//
//  WorkoutBundle.swift
//  Workout
//
//  Created by Ahmed Abushagur on 4/8/25.
//

import WidgetKit
import SwiftUI

@main
struct WorkoutBundle: WidgetBundle {
    var body: some Widget {
        Workout()
        WorkoutControl()
        WorkoutLiveActivity()
    }
}
