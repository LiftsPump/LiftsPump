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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(defaultTab: WorkoutTab) {
        self.defaultTab = defaultTab
        _selectedTab = State(initialValue: defaultTab)
        self.tab = false
        self.calorlist = false
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
                WorkoutTabs(color: selectedTab == .history ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Workout History", textColor: selectedTab == .history ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                    .onTapGesture { selectedTab = .history
                        showAccessory.toggle()}
                WorkoutTabs(color: selectedTab == .created ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Created Workouts", textColor: selectedTab == .created ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                    .onTapGesture { selectedTab = .created
                        showAccessory.toggle()}
                WorkoutTabs(color: selectedTab == .prs ? Theme.Colors.Primary1 : Theme.Colors.NeutralGray1, text: "Personal Records", textColor: selectedTab == .prs ? Theme.Colors.NeutralDark : Theme.Colors.NeutralDarkGray1)
                    .onTapGesture { selectedTab = .prs
                        showAccessory.toggle() }
            }
            .padding(.horizontal)
            
            if selectedTab == .history {
                HStack {
                    Spacer()
                    Text(calorlist ? "Calendar View" : "List View")
                        .padding(.trailing)
                        .padding(.top, 8)
                        .font(Theme.Fonts.SubHeading5)
                        .onTapGesture {
                            calorlist.toggle()
                        }
                }
                if calorlist {
                    CompletedScreen()
                } else {
                    CalendarScreen(selectedDate: $selectedDate)
                        .onChange(of: selectedDate) { newDate in
                            print("Date selected from CalendarScreen: \(newDate)")
                        }
                }
            } else if selectedTab == .created {
                CreatedScreen()
            } else if selectedTab == .prs {
                PRScreen()
            }
            Spacer()
        }
        .sensoryFeedback(.selection, trigger: showAccessory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.NeutralDark)
        .overlay(content: {VStack{Spacer()
            HStack{Spacer()
                if (selectedTab == .history || selectedTab == .created) && (!calorlist) {
                    if selectedTab == .history && !calorlist {
                        PlusButton(date: $selectedDate)
                    } else {
                        PlusButton(date: .constant(Date()))
                    }
                }
                }}})
    }
}

#Preview {
    WorkoutScreen(defaultTab: WorkoutTab.history)
}
