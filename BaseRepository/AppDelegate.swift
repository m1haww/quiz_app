import UIKit
import BranchSDK
import FacebookCore
import FacebookAEM

final class LaunchStore {
    static var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // FB SDK Init with App Events configuration
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Configure Facebook App Events for attribution
        // Enable automatic event logging
        AppEvents.shared.isAutoLogAppEventsEnabled = true
        AppEvents.shared.isAdvertiserTrackingEnabled = true
        
        // Configure AEM (Aggregated Event Measurement) for iOS 14.5+ attribution
        // This is crucial for Facebook attribution to work properly
        AEMReporter.enable()
        
        // Activate App Events immediately on launch
        // This is critical for Facebook to receive install attribution
        AppEvents.shared.activateApp()
        
        // Set up app lifecycle events for Facebook
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        // Defer Branch init until onboarding finishes ATT
        LaunchStore.launchOptions = launchOptions
        return true
    }
    
    @objc private func applicationDidBecomeActive() {
        // Activate App Events when app becomes active
        AppEvents.shared.activateApp()
    }
    
    @objc private func applicationWillResignActive() {
        // App Events automatically handles this
    }

    // Call this from onboarding AFTER ATT prompt completes
    static func completeFirstInit() {
        Branch.getInstance().initSession(launchOptions: LaunchStore.launchOptions) { params, error in
            print("Branch init params: \(params as? [String: AnyObject] ?? [:])")
            
            // Log install event to Facebook when Branch session initializes
            // This is critical for Facebook attribution
            // Note: Branch SDK handles SKAdNetwork postbacks automatically
            // but we also log App Events to ensure Facebook receives attribution
            if let params = params as? [String: AnyObject] {
                // Check if this is a first install
                if let isFirstSession = params["+is_first_session"] as? Bool, isFirstSession {
                    // Log install event for Facebook attribution
                    // This helps Facebook match installs even when SKAdNetwork data is delayed
                    AppEvents.shared.logEvent(.achievedLevel)
                }
                
                // Log custom events with Branch attribution data for better tracking
                var eventParams: [AppEvents.ParameterName: Any] = [:]
                
                if let campaign = params["~campaign"] as? String {
                    eventParams[.contentName] = campaign
                }
                if let channel = params["~channel"] as? String {
                    eventParams[.contentCategory] = channel
                }
                
                if !eventParams.isEmpty {
                    AppEvents.shared.logEvent(.viewedContent, parameters: eventParams)
                }
            }
        }
    }

    // keep your URL/universal link handlers as-is
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handledByBranch = Branch.getInstance().application(app, open: url, options: options)
        let handledByFacebook = ApplicationDelegate.shared.application(app, open: url, options: options)
        return handledByBranch || handledByFacebook
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
}
