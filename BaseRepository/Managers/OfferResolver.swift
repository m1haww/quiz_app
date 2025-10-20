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
    func fetchOffer() async throws -> URL {
        let path = "/api/v1/offers/ios/\(Bundle.main.bundleIdentifier ?? "")"
    
        guard let endpoint = URL(string: path, relativeTo: apiBase) else { throw OfferResolveError.invalidOfferURL }

        let (data, resp) = try await URLSession.shared.data(from: endpoint)
        guard let http = resp as? HTTPURLResponse else { throw OfferResolveError.decodeFailed }
        
        switch http.statusCode {
        case 200...299:
            break
        case 404:
            throw OfferResolveError.apiNotFound
        default:
            throw OfferResolveError.apiBadStatus(http.statusCode)
        }

        let dto = try JSONDecoder().decode(OfferDTO.self, from: data)
        guard let start = URL(string: dto.url) else { throw OfferResolveError.invalidOfferURL }
        return start
    }

    // 2) Append params and resolve redirects
    func resolveFinalURL(from start: URL) async throws -> URL {
        let urlWithParams = try await appendParams(from: start)
        
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
    
    func appendParams(from start: URL) async throws -> URL {
        var identifier: String
        var identifierType: String
        
        if TrackingManager.shared.currentStatus == .authorized {
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
        
        var urlString = start.absoluteString
        urlString = urlString.replacingOccurrences(of: "{t1}", with: identifier)
        urlString = urlString.replacingOccurrences(of: "{t2}", with: platform)
        urlString = urlString.replacingOccurrences(of: "{t3}", with: bundleId)
        urlString = urlString.replacingOccurrences(of: "{t4}", with: identifierType)
        
        guard let finalURL = URL(string: urlString) else {
            throw OfferResolveError.invalidOfferURL
        }
        
        return finalURL
    }


    // 3) Full flow: API → final working URL (2xx) or a typed error
    func getWorkingOfferURL() async throws -> URL {
        let start = try await fetchOffer()
        return try await resolveFinalURL(from: start)
    }
}
