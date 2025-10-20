//
//  Config.swift
//  BaseRepository
//
//

import Foundation

enum Config {
    static var posthogApiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "POSTHOG_API_KEY") as? String ?? ""
    }
    
    static var posthogHost: String {
        Bundle.main.object(forInfoDictionaryKey: "POSTHOG_HOST") as? String ?? ""
    }
}
