//
//  NicknameView.swift
//  quiz app
//
//  Created by Mihail Ozun on 18.11.2025.
//

import SwiftUI

struct NicknameView: View {
    @State private var nickname: String = ""
    @State private var showError: Bool = false
    @State private var showAvatarView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject private var userService = UserService.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "#351162")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 80 : 40)
                    
                    VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 25 : 15) {
                        // Enter nickname text
                        HStack {
                            Text(localizationManager.localizedString("enter_your_nickname"))
                                .font(.system(
                                    size: horizontalSizeClass == .regular ? 22 : 17, 
                                    weight: .medium
                                ))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                        
                        // Nickname input field
                        TextField("", text: $nickname)
                            .placeholder(when: nickname.isEmpty) {
                                Text(localizationManager.localizedString("nickname"))
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                            }
                            .font(.system(size: horizontalSizeClass == .regular ? 22 : 18))
                            .foregroundColor(.white)
                            .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 24)
                            .padding(.vertical, horizontalSizeClass == .regular ? 28 : 20)
                            .background(
                                RoundedRectangle(cornerRadius: 49)
                                    .stroke(showError ? Color.red : Color.white.opacity(0.4), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.clear)
                                    )
                            )
                            .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                            .onChange(of: nickname) { _ in
                                if showError {
                                    showError = false
                                }
                            }
                        
                        // Error message
                        if showError {
                            HStack {
                                Text(localizationManager.localizedString("please_enter_nickname"))
                                    .font(.system(size: horizontalSizeClass == .regular ? 18 : 14))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                        }
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedNickname.isEmpty {
                            showError = true
                        } else {
                            // Save nickname to UserService
                            userService.setUsername(trimmedNickname)
                            print("📝 NicknameView: Saved nickname '\(trimmedNickname)' to UserService")
                            showAvatarView = true
                        }
                    }) {
                        Text(localizationManager.localizedString("continue"))
                            .font(.system(
                                size: horizontalSizeClass == .regular ? 22 : 18, 
                                weight: .semibold
                            ))
                            .foregroundColor(.white)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 500 : .infinity)
                            .frame(height: horizontalSizeClass == .regular ? 68 : 56)
                            .background(Color(hex: "#7328CF"))
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
        .fullScreenCover(isPresented: $showAvatarView) {
            AvatarSelectionView()
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


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct NicknameView_Previews: PreviewProvider {
    static var previews: some View {
        NicknameView()
    }
}
