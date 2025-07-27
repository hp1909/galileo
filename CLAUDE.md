# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Galileo is an iOS application built with SwiftUI. This is a standard iOS project created with Xcode 26.0, targeting iPhone and iPad platforms with iOS 26.0 deployment target.

## Project Structure

- `Galileo/` - Main application source code
  - `GalileoApp.swift` - App entry point using SwiftUI App protocol
  - `ContentView.swift` - Main view with basic "Hello, world!" interface
  - `Assets.xcassets/` - App icons and asset catalog
- `GalileoTests/` - Unit tests using Swift Testing framework
- `GalileoUITests/` - UI tests using XCTest framework
- `Galileo.xcodeproj/` - Xcode project configuration

## Development Commands

### Building the Project
Use Xcode to build the project:
- Open `Galileo.xcodeproj` in Xcode
- Use Cmd+B to build
- Use Cmd+R to run on simulator or device

### Running Tests
- **Unit Tests**: Use Cmd+U in Xcode or run via Test Navigator
- **UI Tests**: Included in the same test suite, run via Xcode Test Navigator

### Command Line Build (if needed)
```bash
xcodebuild -project Galileo.xcodeproj -scheme Galileo -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project Galileo.xcodeproj -scheme Galileo -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Architecture Notes

- **Framework**: SwiftUI with modern Swift 5.0 features
- **AI Integration**: Uses Apple's Foundation Models framework with LanguageModelSession
- **Testing**: Uses Swift Testing framework for unit tests and XCTest for UI tests
- **Deployment Target**: iOS 26.0 (very recent iOS version)
- **Development Team**: Configured with team ID UR86F3FN9K
- **Bundle ID**: phucnguyen.Galileo

## Educational Content Creator Demo

This project demonstrates Apple's Foundation Models framework through an educational app with four main features:

### Features
1. **Concept Explainer**: Transforms complex scientific concepts into accessible explanations
2. **Quiz Generator**: Creates interactive multiple-choice quizzes on any topic
3. **Study Notes Summarizer**: Processes lengthy study material into organized summaries
4. **Flashcard Creator**: Generates interactive flashcard sets for effective learning

### Foundation Models Implementation
- Uses `LanguageModelSession` with custom instructions for educational content
- Implements `@Generable` structs for structured AI output
- Employs guided generation for consistent formatting
- Session prewarming for optimal performance

## Key Configuration Details

- Swift version: 5.0
- Uses automatic code signing
- SwiftUI previews enabled
- Modern Swift concurrency features enabled (SWIFT_APPROACHABLE_CONCURRENCY)
- Main Actor isolation by default (SWIFT_DEFAULT_ACTOR_ISOLATION)