import SwiftUI

enum WorkoutTab {
    case history, created, prs
}
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct WorkoutScreen: View {
    private var defaultTab: WorkoutTab
    private var tab: Bool
    @State var selectedDate: Date = Date()
    @State private var calorlist: Bool
    @State private var showAccessory = false
    @State private var selectedTab: WorkoutTab
    @State private var previousTab: WorkoutTab = .history
    @State private var flipTab: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(defaultTab: WorkoutTab) {
        self.defaultTab = defaultTab
        _selectedTab = State(initialValue: defaultTab)
        self.tab = false
        self.calorlist = false
        self.flipTab = false
    }
    func selectedTabIndex(for tab: WorkoutTab) -> Int {
        switch tab {
        case .history: return 0
        case .created: return 1
        case .prs: return 2
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Workouts")
                    .font(Theme.Fonts.Heading1)
                    .foregroundStyle(Theme.Colors.Primary1)
                Spacer()
            }
            .padding(.leading)
            
            HStack {
                Button(action: {
                    flipTab = selectedTabIndex(for: .history) < selectedTabIndex(for: selectedTab)
                    previousTab = selectedTab
                    selectedTab = .history
                    showAccessory.toggle()
                }) {
                    WorkoutTabs(color: selectedTab == .history ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Workout History", textColor: selectedTab == .history ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Workout History tab")
                
                Button(action: {
                    flipTab = selectedTabIndex(for: .created) < selectedTabIndex(for: selectedTab)
                    previousTab = selectedTab
                    selectedTab = .created
                    showAccessory.toggle()
                }) {
                    WorkoutTabs(color: selectedTab == .created ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Created Workouts", textColor: selectedTab == .created ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Created Workouts tab")
                
                Button(action: {
                    flipTab = selectedTabIndex(for: .prs) < selectedTabIndex(for: selectedTab)
                    previousTab = selectedTab
                    selectedTab = .prs
                    showAccessory.toggle()
                }) {
                    WorkoutTabs(color: selectedTab == .prs ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Personal Records", textColor: selectedTab == .prs ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Personal Records tab")
            }
            .padding(.horizontal)
            
            if selectedTab == .history {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { calorlist.toggle() } }) {
                        Text(calorlist ? "Calendar View" : "List View")
                            .padding(.trailing)
                            .padding(.top, 8)
                            .font(Theme.Fonts.SubHeading5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(calorlist ? "Switch to calendar" : "Switch to list")
                }
                if calorlist {
                    CompletedScreen()
                        .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
                } else {
                    CalendarScreen(selectedDate: $selectedDate)
                        .onChange(of: selectedDate) { newDate in
                            print("Date selected from CalendarScreen: \(newDate)")
                        }
                        .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
                }
            } else if selectedTab == .created {
                CreatedScreen()
                    .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
            } else if selectedTab == .prs {
                PRScreen()
                    .transition(.opacity.combined(with: .move(edge: flipTab ? .leading : .trailing)))
            }
            Spacer()
        }
        .animation(.snappy(duration: 0.2), value: selectedTab)
        .animation(.snappy(duration: 0.2), value: calorlist)
        .sensoryFeedback(.selection, trigger: showAccessory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.NeutralDark)
        .overlay(content: {VStack{Spacer()
            HStack{Spacer()
                if (selectedTab == .history || selectedTab == .created) && (!calorlist) {
                    if selectedTab == .history && !calorlist {
                        PlusButton(date: $selectedDate)
                    } else {
                        PlusButton(ifCreateScreen: true, date: .constant(Date()))                    }
                }
                }}})
    }
}

#Preview {
    WorkoutScreen(defaultTab: WorkoutTab.history)
}
