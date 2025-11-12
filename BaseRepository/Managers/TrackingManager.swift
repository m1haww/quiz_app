//
//  TrackingStatus.swift
//  BaseRepository
//
//

import Foundation
import AppTrackingTransparency
import AdSupport
import PostHog
import BranchSDK
import FacebookCore

final class TrackingManager {
    static let shared = TrackingManager()
    private init() {}
    
    private let key = "trackingStatus"
    private let zeroUUID = "00000000-0000-0000-0000-000000000000"
    private var branchInitialized = false
    
    var currentStatus: TrackingStatus {
        let raw = UserDefaults.standard.string(forKey: key) ?? "notDetermined"
        return TrackingStatus(rawValue: raw) ?? .unknown
    }
    
    func requestPermission() {
        let currentATTStatus = ATTrackingManager.trackingAuthorizationStatus
        let wasAlreadyDetermined = currentATTStatus != .notDetermined
        
        PostHogSDK.shared.capture("request_tracking_permission", properties: [
            "already_determined": wasAlreadyDetermined,
            "current_status": currentATTStatus.rawValue
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                let result: TrackingStatus
                
                switch status {
                case .authorized: result = .authorized
                case .denied: result = .denied
                case .restricted: result  = .restricted
                case .notDetermined: result = .notDetermined
                @unknown default: result = .unknown
                }

                PostHogSDK.shared.capture("request_tracking_permission_result", properties: [
                    "result": result.rawValue,
                    "dialog_shown": !wasAlreadyDetermined
                ])
                
                if result == .authorized {
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    if idfa != self.zeroUUID {
                        PostHogSDK.shared.identify(idfa)
                    }
                }
                
                UserDefaults.standard.set(result.rawValue, forKey: self.key)
                
                // Initialize Branch AFTER ATT prompt completes
                // This is critical for TikTok attribution - IDFA must be available
                self.initializeBranch()
            }
        }
    }
    
    private func initializeBranch() {
        guard !branchInitialized else { return }
        branchInitialized = true
        
        // Wait a moment for IDFA to be fully available
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Branch.getInstance().initSession(launchOptions: LaunchStore.launchOptions) { params, error in
                print("Branch init params: \(params as? [String: AnyObject] ?? [:])")
                
                // Log install event to Facebook when Branch session initializes
                // This is critical for Facebook and TikTok attribution
                if let params = params as? [String: AnyObject] {
                    // Check if this is a first install
                    if let isFirstSession = params["+is_first_session"] as? Bool, isFirstSession {
                        // Log install event for Facebook attribution
                        // This helps Facebook and TikTok match installs with IDFA available
                        AppEvents.shared.logEvent(.achievedLevel)
                        
                        // Log additional attribution data from Branch
                        var eventParams: [AppEvents.ParameterName: Any] = [:]
                        
                        if let campaign = params["~campaign"] as? String {
                            eventParams[.init("campaign")] = campaign
                        }
                        if let channel = params["~channel"] as? String {
                            eventParams[.init("channel")] = channel
                        }
                        
                        if !eventParams.isEmpty {
                            AppEvents.shared.logEvent(.viewedContent, parameters: eventParams)
                        }
                    }
                }
            }
        }
    }
}
