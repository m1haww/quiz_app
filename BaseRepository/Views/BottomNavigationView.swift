import SwiftUI

struct BottomNavigationView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationButton(
                icon: "home",
                label: "Home",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            NavigationButton(
                icon: "star",
                label: "Leaderboard",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            NavigationButton(
                icon: "profile",
                label: "Profile",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            NavigationButton(
                icon: "settings",
                label: "Settings",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: "#7328CF"))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct NavigationButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1.0 : 0.6)
                
                if isSelected {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BottomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationView(selectedTab: .constant(0))
            .background(Color(hex: "#351162"))
    }
}
