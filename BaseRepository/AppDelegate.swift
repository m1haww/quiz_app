import UIKit
import BranchSDK
import FacebookCore

final class LaunchStore {
    static var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // FB SDK Init (unchanged)
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Defer Branch init until onboarding finishes ATT
        LaunchStore.launchOptions = launchOptions
        return true
    }

    // Called automatically by TrackingManager after ATT prompt completes
    static func completeFirstInit() {
        Branch.getInstance().initSession(launchOptions: LaunchStore.launchOptions) { params, error in
            print(params as? [String: AnyObject] ?? [:])
        }
    }

    // keep your URL/universal link handlers as-is
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
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
