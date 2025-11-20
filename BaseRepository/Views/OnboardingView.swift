//
//  OnboardingView.swift
//  quiz app
//
//  Created by Mihail Ozun on 18.11.2025.
//

import SwiftUI


struct OnboardingView: View {
    @State private var showNicknameView = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Background - force full screen coverage
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#351162"), Color(hex: "#7328CF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(.all)
            
            // Background Image overlay
            Image("onbarding")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
                .opacity(0.8)
            
            // Dark overlay for better text readability
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
            
            if horizontalSizeClass == .regular {
                // iPad layout - scroll normal
                ScrollView {
                    VStack(spacing: 50) {
                        Spacer()
                            .frame(height: 150)
                        
                        // Main Title
                        Text("Maza Fil Jiwar")
                            .font(.system(size: 72, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                        
                        // Subtitle
                        Text(localizationManager.localizedString("find_out_who_lives"))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 80)
                            .lineLimit(nil)
                        
                        Spacer()
                            .frame(height: 200)
                        
                        // Continue Button inside scroll
                        Button(action: {
                            print("🌐 OnboardingView: Continue pressed, current language: \(localizationManager.currentLanguage)")
                            showNicknameView = true
                        }) {
                            Text(localizationManager.localizedString("continue"))
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 500)
                                .frame(height: 68)
                                .background(Color(hex: "#7328CF"))
                                .cornerRadius(34)
                        }
                        .padding(.horizontal, 100)
                        .padding(.bottom, 80)
                    }
                }
            } else {
                // iPhone layout - buton în jos cu Spacer
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Main Title
                    Text("Maza Fil Jiwar")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    // Subtitle
                    Text(localizationManager.localizedString("find_out_who_lives"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineLimit(nil)
                    
                    Spacer()
                    
                    // Continue Button la baza ecranului
                    Button(action: {
                        print("🌐 OnboardingView: Continue pressed, current language: \(localizationManager.currentLanguage)")
                        showNicknameView = true
                    }) {
                        Text(localizationManager.localizedString("continue"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#7328CF"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showNicknameView) {
            NicknameView()
        }
    }
}

#Preview {
    OnboardingView()
}
