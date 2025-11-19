import Foundation

class UserService: ObservableObject {
    static let shared = UserService()
    
    @Published var selectedAvatar: String = ""
    @Published var username: String = ""
    @Published var totalStars: Int = 0
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadUserData()
    }
    
    // MARK: - Avatar Management
    func setAvatar(_ avatar: String) {
        print("🔵 UserService: Setting avatar to '\(avatar)'")
        selectedAvatar = avatar
        userDefaults.set(avatar, forKey: "selectedAvatar")
        print("🔵 UserService: Avatar saved to UserDefaults: '\(avatar)'")
    }
    
    func hasSelectedAvatar() -> Bool {
        return !selectedAvatar.isEmpty
    }
    
    // MARK: - Username Management
    func setUsername(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🟢 UserService: Setting username to '\(trimmedName)'")
        username = trimmedName
        userDefaults.set(username, forKey: "username")
        print("🟢 UserService: Username saved to UserDefaults: '\(username)'")
    }
    
    func hasValidUsername() -> Bool {
        return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Stars Management
    func addStars(_ stars: Int) {
        let oldStars = totalStars
        totalStars += stars
        userDefaults.set(totalStars, forKey: "totalStars")
        print("⭐ UserService: Added \(stars) stars. Old: \(oldStars), New: \(totalStars)")
    }
    
    func resetProgress() {
        let oldStars = totalStars
        totalStars = 0
        userDefaults.set(totalStars, forKey: "totalStars")
        print("🔄 UserService: Reset progress - Stars changed from \(oldStars) to \(totalStars)")
        // TODO: Reset character progress when needed
    }
    
    // MARK: - Data Persistence
    private func loadUserData() {
        selectedAvatar = userDefaults.string(forKey: "selectedAvatar") ?? ""
        username = userDefaults.string(forKey: "username") ?? ""
        totalStars = userDefaults.integer(forKey: "totalStars")
        
        print("📱 UserService: Loading user data from UserDefaults:")
        print("   - Avatar: '\(selectedAvatar)'")
        print("   - Username: '\(username)'") 
        print("   - Total Stars: \(totalStars)")
    }
    
    func saveUserData() {
        userDefaults.set(selectedAvatar, forKey: "selectedAvatar")
        userDefaults.set(username, forKey: "username")
        userDefaults.set(totalStars, forKey: "totalStars")
        print("💾 UserService: Manual save called - all data saved to UserDefaults")
    }
}