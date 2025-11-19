import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
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
                VStack(spacing: 30) {
                    // Avatar - using selected avatar from UserService
                    if !userService.selectedAvatar.isEmpty {
                        Image(userService.selectedAvatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                         
                        
                    } else {
                        // Default avatar if none selected
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 60))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.orange, Color.yellow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                    }
                    
                    // Username - using username from UserService
                    Text(userService.username.isEmpty ? localizationManager.localizedString("no_nickname_set") : userService.username)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Stars count - using real stars from UserService
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#D29B43"))
                            .font(.system(size: 20))
                        
                        Text("\(userService.totalStars) \(localizationManager.localizedString("stars"))")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
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
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(hex: "#7328CF"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 40)
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
                
                VStack(spacing: 30) {
                    // Language Section
                    HStack {
                        Text(localizationManager.localizedString("language"))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            // English Button
                            Button(action: {
                                localizationManager.currentLanguage = "English"
                            }) {
                                Text(localizationManager.localizedString("english"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
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
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(localizationManager.currentLanguage == "Arabic" ? .white : .white.opacity(0.6))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
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
                    .padding(.horizontal, 40)
                    
                    // Action Buttons Section
                    VStack(spacing: 15) {
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
                
                Spacer()
                Spacer() // Extra spacer to push button lower
                
                // Reset Progress Button
                Button(action: {
                    showResetAlert = true
                }) {
                    Text(localizationManager.localizedString("reset_progress"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 40)
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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
