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
    
    /// Resolves the offer URL via OfferResolver
    /// If successful, stores the state so webview can be opened
    func resolveOffer() async {
        do {
            let url = try await OfferResolver.shared.getWorkingOfferURL()
            self.resolvedURL = url
            self.isResolved = true
            PostHogSDK.shared.capture("offer_resolve_success", properties: [
                "url": url.absoluteString
            ])
        } catch {
            self.resolvedURL = nil
            self.isResolved = false
            PostHogSDK.shared.capture("offer_resolve_fail", properties: [
                "error": error.localizedDescription
            ])
        }
    }
    
    /// Opens the webview if offer was successfully resolved, ignores if not
    func
    () {
        guard isResolved, let url = resolvedURL else {
            PostHogSDK.shared.capture("webview_blocked") 
            return
        }

        PostHogSDK.shared.capture("webview_opened")
        
        // Present the webview
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            let webViewController = WebViewController(url: url)
            rootViewController.present(webViewController, animated: true)
        }
    }
}

