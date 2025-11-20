import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            if horizontalSizeClass == .regular {
                // iPad layout with side navigation
                HStack(spacing: 0) {
                    // Side Navigation for iPad
                    SideNavigationView(selectedTab: $selectedTab)
                        .frame(width: 300)
                    
                    // Main content area
                    Group {
                        switch selectedTab {
                        case 0:
                            HomeView()
                        case 1:
                            StarView()
                        case 2:
                            ProfileView()
                        case 3:
                            SettingsView()
                        default:
                            HomeView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // iPhone layout with bottom navigation
                VStack(spacing: 0) {
                    // Main content area
                    Group {
                        switch selectedTab {
                        case 0:
                            HomeView()
                        case 1:
                            StarView()
                        case 2:
                            ProfileView()
                        case 3:
                            SettingsView()
                        default:
                            HomeView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom Navigation
                    BottomNavigationView(selectedTab: $selectedTab)
                }
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        CharacterSelectionView()
    }
}

struct StarView: View {
    var body: some View {
        LeaderboardView()
    }
}

struct ProfileView: View {
    @ObservedObject private var userService = UserService.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showEditProfile = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text(localizationManager.localizedString("profile"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // Profile Content
                VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                    // Avatar - using selected avatar from UserService
                    if !userService.selectedAvatar.isEmpty {
                        Image(userService.selectedAvatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: horizontalSizeClass == .regular ? 200 : 150,
                                height: horizontalSizeClass == .regular ? 200 : 150
                            )
                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 35 : 25))
                            
                         
                        
                    } else {
                        // Default avatar if none selected
                        RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 35 : 25)
                            .fill(Color.gray.opacity(0.5))
                            .frame(
                                width: horizontalSizeClass == .regular ? 200 : 150,
                                height: horizontalSizeClass == .regular ? 200 : 150
                            )
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: horizontalSizeClass == .regular ? 80 : 60))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 35 : 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.orange, Color.yellow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: horizontalSizeClass == .regular ? 6 : 4
                                    )
                            )
                    }
                    
                    // Username - using username from UserService
                    Text(userService.username.isEmpty ? localizationManager.localizedString("no_nickname_set") : userService.username)
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 40 : 32,
                            weight: .bold
                        ))
                        .foregroundColor(.white)
                    
                    // Stars count - using real stars from UserService
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#D29B43"))
                            .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                        
                        Text("\(userService.totalStars) \(localizationManager.localizedString("stars"))")
                            .font(.system(
                                size: horizontalSizeClass == .regular ? 22 : 18,
                                weight: .semibold
                            ))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 24)
                    .padding(.vertical, horizontalSizeClass == .regular ? 16 : 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.62)
                    )
                }
                
                Spacer()
                Spacer() // Extra spacer to push button lower
                
                // Edit Button
                Button(action: {
                    showEditProfile = true
                }) {
                    Text(localizationManager.localizedString("edit"))
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 20 : 18,
                            weight: .semibold
                        ))
                        .foregroundColor(.white)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                        .frame(height: horizontalSizeClass == .regular ? 64 : 56)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 32 : 28)
                                .stroke(Color(hex: "#7328CF"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(userService: userService)
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var userService = UserService.shared
    @State private var showResetAlert = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text(localizationManager.localizedString("settings"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                
                VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                    // Language Section
                    HStack {
                        Text(localizationManager.localizedString("language"))
                            .font(.system(
                                size: horizontalSizeClass == .regular ? 22 : 18,
                                weight: .medium
                            ))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            // English Button
                            Button(action: {
                                localizationManager.currentLanguage = "English"
                            }) {
                                Text(localizationManager.localizedString("english"))
                                    .font(.system(
                                        size: horizontalSizeClass == .regular ? 18 : 16,
                                        weight: .medium
                                    ))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)
                                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(localizationManager.currentLanguage == "English" ? Color(hex: "#7328CF") : Color.clear)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Arabic Button
                            Button(action: {
                                localizationManager.currentLanguage = "Arabic"
                            }) {
                                Text(localizationManager.localizedString("arabic"))
                                    .font(.system(
                                        size: horizontalSizeClass == .regular ? 18 : 16,
                                        weight: .medium
                                    ))
                                    .foregroundColor(localizationManager.currentLanguage == "Arabic" ? .white : .white.opacity(0.6))
                                    .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)
                                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(localizationManager.currentLanguage == "Arabic" ? Color(hex: "#7328CF") : Color.clear)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#7328CF"), lineWidth: 3)
                        )
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? 60 : 40)
                    
                    // Action Buttons Section
                    VStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                        if horizontalSizeClass == .regular {
                            // iPad layout - single row with more space
                            HStack(spacing: 30) {
                                // Privacy Policy Button
                                Button(action: {
                                    if let url = URL(string: "https://v0-next-js-shadcn-ui-app-jade.vercel.app/privacy-policy") {
                                        UIApplication.shared.open(url)
                                        print("🔗 SettingsView: Opening Privacy Policy URL")
                                    }
                                }) {
                                    Text(localizationManager.localizedString("privacy_policy"))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(hex: "#7328CF"), lineWidth: 3)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Contact Us Button
                                Button(action: {
                                    if let url = URL(string: "https://v0-next-js-shadcn-ui-app-jade.vercel.app/feedback-form") {
                                        UIApplication.shared.open(url)
                                        print("🔗 SettingsView: Opening Contact Us URL")
                                    }
                                }) {
                                    Text(localizationManager.localizedString("contact_us"))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(hex: "#7328CF"), lineWidth: 3)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 80)
                        } else {
                            // iPhone layout - keep existing
                            HStack(spacing: 15) {
                                // Privacy Policy Button
                                Button(action: {
                                    if let url = URL(string: "https://v0-next-js-shadcn-ui-app-jade.vercel.app/privacy-policy") {
                                        UIApplication.shared.open(url)
                                        print("🔗 SettingsView: Opening Privacy Policy URL")
                                    }
                                }) {
                                    Text(localizationManager.localizedString("privacy_policy"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(hex: "#7328CF"), lineWidth: 3)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Contact Us Button
                                Button(action: {
                                    if let url = URL(string: "https://v0-next-js-shadcn-ui-app-jade.vercel.app/feedback-form") {
                                        UIApplication.shared.open(url)
                                        print("🔗 SettingsView: Opening Contact Us URL")
                                    }
                                }) {
                                    Text(localizationManager.localizedString("contact_us"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(hex: "#7328CF"), lineWidth: 3)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                }
                
                Spacer()
                Spacer() // Extra spacer to push button lower
                
                // Reset Progress Button
                Button(action: {
                    showResetAlert = true
                }) {
                    Text(localizationManager.localizedString("reset_progress"))
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 20 : 18,
                            weight: .semibold
                        ))
                        .foregroundColor(.white)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                        .frame(height: horizontalSizeClass == .regular ? 64 : 56)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(horizontalSizeClass == .regular ? 32 : 28)
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                .padding(.bottom, 20) // Increased bottom padding
            }
        }
        .alert("Progress Reset", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                print("🔄 SettingsView: Reset Progress confirmed")
                userService.resetProgress()
                print("🔄 SettingsView: Progress reset completed")
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This will reset your stars to 0.")
        }
    }
}

struct EditProfileSheet: View {
    @ObservedObject var userService: UserService
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedAvatar: String = ""
    @State private var nickname: String = ""
    @State private var showError: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    let avatars = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            // iPad - 4 columns
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        } else {
            // iPhone - 3 columns
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(localizationManager.localizedString("Cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(localizationManager.localizedString("Edit Profile"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(localizationManager.localizedString("Save")) {
                        saveProfile()
                    }
                    .foregroundColor(canSave ? .white : .white.opacity(0.5))
                    .disabled(!canSave)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Avatar Selection
                        VStack(spacing: 20) {
                            Text(localizationManager.localizedString("Choose Avatar"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(avatars, id: \.self) { avatar in
                                    EditAvatarOption(
                                        avatar: avatar,
                                        isSelected: selectedAvatar == avatar,
                                        showError: showError && selectedAvatar.isEmpty
                                    ) {
                                        selectedAvatar = avatar
                                        showError = false
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Nickname Input
                        VStack(spacing: 15) {
                            Text(localizationManager.localizedString("Nickname"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            TextField(localizationManager.localizedString("Enter your nickname"), text: $nickname)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            showError && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                            ? Color.red : Color.white.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(12)
                                .padding(.horizontal, 30)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            selectedAvatar = userService.selectedAvatar
            nickname = userService.username
        }
    }
    
    private var canSave: Bool {
        !selectedAvatar.isEmpty && !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveProfile() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedAvatar.isEmpty || trimmedNickname.isEmpty {
            showError = true
            return
        }
        
        userService.setAvatar(selectedAvatar)
        userService.setUsername(trimmedNickname)
        
        print("✅ Profile saved successfully!")
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditAvatarOption: View {
    let avatar: String
    let isSelected: Bool
    let showError: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(avatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            isSelected 
                            ? LinearGradient(colors: [Color.orange, Color.yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [showError ? Color.red : Color.white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 4 : 2
                        )
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SideNavigationView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // App logo/title area
            VStack(spacing: 10) {
                Text("Maza Fil Jiwar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Navigation buttons
            VStack(spacing: 20) {
                SideNavigationButton(
                    icon: "home",
                    label: "Home",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                SideNavigationButton(
                    icon: "star",
                    label: "Leaderboard",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                SideNavigationButton(
                    icon: "profile",
                    label: "Profile",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
                
                SideNavigationButton(
                    icon: "settings",
                    label: "Settings",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(Color(hex: "#7328CF"))
        )
    }
}

struct SideNavigationButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1.0 : 0.6)
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1.0 : 0.6)
                
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.black.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
