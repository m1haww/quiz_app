//
//  TrackingStatus.swift
//  BaseRepository
//
//

import Foundation
import AppTrackingTransparency
import AdSupport
import PostHog

final class TrackingManager {
    static let shared = TrackingManager()
    private init() {}
    
    private let key = "trackingStatus"
    private let zeroUUID = "00000000-0000-0000-0000-000000000000"
    
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

                Task {
                    await OfferWebViewManager.shared.resolveOffer()
                }
            }
        }
    }
}
