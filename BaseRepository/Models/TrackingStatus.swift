//
//  TrackingStatus.swift
//  BaseRepository
//

import Foundation

enum TrackingStatus: String {
    // authorized - user granted permission
    // denied - user denied permission
    // restricted - user can't grant permission at all (e.g., child account, MDM/profile restrictions)
    // notDetermined - prompt hasn't been shown yet
    // unknown - fallback
    case authorized, denied, restricted, notDetermined, unknown
}
