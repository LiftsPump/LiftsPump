import SwiftUI

class TimerManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var showAccessory: Bool = false
    @Published private(set) var isRunning: Bool = false

    private var timer: Timer? = nil
    private var startDate: Date? = nil
    private var accumulated: TimeInterval = 0

    func toggleTimer(startOrStop: Bool) {
        if startOrStop {
            pause()
        } else {
            start()
        }
    }

    func start() {
        // Do nothing if already running
        guard !isRunning else { return }
        isRunning = true
        // If there is no startDate, start from now
        if startDate == nil {
            startDate = Date()
        }
        scheduleTimerIfNeeded()
        // Update immediately to reflect any time passed while app was inactive
        recalculateElapsed()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        if let start = startDate {
            accumulated += Date().timeIntervalSince(start)
        }
        startDate = nil
        invalidateTimer()
        recalculateElapsed()
    }

    func reset() {
        invalidateTimer()
        isRunning = false
        startDate = nil
        accumulated = 0
        elapsedTime = 0
    }

    func refresh() {
        // Recalculate from wall clock; useful on foreground transitions
        recalculateElapsed()
    }

    private func scheduleTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // Ensure timer fires during common run loop modes
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        recalculateElapsed()
        showAccessory.toggle()
    }

    private func recalculateElapsed() {
        let runningDelta: TimeInterval
        if let start = startDate {
            runningDelta = Date().timeIntervalSince(start)
        } else {
            runningDelta = 0
        }
        let total = accumulated + runningDelta
        if total != elapsedTime {
            elapsedTime = total
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
