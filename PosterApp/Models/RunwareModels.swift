//
//  RunwareModels.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import Foundation

struct RunwareImageRequest: Codable {
    let taskType: String
    let taskUUID: String
    let positivePrompt: String
    let negativePrompt: String?
    let width: Int?
    let height: Int?
    let model: String
    let steps: Int?
    let CFGScale: Double?
    let numberResults: Int?

    init(prompt: String, negativePrompt: String? = nil, aspectRatio: AspectRatio = .square, aiModel: AIModel, numberResults: Int? = nil) {
        self.taskType = "imageInference"
        self.taskUUID = UUID().uuidString
        self.positivePrompt = prompt
        self.negativePrompt = negativePrompt
        self.model = aiModel.rawValue
        
        // Conditionally set dimensions based on model support
        if aiModel.supportsCustomDimensions {
            self.width = aspectRatio.dimensions.width
            self.height = aspectRatio.dimensions.height
        } else {
            self.width = nil
            self.height = nil
        }
        
        // Conditionally set steps based on model support
        if aiModel.supportsStepsParameter {
            self.steps = aiModel.optimalSettings.steps
        } else {
            self.steps = nil
        }
        
        // Conditionally set CFGScale based on model support
        if aiModel.supportsCFGScaleParameter {
            self.CFGScale = aiModel.optimalSettings.cfgScale
        } else {
            self.CFGScale = nil
        }
        self.numberResults = numberResults ?? 1
        
        // Validate dimensions only if they are supported (must be multiples of 64, between 128-2048)
        if let width = self.width, let height = self.height {
            assert(width >= 128 && width <= 2048 && width % 64 == 0, "Width must be between 128-2048 and multiple of 64")
            assert(height >= 128 && height <= 2048 && height % 64 == 0, "Height must be between 128-2048 and multiple of 64")
        }
    }
    
    // Legacy initializer for backwards compatibility
    init(prompt: String, negativePrompt: String? = nil, aspectRatio: AspectRatio = .square, model: String = "civitai:4384@128713", steps: Int = 20, CFGScale: Double = 7.0, numberResults: Int? = nil) {
        let dimensions = aspectRatio.dimensions
        
        self.taskType = "imageInference"
        self.taskUUID = UUID().uuidString
        self.positivePrompt = prompt
        self.negativePrompt = negativePrompt
        self.width = dimensions.width
        self.height = dimensions.height
        self.model = model
        self.steps = steps
        self.CFGScale = CFGScale
        self.numberResults = numberResults ?? 1
        
        // Validate dimensions (must be multiples of 64, between 128-2048)
        assert(dimensions.width >= 128 && dimensions.width <= 2048 && dimensions.width % 64 == 0, "Width must be between 128-2048 and multiple of 64")
        assert(dimensions.height >= 128 && dimensions.height <= 2048 && dimensions.height % 64 == 0, "Height must be between 128-2048 and multiple of 64")
    }
    
    init(prompt: String, width: Int = 1024, height: Int = 1024, model: String = "runware:100@1", steps: Int = 25, CFGScale: Double = 4.0, numberResults: Int? = nil) {
        self.taskType = "imageInference"
        self.taskUUID = UUID().uuidString
        self.positivePrompt = prompt
        self.negativePrompt = nil
        self.width = width
        self.height = height
        self.model = model
        self.steps = steps
        self.CFGScale = CFGScale
        self.numberResults = numberResults
    }
}

enum AspectRatio: String, CaseIterable, Codable {
    case square = "1:1"
    case portrait = "4:5"
    case story = "9:16"
    case landscape = "16:9"
    
    var dimensions: (width: Int, height: Int) {
        switch self {
        case .square: return (1024, 1024)      // 1024 is multiple of 64
        case .portrait: return (832, 1024)     // 4:5 ratio, both multiples of 64
        case .story: return (576, 1024)        // 9:16 ratio, both multiples of 64
        case .landscape: return (1024, 576)    // 16:9 ratio, both multiples of 64
        }
    }
    
    var displayName: String {
        switch self {
        case .square: return "Square (1024×1024)"
        case .portrait: return "Portrait (832×1024)"
        case .story: return "Story (576×1024)"
        case .landscape: return "Landscape (1024×576)"
        }
    }
}

struct RunwareImageResponse: Codable {
    let taskType: String
    let taskUUID: String
    let imageUUID: String?
    let imageURL: String?
    let imageBase64Data: String?
    let imageDataURI: String?
    let seed: Int?
    let NSFWContent: Bool?
    let cost: Double?
}

struct RunwareDataResponse: Codable {
    let data: [RunwareImageResponse]
}

struct PosterImage: Identifiable, Codable {
    let id: UUID
    let prompt: String
    let imageURL: String?
    let imageData: Data?
    let generatedAt: Date
    let seed: Int?
    let model: String
    let cost: Double?
    let contentSeries: ContentSeries?
    let aspectRatio: AspectRatio

    init(prompt: String, response: RunwareImageResponse, imageData: Data? = nil, contentSeries: ContentSeries? = nil, aspectRatio: AspectRatio = .square, model: String = "runware:100@1") {
        self.id = UUID()
        self.prompt = prompt
        self.imageURL = response.imageURL
        self.imageData = imageData
        self.generatedAt = Date()
        self.seed = response.seed
        self.model = model
        self.cost = response.cost
        self.contentSeries = contentSeries
        self.aspectRatio = aspectRatio
    }
    
    // Custom initializer for backwards compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        prompt = try container.decode(String.self, forKey: .prompt)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
        seed = try container.decodeIfPresent(Int.self, forKey: .seed)
        model = try container.decode(String.self, forKey: .model)
        cost = try container.decodeIfPresent(Double.self, forKey: .cost)
        
        // Handle new properties with defaults for backwards compatibility
        contentSeries = try container.decodeIfPresent(ContentSeries.self, forKey: .contentSeries)
        aspectRatio = try container.decodeIfPresent(AspectRatio.self, forKey: .aspectRatio) ?? .square
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, prompt, imageURL, imageData, generatedAt, seed, model, cost, contentSeries, aspectRatio
    }
}

enum AIModel: String, CaseIterable, Codable {
    case geminiFlashImage25 = "google:4@1"
    case realisticVision = "civitai:4201@130072"
    case dreamShaper = "civitai:4384@128713"
    case sdxlBase = "runware:100@1"
    case absoluteReality = "civitai:81458@132760"
    
    var displayName: String {
        switch self {
        case .geminiFlashImage25: return "Gemini Flash Image 25"
        case .realisticVision: return "Realistic Vision"
        case .dreamShaper: return "DreamShaper"
        case .sdxlBase: return "SDXL Base"
        case .absoluteReality: return "Absolute Reality"
        }
    }
    
    var description: String {
        switch self {
        case .geminiFlashImage25: return "General purpose, high quality, versatile"
        case .realisticVision: return "Photorealistic, detailed portraits and landscapes"
        case .dreamShaper: return "Artistic, dreamlike, fantasy-oriented"
        case .sdxlBase: return "General purpose, high quality, versatile"
        case .absoluteReality: return "Ultra-realistic, cinematic quality"
        }
    }
    
    var icon: String {
        switch self {
        case .geminiFlashImage25: return "pen.fill"
        case .realisticVision: return "camera.fill"
        case .dreamShaper: return "cloud.fill"
        case .sdxlBase: return "star.fill"
        case .absoluteReality: return "eye.fill"
        }
    }
    
    var mindfulnessStyle: String {
        switch self {
        case .geminiFlashImage25: return "balanced, harmonious mindful compositions"
        case .realisticVision: return "photographic meditation scenes with natural lighting"
        case .dreamShaper: return "ethereal, dreamlike mindfulness imagery"
        case .sdxlBase: return "balanced, harmonious mindful compositions"
        case .absoluteReality: return "cinematic, inspiring mindfulness photography"
        }
    }
    
    var optimalSettings: (steps: Int, cfgScale: Double) {
        switch self {
        case .geminiFlashImage25: return (25, 7.0)
        case .realisticVision: return (25, 7.0)
        case .dreamShaper: return (20, 7.5)
        case .sdxlBase: return (25, 4.0)
        case .absoluteReality: return (30, 6.5)
        }
    }
    
    var mindfulnessPromptEnhancement: String {
        switch self {
        case .geminiFlashImage25:
            return ", masterpiece, ultra-realistic, professional photography, natural lighting, serene atmosphere, high detail, peaceful expression"
        case .realisticVision:
            return ", masterpiece, ultra-realistic, professional photography, natural lighting, serene atmosphere, high detail, peaceful expression"
        case .dreamShaper:
            return ", ethereal beauty, soft dreamy lighting, magical atmosphere, fantasy art style, enchanting, peaceful aura, artistic masterpiece"
        case .sdxlBase:
            return ", high quality, balanced composition, harmonious colors, zen aesthetic, tranquil mood, premium artwork, detailed"
        case .absoluteReality:
            return ", cinematic quality, dramatic lighting, ultra-high definition, photorealistic, inspiring scene, emotional depth, award-winning"
        }
    }
    
    var supportsStepsParameter: Bool {
        switch self {
        case .geminiFlashImage25: return false
        case .realisticVision, .dreamShaper, .sdxlBase, .absoluteReality: return true
        }
    }
    
    var supportsCFGScaleParameter: Bool {
        switch self {
        case .geminiFlashImage25: return false
        case .realisticVision, .dreamShaper, .sdxlBase, .absoluteReality: return true
        }
    }
    
    var supportsCustomDimensions: Bool {
        switch self {
        case .geminiFlashImage25: return false
        case .realisticVision, .dreamShaper, .sdxlBase, .absoluteReality: return true
        }
    }
    
    static func displayName(for modelId: String) -> String {
        switch modelId {
        case AIModel.geminiFlashImage25.rawValue: return AIModel.geminiFlashImage25.displayName
        case AIModel.realisticVision.rawValue: return AIModel.realisticVision.displayName
        case AIModel.dreamShaper.rawValue: return AIModel.dreamShaper.displayName
        case AIModel.sdxlBase.rawValue: return AIModel.sdxlBase.displayName
        case AIModel.absoluteReality.rawValue: return AIModel.absoluteReality.displayName
        default: return modelId
        }
    }
}

enum StylePreset: String, CaseIterable, Codable {
    case watercolor = "Watercolor"
    case photography = "Photography" 
    case minimalist = "Minimalist"
    case illustration = "Soft Illustration"
    
    var stylePrompt: String {
        switch self {
        case .watercolor:
            return ", watercolor painting style, soft brushstrokes, flowing colors, artistic, dreamy"
        case .photography:
            return ", professional photography, natural lighting, crisp details, realistic"
        case .minimalist:
            return ", minimalist design, clean lines, simple composition, negative space, zen aesthetic"
        case .illustration:
            return ", soft digital illustration, gentle colors, smooth gradients, peaceful atmosphere"
        }
    }
    
    var negativePrompt: String {
        switch self {
        case .watercolor:
            return "harsh lines, digital artifacts, overly sharp, mechanical"
        case .photography:
            return "painting, illustration, cartoon, unrealistic, oversaturated"
        case .minimalist:
            return "cluttered, busy, complex, ornate, decorative elements"
        case .illustration:
            return "photorealistic, harsh shadows, rough textures, aggressive"
        }
    }
    
    var icon: String {
        switch self {
        case .watercolor: return "paintbrush.fill"
        case .photography: return "camera.fill"
        case .minimalist: return "circle"
        case .illustration: return "pencil.tip.crop.circle.fill"
        }
    }
}

enum ContentSeries: String, CaseIterable, Codable {
    case mondayMotivation = "Monday Motivation"
    case tuesdayThoughts = "Tuesday Thoughts"
    case wednesdayWisdom = "Wednesday Wisdom"
    case thursdayTherapy = "Thursday Therapy"
    case fridayReflection = "Friday Reflection"
    case weekendWellness = "Weekend Wellness"
    case dailyAffirmation = "Daily Affirmation"
    case mindfulMoment = "Mindful Moment"
    
    var promptPrefix: String {
        switch self {
        case .mondayMotivation:
            return "Motivational and energizing scene with warm sunrise colors, representing new beginnings and fresh starts. "
        case .tuesdayThoughts:
            return "Contemplative and thoughtful atmosphere with soft natural lighting, encouraging deep reflection. "
        case .wednesdayWisdom:
            return "Wise and serene environment with ancient or timeless elements, conveying knowledge and understanding. "
        case .thursdayTherapy:
            return "Healing and nurturing scene with gentle, soothing colors and therapeutic elements. "
        case .fridayReflection:
            return "Peaceful sunset or twilight scene with calming colors, perfect for weekly reflection. "
        case .weekendWellness:
            return "Rejuvenating nature scene with lush greenery and fresh air, promoting wellness and self-care. "
        case .dailyAffirmation:
            return "Uplifting and positive scene with bright, encouraging colors and symbols of growth. "
        case .mindfulMoment:
            return "Zen-like minimalist scene with clean lines and calming elements, promoting mindfulness. "
        }
    }
    
    var stylePrompt: String {
        return ", minimalist design, soft gradients, peaceful atmosphere, high quality, aesthetic composition, Instagram-ready"
    }
    
    var emoji: String {
        switch self {
        case .mondayMotivation: return "🌅"
        case .tuesdayThoughts: return "💭"
        case .wednesdayWisdom: return "🧘‍♂️"
        case .thursdayTherapy: return "🌸"
        case .fridayReflection: return "🌙"
        case .weekendWellness: return "🌿"
        case .dailyAffirmation: return "✨"
        case .mindfulMoment: return "🕯️"
        }
    }
}

enum GenerationState {
    case idle
    case generating(progress: Double)
    case completed(PosterImage)
    case failed(Error)
}

struct APIRequestLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let request: RunwareImageRequest
    let response: RunwareDataResponse?
    let error: String?
    let executionTime: Double
    let cost: Double?
    
    init(request: RunwareImageRequest, response: RunwareDataResponse? = nil, error: String? = nil, executionTime: Double, cost: Double? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.request = request
        self.response = response
        self.error = error
        self.executionTime = executionTime
        self.cost = cost
    }
}

struct BatchGenerationRequest {
    let basePrompt: String
    let contentSeries: ContentSeries
    let aspectRatio: AspectRatio
    let count: Int
    let model: String
    
    init(basePrompt: String, contentSeries: ContentSeries, aspectRatio: AspectRatio = .square, count: Int = 4, model: String = "runware:100@1") {
        self.basePrompt = basePrompt
        self.contentSeries = contentSeries
        self.aspectRatio = aspectRatio
        self.count = count
        self.model = model
    }
    
    var enhancedPrompt: String {
        return contentSeries.promptPrefix + basePrompt + contentSeries.stylePrompt
    }
}

struct RunwareAPIError: LocalizedError {
    let message: String
    let code: String?

    var errorDescription: String? {
        return message
    }

    init(message: String, code: String? = nil) {
        self.message = message
        self.code = code
    }
}
