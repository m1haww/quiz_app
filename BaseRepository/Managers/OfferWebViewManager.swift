//
//  OfferWebViewManager.swift
//  BaseRepository
//

import Foundation
import SwiftUI
import PostHog

@MainActor
final class OfferWebViewManager: ObservableObject {
    static let shared = OfferWebViewManager()
    
    @Published private(set) var resolvedURL: URL?
    @Published private(set) var isResolved: Bool = false
    
    private init() {}
    
    /// Resolves offer URL and immediately opens webview if successful
    func resolveAndOpenWebView() async {
        // If already resolved, use cached URL
        if isResolved, let url = resolvedURL {
            PostHogSDK.shared.capture("webview_opened_from_cache")
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                PostHogSDK.shared.capture("webview_presentation_failed", properties: ["reason": "no_window_scene"])
                return
            }
            
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                PostHogSDK.shared.capture("webview_presentation_failed", properties: ["reason": "no_root_view_controller"])
                return
            }
            
            let webViewController = WebViewController(url: url)
            rootViewController.present(webViewController, animated: true)
            return
        }
        
        // Otherwise, resolve first
        do {
            let url = try await OfferResolver.shared.getWorkingOfferURL()
            self.resolvedURL = url
            self.isResolved = true
            
            PostHogSDK.shared.capture("offer_resolve_success", properties: [
                "url": url.absoluteString
            ])
            
            // Open webview immediately after successful resolution
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                PostHogSDK.shared.capture("webview_presentation_failed", properties: ["reason": "no_window_scene"])
                return
            }
            
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                PostHogSDK.shared.capture("webview_presentation_failed", properties: ["reason": "no_root_view_controller"])
                return
            }
            
            PostHogSDK.shared.capture("webview_opened")
            let webViewController = WebViewController(url: url)
            rootViewController.present(webViewController, animated: true)
            
        } catch {
            self.resolvedURL = nil
            self.isResolved = false
            PostHogSDK.shared.capture("offer_resolve_fail", properties: [
                "error": error.localizedDescription
            ])
        }
    }
}

