import SwiftUI

struct WorkoutComponent: View {
    var title: String
    var image: String
    var description: String
    var body: some View {
        VStack() {
            Text("\(title)")
                .fontWeight(.semibold)
                .padding([.top, .leading])
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Theme.Colors.Primary1)
                .font(.system(size: 25))
            
            HStack(alignment: .top) {
                Image(systemName: "\(image)")
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.init(red: 0.5333333333333333, green: 0.996078431372549, blue: 0.7686274509803922), Color.gray]),
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(10)
                    .font(.system(size: 45))
                    .padding(.bottom)
                    .padding(.top, 1)
                    .padding(.leading, 12)
                Text("\(description)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading, 6)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 155)
        .background(Theme.Colors.NeutralDark2)
        .cornerRadius(10)
        .padding(.top, -7.0)
    }
}

#Preview {
    WorkoutComponent(title: "Chest & Back", image: "figure.run", description: "Enhance upper body strength and muscle definition by targeting the major muscle groups in the chest and back.")
}
