import Foundation
import UIKit
import AdSupport

enum OfferResolveError: Error {
    case apiNotFound
    case apiBadStatus(Int)
    case decodeFailed
    case invalidOfferURL
    case tooManyRedirects
    case finalBadStatus(Int)
}

struct OfferDTO: Codable { let url: String }

actor OfferResolver {
    static let shared = OfferResolver()
    var apiBase = URL(string: "https://applink-infra-api-production.up.railway.app")!

    // 1) Get offer JSON
    func fetchOffer() async throws -> String {
        let path = "/api/v1/offers/ios/\(Bundle.main.bundleIdentifier ?? "")"
    
        guard let endpoint = URL(string: path, relativeTo: apiBase) else {
            throw OfferResolveError.invalidOfferURL
        }

        let (data, resp) = try await URLSession.shared.data(from: endpoint)
        guard let http = resp as? HTTPURLResponse else {
            throw OfferResolveError.decodeFailed
        }
        
        switch http.statusCode {
        case 200...299:
            break
        case 404:
            throw OfferResolveError.apiNotFound
        default:
            throw OfferResolveError.apiBadStatus(http.statusCode)
        }

        let dto = try JSONDecoder().decode(OfferDTO.self, from: data)
        
        // Return the original string (not URL) to preserve placeholders like {t1}
        return dto.url
    }

    // 2) Append params and resolve redirects
    func resolveFinalURL(from urlString: String) async throws -> URL {
        let urlWithParams = try await appendParams(from: urlString)
        
        var req = URLRequest(url: urlWithParams)
        req.httpMethod = "HEAD" // avoid downloading large body
        
        let (_, response) = try await URLSession.shared.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // You're already at the end of the redirect chain
        guard (200...299).contains(http.statusCode) else {
            throw URLError(.init(rawValue: http.statusCode))
        }

        return http.url ?? urlWithParams
    }
    
    func appendParams(from urlString: String) async throws -> URL {
        var identifier: String
        var identifierType: String
        
        let trackingStatus = TrackingManager.shared.currentStatus
        
        if trackingStatus == .authorized {
            let idfa = ASIdentifierManager.shared().advertisingIdentifier
            if idfa != UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                identifier = idfa.uuidString
                identifierType = "idfa"
            } else {
                identifier = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
                identifierType = "idfv"
            }
        } else {
            identifier = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            identifierType = "idfv"
        }
        
        let platform = "ios"
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        
        // Replace placeholders in the original string (before URL encoding)
        var finalUrlString = urlString
        finalUrlString = finalUrlString.replacingOccurrences(of: "{t1}", with: identifier)
        finalUrlString = finalUrlString.replacingOccurrences(of: "{t2}", with: platform)
        finalUrlString = finalUrlString.replacingOccurrences(of: "{t3}", with: bundleId)
        finalUrlString = finalUrlString.replacingOccurrences(of: "{t4}", with: identifierType)
        
        guard let finalURL = URL(string: finalUrlString) else {
            throw OfferResolveError.invalidOfferURL
        }
        
        return finalURL
    }


    // 3) Full flow: API → final working URL (2xx) or a typed error
    func getWorkingOfferURL() async throws -> URL {
        let urlString = try await fetchOffer()
        return try await resolveFinalURL(from: urlString)
    }
}
