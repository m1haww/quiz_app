//
//  SessionManager.swift
//  BaseRepository
//

import Foundation
import PostHog

final class SessionManager {
    static let shared = SessionManager()
    private init() {}
    
    // App session tracking
    private var appSessionStartTime: Date?
    private var cumulativeAppTime: TimeInterval = 0
    
    // WebView session tracking (nested within app session)
    private var webViewSessionStartTime: Date?
    private var cumulativeWebViewTime: TimeInterval = 0
    private var webViewWasPausedByBackground: Bool = false
    private var pausedWebViewURL: String?
    
    // MARK: - App Session Tracking
    
    /// Called when app enters foreground
    func startAppSession() {
        appSessionStartTime = Date()
        PostHogSDK.shared.capture("app_session_start")
        
        // Resume webview session if it was paused by backgrounding
        if webViewWasPausedByBackground, let url = pausedWebViewURL {
            resumeWebViewSession(url: url)
        }
    }
    
    /// Called when app enters background
    func endAppSession() {
        guard let startTime = appSessionStartTime else { return }
        
        // If webview session is active, pause it first
        let wasWebViewActive = webViewSessionStartTime != nil
        if wasWebViewActive {
            pauseWebViewSession()
        }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        cumulativeAppTime += sessionDuration
        
        PostHogSDK.shared.capture("app_session_end", properties: [
            "session_duration_seconds": sessionDuration,
            "session_duration_minutes": sessionDuration / 60,
            "cumulative_app_time_seconds": cumulativeAppTime,
            "cumulative_webview_time_seconds": cumulativeWebViewTime,
            "webview_was_active": wasWebViewActive
        ])
        
        appSessionStartTime = nil
    }
    
    /// Get current app session duration (if active)
    var currentAppSessionDuration: TimeInterval? {
        guard let startTime = appSessionStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - WebView Session Tracking
    
    /// Internal: Pause webview session when app backgrounds (stores state for resume)
    private func pauseWebViewSession() {
        guard let startTime = webViewSessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        cumulativeWebViewTime += sessionDuration
        
        PostHogSDK.shared.capture("webview_session_paused", properties: [
            "session_duration_seconds": sessionDuration,
            "reason": "app_backgrounded"
        ])
        
        webViewWasPausedByBackground = true
        webViewSessionStartTime = nil
    }
    
    /// Internal: Resume webview session when app foregrounds (if it was paused)
    private func resumeWebViewSession(url: String) {
        webViewSessionStartTime = Date()
        webViewWasPausedByBackground = false
        pausedWebViewURL = nil
        
        PostHogSDK.shared.capture("webview_session_resumed", properties: [
            "url": url
        ])
    }
    
    /// Called when webview opens
    func startWebViewSession(url: String) {
        webViewSessionStartTime = Date()
        pausedWebViewURL = url // Store for potential pause/resume
        webViewWasPausedByBackground = false
        
        PostHogSDK.shared.capture("webview_session_start", properties: [
            "url": url,
            "app_session_duration_at_open": currentAppSessionDuration ?? 0
        ])
    }
    
    /// Called when webview closes
    func endWebViewSession() {
        guard let startTime = webViewSessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        cumulativeWebViewTime += sessionDuration
        
        PostHogSDK.shared.capture("webview_session_end", properties: [
            "session_duration_seconds": sessionDuration,
            "session_duration_minutes": sessionDuration / 60,
            "cumulative_webview_time_seconds": cumulativeWebViewTime,
            "app_session_duration": currentAppSessionDuration ?? 0
        ])
        
        // Clear all webview state
        webViewSessionStartTime = nil
        webViewWasPausedByBackground = false
        pausedWebViewURL = nil
    }
    
    /// Get current webview session duration (if active)
    var currentWebViewSessionDuration: TimeInterval? {
        guard let startTime = webViewSessionStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
}

