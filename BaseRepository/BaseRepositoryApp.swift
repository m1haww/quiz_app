//
//  BaseRepositoryApp.swift
//  BaseRepository
//

import SwiftUI
import PostHog

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

@main
struct BaseRepositoryApp: App {
    @State private var hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @StateObject private var offerManager = OfferWebViewManager.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let config = PostHogConfig(
            apiKey: Config.posthogApiKey,
            host: Config.posthogHost
        )
        PostHogSDK.shared.setup(config)
        
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        PostHogSDK.shared.identify(idfv)
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .onAppear {
                        Task {
                            print("🌐 BaseRepositoryApp: Starting webview resolve...")
                            await OfferWebViewManager.shared.resolveAndOpenWebView()
                            print("🌐 BaseRepositoryApp: Webview resolve completed")
                        }
                    }
            } else {
                OnboardingView()
                    .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                        hasSeenOnboarding = true
                    }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                // App became active (foreground)
                SessionManager.shared.startAppSession()
            case .background:
                // App went to background
                SessionManager.shared.endAppSession()
            case .inactive:
                // App is transitioning (e.g., during interruptions)
                break
            @unknown default:
                break
            }
        }
    }
}
