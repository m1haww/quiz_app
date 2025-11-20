//
//  AvatarSelectionView.swift
//  quiz app
//
//  Created by Mihail Ozun on 18.11.2025.
//

import SwiftUI

struct AvatarSelectionView: View {
    @State private var selectedAvatarIndex: Int? = nil
    @State private var showMainTabView = false
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject private var userService = UserService.shared
    
    let avatarImages = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "#351162")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 80 : 40)
                    
                    VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 40 : 30) {
                        // Choose your avatar text
                        HStack {
                            Text("Choose your avatar")
                                .font(.system(
                                    size: horizontalSizeClass == .regular ? 22 : 17, 
                                    weight: .medium
                                ))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                        
                        // Avatar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: horizontalSizeClass == .regular ? 30 : 20), count: horizontalSizeClass == .regular ? 4 : 3), spacing: horizontalSizeClass == .regular ? 30 : 20) {
                            ForEach(0..<avatarImages.count, id: \.self) { index in
                                Button(action: {
                                    selectedAvatarIndex = index
                                }) {
                                    ZStack {
                                        // Avatar image
                                        Image(avatarImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: horizontalSizeClass == .regular ? 100 : 80, 
                                                height: horizontalSizeClass == .regular ? 100 : 80
                                            )
                                            .clipShape(Circle())
                                        
                                        // Border
                                        Circle()
                                            .stroke(
                                                selectedAvatarIndex == index ? 
                                                Color(hex: "#7328CF") : Color(hex: "#FFD700"),
                                                lineWidth: horizontalSizeClass == .regular ? 4 : 3
                                            )
                                            .frame(
                                                width: horizontalSizeClass == .regular ? 108 : 86, 
                                                height: horizontalSizeClass == .regular ? 108 : 86
                                            )
                                        
                                        // Icon for selected avatar
                                        if selectedAvatarIndex == index {
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image("icon")
                                                        .resizable()
                                                        .frame(
                                                            width: horizontalSizeClass == .regular ? 30 : 24, 
                                                            height: horizontalSizeClass == .regular ? 30 : 24
                                                        )
                                                        .offset(
                                                            x: horizontalSizeClass == .regular ? 10 : 8, 
                                                            y: horizontalSizeClass == .regular ? 10 : 8
                                                        )
                                                }
                                            }
                                            .frame(
                                                width: horizontalSizeClass == .regular ? 100 : 80, 
                                                height: horizontalSizeClass == .regular ? 100 : 80
                                            )
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                    }
                    
                    // Error message
                    if showError && selectedAvatarIndex == nil {
                        HStack {
                            Text("Please select an avatar to continue")
                                .font(.system(size: horizontalSizeClass == .regular ? 18 : 14))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        if let selectedIndex = selectedAvatarIndex {
                            let selectedAvatar = avatarImages[selectedIndex]
                            userService.setAvatar(selectedAvatar)
                            print("🖼️ AvatarSelectionView: Saved avatar '\(selectedAvatar)' to UserService")
                            
                            // Mark onboarding as completed
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            print("✅ AvatarSelectionView: Onboarding completed, setting flag to true")
                            
                            // Request tracking permission at the end of onboarding
                            TrackingManager.shared.requestPermission()
                            
                            // Post notification to update BaseRepositoryApp
                            NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                            
                            showMainTabView = true
                        } else {
                            showError = true
                            print("❌ AvatarSelectionView: No avatar selected, showing error")
                        }
                    }) {
                        Text("Continue")
                            .font(.system(
                                size: horizontalSizeClass == .regular ? 22 : 18, 
                                weight: .semibold
                            ))
                            .foregroundColor(.white)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 500 : .infinity)
                            .frame(height: horizontalSizeClass == .regular ? 68 : 56)
                            .background(
                                showError && selectedAvatarIndex == nil 
                                ? Color.red 
                                : Color(hex: "#7328CF")
                            )
                            .cornerRadius(horizontalSizeClass == .regular ? 34 : 28)
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? 100 : 40)
                    .padding(.bottom, horizontalSizeClass == .regular ? 80 : 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Maza Fil Jiwar")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                setupNavigationBarAppearance()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showMainTabView) {
            MainTabView()
        }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "#351162"))
        appearance.shadowColor = UIColor.clear
        appearance.shadowImage = UIImage()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

struct AvatarSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarSelectionView()
    }
}