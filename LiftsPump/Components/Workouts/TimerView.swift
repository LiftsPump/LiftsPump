import SwiftUI

class TimerManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @State var showAccessory = false
    private var timer: Timer? = nil

    func toggleTimer(startOrStop: Bool) {
        if startOrStop {
            // Stop the timer
            timer?.invalidate()
            timer = nil
        } else {
            // Start the timer
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in 
                self.elapsedTime += 1
                self.showAccessory.toggle()
            }
        }
    }
}

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    private let dateFormatter: DateComponentsFormatter
    @State private var previousAccessoryState: Bool = false

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        self.dateFormatter = formatter
    }

    var body: some View {
        Text(dateFormatter.string(from: timerManager.elapsedTime) ?? "00:00")
            .font(Theme.Fonts.SubHeading2)
            .foregroundStyle(Theme.Colors.NeutralLight1)
            .padding(.trailing, 10)
            .onChange(of: timerManager.showAccessory) { newValue in
                if newValue != previousAccessoryState {
                    previousAccessoryState = newValue
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
            }
    }
}
