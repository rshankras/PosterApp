# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PosterApp is an iOS SwiftUI application called "Mindful Creator" that generates AI-powered mindfulness content using the Runware AI API. The app focuses on creating inspiring visual content for mindfulness journeys, with specialized content series for different days of the week and wellness themes.

## Architecture

### Core Components

- **MVVM Pattern**: Uses `PosterViewModel` as the central state manager that coordinates between views and services
- **Service Layer**: `RunwareAPIService` handles all API communication with Runware AI
- **Data Models**: `RunwareModels.swift` contains request/response models, `PosterImage` data structure, content series, style presets, and aspect ratios
- **Design System**: `DesignSystem.swift` provides Apple HIG-compliant UI components, semantic colors, typography, and spacing
- **Persistence**: Uses `UserDefaults` for API key storage, generated image metadata, and user preferences
- **Photo Library Integration**: Built-in functionality to save generated images to device photo library
- **Developer Tools**: Built-in API logging, cost tracking, and debugging features

### Key Files

- `PosterViewModel.swift`: Main view model handling state, API calls, business logic, and mindfulness content features
- `RunwareAPIService.swift`: API service and `APIKeyManager` for Runware AI integration
- `RunwareModels.swift`: Data models including `PosterImage`, request/response structures, `GenerationState` enum, `ContentSeries`, `StylePreset`, and `AspectRatio`
- `ContentView.swift`: Root view with tab navigation, developer mode toggle, and success banners
- `PromptInputView.swift`: Text input interface with mindfulness suggestions and generation controls
- `ImageGalleryView.swift`: Grid display of generated images with detailed view modal
- `APIKeySetupView.swift`: Initial setup screen for Runware API key configuration
- `DesignSystem.swift`: Apple HIG-compliant design system with semantic colors, typography, and reusable components

### Data Flow

1. User configures API key via `APIKeySetupView` (persisted in `UserDefaults`)
2. User selects content series (Monday Motivation, Tuesday Thoughts, etc.) and enters prompt in `PromptInputView`
3. `PosterViewModel.generateMindfulnessContent()` enhances prompt with series-specific styling and creates `RunwareImageRequest`
4. API generates images with mindfulness-focused prompts and negative prompts to ensure peaceful content
5. Generated images are wrapped as `PosterImage` objects with content series metadata and stored locally
6. Images display in `ImageGalleryView` with share/save/regenerate actions and success banner navigation

## Development Commands

### Building and Running
```bash
# Open in Xcode
open PosterApp.xcodeproj

# Build from command line (if using xcodebuild)
xcodebuild -project PosterApp.xcodeproj -scheme PosterApp -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### iOS Simulator Testing
- Target: iOS 18.5+
- Primary test device: iPhone 15
- Uses Photos framework - simulator will prompt for photo library permissions
- Test both light and dark mode (design system is fully adaptive)

## Key Implementation Details

### API Integration
- Uses Runware AI's `/v1` endpoint for batch image generation
- Requires Bearer token authentication
- Supports multiple aspect ratios: Square (1024×1024), Portrait (832×1024), Story (576×1024), Landscape (1024×576)
- Model: `civitai:4384@128713` with customizable CFG scale and steps
- Handles image download, local caching, and cost tracking
- Developer mode provides API request logging and daily cost tracking

### Content Series System
- 8 predefined content series: Monday Motivation, Tuesday Thoughts, Wednesday Wisdom, Thursday Therapy, Friday Reflection, Weekend Wellness, Daily Affirmation, Mindful Moment
- Each series has specific prompt prefixes and styling to ensure appropriate mindful content
- Batch generation supports creating 1-4 images at once
- Advanced controls allow custom negative prompts, style presets, and seed values

### State Management
- `GenerationState` enum tracks: `.idle`, `.generating(progress)`, `.completed(PosterImage)`, `.failed(Error)`
- All generated images persist in `UserDefaults` as encoded JSON with content series metadata
- API key and user preferences managed through `APIKeyManager` and `UserDefaults`
- Developer mode state persisted across app launches

### UI Patterns
- Tab-based navigation (Create/Gallery) with programmatic navigation after generation
- Apple HIG-compliant design system with semantic colors supporting light/dark mode
- Success banners with automatic navigation to gallery
- Developer mode toggle with haptic feedback
- Share sheet integration using `UIActivityViewController`
- Progress indicators and loading states with animation

## Testing Considerations

- Mock the `RunwareAPIService` for unit tests
- Test image persistence and retrieval from `UserDefaults` with content series metadata
- Verify photo library permission handling
- Test error states (network failures, invalid API keys, malformed API responses)
- Test developer mode features (API logging, cost tracking)
- Test content series prompt enhancement and negative prompt generation
- UI testing should cover the full prompt-to-poster generation flow including batch generation
- Test design system components in both light and dark modes
- Verify accessibility compliance with VoiceOver and dynamic type