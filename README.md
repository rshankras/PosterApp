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
- **Model**: `civitai:4384@128713`
- **Authentication**: Bearer token required
- **Parameters**:
  - CFG Scale: Controls adherence to prompt (default: 7)
  - Steps: Generation quality (default: 25)
  - Aspect Ratio: Square (1024×1024), Portrait (832×1024), Story (576×1024), Landscape (1024×576)
  - Batch Size: 1-4 images per request
  - Negative Prompts: Automatically added for peaceful, mindful content

## Setup

1. Get your API key from [Runware](https://runware.ai)
2. Open the app and enter your API key
3. Start generating mindful content

## Documentation

- [Runware API Documentation](https://runware.ai/docs/en/image-inference/introduction)

## Requirements

- iOS 18.5+
- Runware API key
