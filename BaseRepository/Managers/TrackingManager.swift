//
//  TrackingStatus.swift
//  BaseRepository
//
//

import Foundation
import AppTrackingTransparency
import PostHog

final class TrackingManager {
    static let shared = TrackingManager()
    private init() {}
    
    private let key = "trackingStatus"
    
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
                
                UserDefaults.standard.set(result.rawValue, forKey: self.key)
            }
        }
    }
}
