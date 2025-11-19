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
    
    var body: some View {
        ZStack {
            // Background Image
            Image("onbarding")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Dark overlay for better text readability
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
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
                
                // Continue Button
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
                .padding(.bottom, 60)
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
