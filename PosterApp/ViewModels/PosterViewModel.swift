//
//  PosterViewModel.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import Foundation
import SwiftUI
import Combine
import Photos
import UIKit

@MainActor
class PosterViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var generatedImages: [PosterImage] = []
    @Published var generationState: GenerationState = .idle
    @Published var apiKey: String = ""
    @Published var showAPIKeySetup = false
    
    // Mindfulness Content Features
    @Published var selectedContentSeries: ContentSeries = .dailyAffirmation
    @Published var selectedAspectRatio: AspectRatio = .square
    @Published var batchGenerationCount: Int = 4
    @Published var isDeveloperModeEnabled: Bool = false
    
    // Advanced Studio Features
    @Published var showAdvancedControls: Bool = false
    @Published var negativePrompt: String = ""
    @Published var selectedStylePreset: StylePreset = .minimalist
    @Published var selectedAIModel: AIModel = .dreamShaper
    @Published var customSeed: String = ""
    @Published var backgroundImage: UIImage? = nil
    @Published var imageStrength: Double = 0.7
    
    // Developer Mode Features
    @Published var apiRequestLogs: [APIRequestLog] = []
    @Published var showingAPIInspector: Bool = false
    @Published var totalCostToday: Double = 0.0
    
    // Navigation Control
    @Published var shouldNavigateToGallery: Bool = false

    private var apiService: RunwareAPIService?

    init() {
        loadAPIKey()
        loadSavedImages()
        loadUserPreferences()
    }

    private func loadAPIKey() {
        if let savedKey = APIKeyManager.getAPIKey() {
            apiKey = savedKey
            apiService = RunwareAPIService(apiKey: savedKey)
        } else {
            showAPIKeySetup = true
        }
    }
    
    private func loadUserPreferences() {
        isDeveloperModeEnabled = UserDefaults.standard.bool(forKey: "developer_mode_enabled")
        showAdvancedControls = UserDefaults.standard.bool(forKey: "advanced_controls_enabled")
        totalCostToday = UserDefaults.standard.double(forKey: "total_cost_today")
    }

    func saveAPIKey() {
        APIKeyManager.setAPIKey(apiKey)
        apiService = RunwareAPIService(apiKey: apiKey)
        showAPIKeySetup = false
    }

    func validatePrompt() -> Bool {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 3
    }

    func generatePoster() async {
        await generateMindfulnessContent(isBatch: false)
    }
    
    func generateBatchContent() async {
        await generateMindfulnessContent(isBatch: true)
    }
    
    private func generateMindfulnessContent(isBatch: Bool = false) async {
        guard validatePrompt() else {
            generationState = .failed(RunwareAPIError(message: "Please enter a valid prompt (at least 3 characters)"))
            return
        }

        guard let apiService = apiService else {
            generationState = .failed(RunwareAPIError(message: "API key not configured"))
            return
        }

        generationState = .generating(progress: 0.1)
        
        let originalPrompt = prompt
        if !isBatch {
            prompt = ""
        }
        
        let startTime = Date()

        do {
            var enhancedPrompt = selectedContentSeries.promptPrefix + originalPrompt
            
            // Apply model-specific prompting strategy
            enhancedPrompt = applyModelSpecificEnhancements(to: enhancedPrompt, for: selectedAIModel)
            
            if showAdvancedControls {
                enhancedPrompt += selectedStylePreset.stylePrompt
            } else {
                enhancedPrompt += selectedContentSeries.stylePrompt
            }
            
            let finalNegativePrompt: String? = {
                if showAdvancedControls && !negativePrompt.isEmpty {
                    return negativePrompt + ", " + selectedStylePreset.negativePrompt
                } else if showAdvancedControls {
                    return selectedStylePreset.negativePrompt
                } else {
                    return "chaotic, busy, stressful, harsh, aggressive"
                }
            }()
            
            let seedValue: Int? = {
                if showAdvancedControls && !customSeed.isEmpty {
                    return Int(customSeed)
                }
                return nil
            }()
            
            let count = isBatch ? batchGenerationCount : 1
            let modelSettings = selectedAIModel.optimalSettings
            
            print("🎬 Director's Cut - Generating mindful scene:")
            print("Original prompt: \(originalPrompt)")
            print("Enhanced prompt: \(enhancedPrompt)")
            print("Negative prompt: \(finalNegativePrompt ?? "default")")
            print("AI Model: \(selectedAIModel.displayName) (\(selectedAIModel.rawValue))")
            print("Model Style: \(selectedAIModel.mindfulnessStyle)")
            print("Style: \(selectedStylePreset.rawValue)")
            print("Series: \(selectedContentSeries.rawValue)")
            print("Dimensions: \(selectedAIModel.supportsCustomDimensions ? "\(selectedAspectRatio.dimensions.width)×\(selectedAspectRatio.dimensions.height)" : "default")")
            print("Steps: \(selectedAIModel.supportsStepsParameter ? "\(modelSettings.steps)" : "not supported"), CFG: \(selectedAIModel.supportsCFGScaleParameter ? "\(modelSettings.cfgScale)" : "not supported")")
            print("Seed: \(seedValue?.description ?? "random")")
            print("Count: \(count)")
            
            let request = RunwareImageRequest(
                prompt: enhancedPrompt,
                negativePrompt: finalNegativePrompt,
                aspectRatio: selectedAspectRatio,
                aiModel: selectedAIModel,
                numberResults: count
            )
            
            generationState = .generating(progress: 0.5)
            let response = try await apiService.generateImages(request: request)
            
            var newImages: [PosterImage] = []
            for imageResponse in response.data {
                if let imageData = try? await downloadImageData(from: imageResponse.imageURL) {
                    let posterImage = PosterImage(
                        prompt: originalPrompt,
                        response: imageResponse,
                        imageData: imageData,
                        contentSeries: selectedContentSeries,
                        aspectRatio: selectedAspectRatio,
                        model: selectedAIModel.rawValue
                    )
                    newImages.append(posterImage)
                }
            }
            
            generatedImages.insert(contentsOf: newImages, at: 0)
            saveImagesToStorage()
            
            let executionTime = Date().timeIntervalSince(startTime)
            let totalCost = response.data.compactMap { $0.cost }.reduce(0, +)
            logAPIRequest(request: request, response: response, executionTime: executionTime, cost: totalCost)
            
            generationState = .completed(newImages.first!)
            
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            if !newImages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.shouldNavigateToGallery = true
                }
            }

        } catch {
            let executionTime = Date().timeIntervalSince(startTime)
            logAPIRequest(request: RunwareImageRequest(prompt: originalPrompt, negativePrompt: nil, aspectRatio: selectedAspectRatio), response: nil, error: error.localizedDescription, executionTime: executionTime)
            generationState = .failed(error)
        }
    }
    
    private func downloadImageData(from urlString: String?) async throws -> Data? {
        guard let urlString = urlString, let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func regeneratePoster(from originalImage: PosterImage) async {
        prompt = originalImage.prompt
        await generatePoster()
    }

    func deletePoster(_ poster: PosterImage) {
        generatedImages.removeAll { $0.id == poster.id }
        saveImagesToStorage()
    }

    private func saveImagesToStorage() {
        do {
            let data = try JSONEncoder().encode(generatedImages)
            UserDefaults.standard.set(data, forKey: "saved_poster_images")
        } catch {
            print("Failed to save images: \(error)")
        }
    }

    private func loadSavedImages() {
        if let data = UserDefaults.standard.data(forKey: "saved_poster_images") {
            do {
                generatedImages = try JSONDecoder().decode([PosterImage].self, from: data)
            } catch {
                print("Failed to load images: \(error)")
            }
        }
    }

    func saveToPhotoLibrary(_ poster: PosterImage) async -> Bool {
        guard let imageData = poster.imageData,
              let uiImage = UIImage(data: imageData) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
            }) { success, error in
                continuation.resume(returning: success)
            }
        }
    }

    func sharePoster(_ poster: PosterImage) -> Data? {
        return poster.imageData
    }

    private func logAPIRequest(request: RunwareImageRequest, response: RunwareDataResponse? = nil, error: String? = nil, executionTime: Double, cost: Double? = nil) {
        let log = APIRequestLog(
            request: request,
            response: response,
            error: error,
            executionTime: executionTime,
            cost: cost
        )
        apiRequestLogs.insert(log, at: 0)
        
        if let cost = cost {
            updateDailyCost(cost)
        }
        
        if apiRequestLogs.count > 50 {
            apiRequestLogs.removeLast()
        }
    }
    
    private func updateDailyCost(_ cost: Double) {
        let today = Calendar.current.startOfDay(for: Date())
        let lastCostUpdate = UserDefaults.standard.object(forKey: "last_cost_update") as? Date ?? Date.distantPast
        
        if Calendar.current.startOfDay(for: lastCostUpdate) != today {
            totalCostToday = cost
        } else {
            totalCostToday += cost
        }
        
        UserDefaults.standard.set(totalCostToday, forKey: "total_cost_today")
        UserDefaults.standard.set(Date(), forKey: "last_cost_update")
    }
    
    func toggleDeveloperMode() {
        isDeveloperModeEnabled.toggle()
        UserDefaults.standard.set(isDeveloperModeEnabled, forKey: "developer_mode_enabled")
    }
    
    func getMindfulnessPromptSuggestions() -> [String] {
        return [
            "Inner peace radiating from within",
            "Gratitude for life's simple moments", 
            "Breathing deeply, finding calm",
            "Let go of what doesn't serve you",
            "Trust the process of your journey",
            "You are exactly where you need to be",
            "Embrace change as growth",
            "Find joy in present moment",
            "Your thoughts create your reality",
            "Be kind to yourself today"
        ]
    }
    
    func getPromptSuggestions() -> [String] {
        return getMindfulnessPromptSuggestions()
    }
    
    func getContentSeriesForToday() -> ContentSeries {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch weekday {
        case 2: return .mondayMotivation
        case 3: return .tuesdayThoughts
        case 4: return .wednesdayWisdom
        case 5: return .thursdayTherapy
        case 6: return .fridayReflection
        case 7, 1: return .weekendWellness
        default: return .dailyAffirmation
        }
    }
    
    func presetPromptForSeries(_ series: ContentSeries) {
        selectedContentSeries = series
        switch series {
        case .mondayMotivation:
            prompt = "Start this week with renewed energy and purpose"
        case .tuesdayThoughts:
            prompt = "Take a moment to reflect on your growth"
        case .wednesdayWisdom:
            prompt = "Ancient wisdom for modern challenges"
        case .thursdayTherapy:
            prompt = "Healing begins with self-compassion"
        case .fridayReflection:
            prompt = "Look back with gratitude, forward with hope"
        case .weekendWellness:
            prompt = "Restore your mind, body, and spirit"
        case .dailyAffirmation:
            prompt = "I am capable of amazing things"
        case .mindfulMoment:
            prompt = "This moment is all we truly have"
        }
    }
    
    func copySeedFromImage(_ posterImage: PosterImage) {
        if let seed = posterImage.seed {
            customSeed = String(seed)
            UIPasteboard.general.string = String(seed)
        }
    }
    
    func toggleAdvancedControls() {
        showAdvancedControls.toggle()
        UserDefaults.standard.set(showAdvancedControls, forKey: "advanced_controls_enabled")
    }
    
    func clearBackgroundImage() {
        backgroundImage = nil
    }
    
    func loadDemoScenario() {
        prompt = "A peaceful meditation garden with morning light streaming through trees"
        selectedStylePreset = .photography
        negativePrompt = "crowded, noisy, artificial, harsh lighting"
        selectedAspectRatio = .square
        showAdvancedControls = true
    }
    
    private func applyModelSpecificEnhancements(to prompt: String, for model: AIModel) -> String {
        let enhancement = model.mindfulnessPromptEnhancement
        return "\(prompt) \(enhancement)"
    }
}