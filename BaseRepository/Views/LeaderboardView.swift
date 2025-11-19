import SwiftUI

struct LeaderboardView: View {
    @State private var leaderboardData: [LeaderboardEntry] = []
    @ObservedObject private var userService = UserService.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text(localizationManager.localizedString("leaderboard"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                
                // Leaderboard Container
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(leaderboardData.enumerated()), id: \.offset) { index, entry in
                            LeaderboardRow(
                                position: index + 1,
                                entry: entry,
                                isFirst: index == 0,
                                isLast: index == leaderboardData.count - 1
                            )
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for bottom navigation
                }
            }
        }
        .onAppear {
            loadLeaderboardData()
        }
        .onChange(of: userService.totalStars) { _ in
            loadLeaderboardData()
        }
        .onChange(of: userService.username) { _ in
            loadLeaderboardData()
        }
        .onChange(of: userService.selectedAvatar) { _ in
            loadLeaderboardData()
        }
    }
    
    private func loadLeaderboardData() {
        // Create our user entry with real data
        let ourUser = LeaderboardEntry(
            username: userService.username.isEmpty ? "User" : userService.username,
            avatar: userService.selectedAvatar.isEmpty ? "1" : userService.selectedAvatar,
            stars: userService.totalStars
        )
        
        // Generate sample leaderboard data with varied stars
        var staticData = [
            LeaderboardEntry(username: "Alex_Pro", avatar: "1", stars: 187),
            LeaderboardEntry(username: "Sarah_Smith", avatar: "2", stars: 156),
            LeaderboardEntry(username: "Gaming_Master", avatar: "3", stars: 143),
            LeaderboardEntry(username: "Quiz_King", avatar: "4", stars: 132),
            LeaderboardEntry(username: "Smart_Player", avatar: "5", stars: 128),
            LeaderboardEntry(username: "Brain_Power", avatar: "6", stars: 119),
            LeaderboardEntry(username: "Quick_Mind", avatar: "7", stars: 108),
            LeaderboardEntry(username: "Trivia_Fan", avatar: "8", stars: 98),
            LeaderboardEntry(username: "Knowledge_Hub", avatar: "9", stars: 87),
            LeaderboardEntry(username: "Study_Buddy", avatar: "1", stars: 76),
            LeaderboardEntry(username: "Facts_Master", avatar: "2", stars: 65),
            LeaderboardEntry(username: "Info_Seeker", avatar: "3", stars: 54)
        ]
        
        // Add our user to the list
        staticData.append(ourUser)
        
        // Sort by stars (descending) and take top positions
        leaderboardData = staticData.sorted { $0.stars > $1.stars }
        
        print("📊 LeaderboardView: Updated leaderboard with user '\(ourUser.username)' having \(ourUser.stars) stars")
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let avatar: String
    let stars: Int
}

struct LeaderboardRow: View {
    let position: Int
    let entry: LeaderboardEntry
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Position number
            Text("\(position)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 20)
            
            // Avatar
            Image(entry.avatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#D29B43"), lineWidth: 2)
                )
            
            // Username
            Text(entry.username)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            // Stars count
            Text("\(entry.stars) stars")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}