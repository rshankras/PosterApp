//
//  RunwareAPIService.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import Foundation
import Combine
import SwiftUI
import Photos

class RunwareAPIService {
    private let baseURL = "https://api.runware.ai/v1"
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateImages(request: RunwareImageRequest) async throws -> RunwareDataResponse {
        let url = URL(string: baseURL)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode([request])
        urlRequest.httpBody = jsonData

        print("🚀 Runware API Request:")
        print("URL: \(url)")
        print("Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Body: \(jsonString)")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RunwareAPIError(message: "Invalid response")
        }

        print("📥 Runware API Response:")
        print("Status Code: \(httpResponse.statusCode)")
        print("Headers: \(httpResponse.allHeaderFields)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage: String
            if let responseString = String(data: data, encoding: .utf8) {
                errorMessage = "HTTP \(httpResponse.statusCode): \(responseString)"
            } else {
                errorMessage = "HTTP Error: \(httpResponse.statusCode)"
            }
            throw RunwareAPIError(message: errorMessage, code: "\(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(RunwareDataResponse.self, from: data)
            print("✅ Successfully decoded response with \(apiResponse.data.count) images")
            return apiResponse
        } catch {
            print("❌ Failed to decode response: \(error)")
            throw RunwareAPIError(message: "Failed to decode API response: \(error.localizedDescription)")
        }
    }
}

class APIKeyManager {
    private static let apiKeyKey = "runware_api_key"

    static func getAPIKey() -> String? {
        return UserDefaults.standard.string(forKey: apiKeyKey)
    }

    static func setAPIKey(_ apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: apiKeyKey)
    }

    static func hasAPIKey() -> Bool {
        return getAPIKey() != nil
    }
}