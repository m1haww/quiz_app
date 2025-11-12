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
        // Enable automatic event logging and advertiser tracking
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

        // IMPORTANT: Defer Branch initialization until AFTER ATT prompt
        // This ensures IDFA is available for TikTok attribution
        // Branch will be initialized in TrackingManager.requestPermission()
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
