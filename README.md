# Mindful Creator

An iOS SwiftUI app that generates AI-powered mindfulness content using the Runware AI API.

## Features

- Generate inspiring mindfulness visuals with AI
- Specialized content series for different themes (Monday Motivation, Tuesday Thoughts, etc.)
- Multiple aspect ratios: Square, Portrait, Story, Landscape
- Save images to photo library
- Built-in cost tracking and API logging

## Runware API Integration

This app uses the Runware AI API for image generation:

- **Endpoint**: `/v1` for batch image generation
- **Authentication**: Bearer token required

### Available Models

The app supports multiple AI models, each optimized for different use cases:

| Model | ID | Description | Use Case |
|-------|----|-----------  |----------|
| **DreamShaper** | `civitai:4384@128713` | Artistic, dreamy aesthetics (default) | Mindfulness, abstract art |
| **Realistic Vision** | `civitai:4201@130072` | Photorealistic portraits and landscapes | Realistic scenes |
| **SDXL Base** | `runware:100@1` | Stable Diffusion XL base model | General purpose |
| **Absolute Reality** | `civitai:81458@132760` | Ultra-realistic generations | High-detail realism |
| **Gemini Flash** | `google:4@1` | Google's fast, versatile model | Quick generation |

### Parameters

Each model supports configurable parameters:

- **CFG Scale**: Controls prompt adherence (4.0-15.0)
  - Lower values: More creative freedom
  - Higher values: Stricter prompt following
- **Steps**: Generation quality (10-50 steps)
  - More steps = higher quality, longer generation time
- **Aspect Ratios**: 
  - Square: 1024×1024
  - Portrait: 832×1024  
  - Story: 576×1024
  - Landscape: 1024×576
- **Batch Size**: Generate 1-4 images per request
- **Negative Prompts**: Automatically exclude unwanted elements
- **Custom Dimensions**: Must be multiples of 64, range 128-2048px

## Setup

1. Get your API key from [Runware](https://runware.ai)
2. Test the API in the [Runware Playground](https://my.runware.ai/playground) (optional)
3. Open the app and enter your API key
4. Start generating mindful content

## Resources

- [Runware API Documentation](https://runware.ai/docs/en/image-inference/introduction)
- [Runware Playground](https://my.runware.ai/playground) - Test models and parameters online

## Requirements

- iOS 18.5+
- Runware API key
