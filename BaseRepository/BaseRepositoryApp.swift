//
//  BaseRepositoryApp.swift
//  BaseRepository
//

import SwiftUI
import PostHog

@main
struct BaseRepositoryApp: App {
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
            Text("Hello, World!")
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
