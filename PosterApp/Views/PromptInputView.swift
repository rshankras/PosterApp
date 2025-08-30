//
//  PromptInputView.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import SwiftUI

struct PromptInputView: View {
    @ObservedObject var viewModel: PosterViewModel
    @State private var selectedSuggestion: String? = nil
    @State private var showingContentSeriesSheet = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg, pinnedViews: .sectionHeaders) {
                // Content Series Selection
                Section {
                    MindfulCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                MindfulSectionHeader("Content Series", subtitle: "Choose your theme")
                                
                                Spacer()
                                
                                Button(action: {
                                    showingContentSeriesSheet = true
                                }) {
                                    Text("Change")
                                        .font(DesignSystem.Typography.callout)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                                .accessibilityLabel("Change content series")
                                .accessibilityHint("Opens series selection")
                            }
                            
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Text(viewModel.selectedContentSeries.emoji)
                                    .font(.system(size: 32))
                                    .accessibilityHidden(true)
                                
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                    Text(viewModel.selectedContentSeries.rawValue)
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.contentPrimary)
                                    
                                    Text("Optimized visual style")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(DesignSystem.Colors.contentSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                
                // Format Selection
                Section {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        MindfulSectionHeader("Format", subtitle: "Choose dimensions")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                ForEach(AspectRatio.allCases, id: \.self) { ratio in
                                    MinimalAspectRatioButton(
                                        ratio: ratio,
                                        isSelected: viewModel.selectedAspectRatio == ratio
                                    ) {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        
                                        viewModel.selectedAspectRatio = ratio
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)

                // Message Input Section
                Section {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            MindfulSectionHeader("Your Message", subtitle: "Share your mindful thoughts")
                            
                            Spacer()
                            
                            if viewModel.isDeveloperModeEnabled {
                                Button(action: {
                                    viewModel.showingAPIInspector = true
                                }) {
                                    Image(systemName: "terminal")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(DesignSystem.Colors.warning)
                                }
                                .accessibilityLabel("Developer tools")
                                .accessibilityHint("View API request logs")
                            }
                        }

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(DesignSystem.Colors.backgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                                )
                                .frame(height: 120)
                            
                            TextEditor(text: $viewModel.prompt)
                                .padding(DesignSystem.Spacing.md)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .font(DesignSystem.Typography.body)
                                .accessibilityLabel("Mindful message input")
                                .accessibilityHint("Enter your mindful thoughts to create visual content")

                            if viewModel.prompt.isEmpty {
                                Text("What mindful message would you like to share?")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.contentTertiary)
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .padding(.vertical, DesignSystem.Spacing.md + 8)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)

                // Inspiration Section
                Section {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        MindfulSectionHeader("Inspiration", subtitle: "Tap to use a suggestion")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(viewModel.getMindfulnessPromptSuggestions(), id: \.self) { suggestion in
                                    MinimalSuggestionChip(
                                        text: suggestion,
                                        isSelected: selectedSuggestion == suggestion
                                    ) {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        
                                        viewModel.prompt = suggestion
                                        selectedSuggestion = suggestion
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                
                // Advanced Controls Toggle
                Section {
                    MindfulCard {
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Director's Studio")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.contentPrimary)
                                
                                Text("Advanced creation tools")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.contentSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.showAdvancedControls)
                                .labelsHidden()
                                .accessibilityLabel("Toggle advanced controls")
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                
                // Advanced Controls (Conditional)
                if viewModel.showAdvancedControls {
                    advancedControlsSection
                }

                // Generation Section
                Section {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Primary generation button
                        MindfulButton(
                            singleButtonText,
                            systemImage: isGenerating ? nil : "plus.circle.fill",
                            style: .primary
                        ) {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            Task {
                                await viewModel.generatePoster()
                            }
                        }
                        .disabled(!viewModel.validatePrompt() || isGenerating)
                        
                        // Batch generation button
                        MindfulButton(
                            "Create \(viewModel.batchGenerationCount) Variations",
                            systemImage: isGenerating ? nil : "square.grid.2x2",
                            style: .secondary
                        ) {
                            Task {
                                await viewModel.generateBatchContent()
                            }
                        }
                        .disabled(!viewModel.validatePrompt() || isGenerating)

                        // Generation progress
                        if case .generating(let progress) = viewModel.generationState {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                                        .scaleEffect(0.8)
                                    
                                    Text("Creating your mindful visual...")
                                        .font(DesignSystem.Typography.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(DesignSystem.Colors.contentPrimary)
                                }
                                
                                ProgressView(value: progress)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .tint(DesignSystem.Colors.primary)
                                    .accessibilityLabel("Generation progress")
                                    .accessibilityValue("\(Int(progress * 100)) percent")
                                
                                Text("\(Int(progress * 100))% complete")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.contentSecondary)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.primary.opacity(0.05))
                                    .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Creating visual, \(Int(progress * 100)) percent complete")
                        }

                        // Error message
                        if case .failed(let error) = viewModel.generationState {
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(DesignSystem.Colors.warning)
                                    Text("Generation Failed")
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.error)
                                }
                                
                                Text(error.localizedDescription)
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.contentSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.error.opacity(0.1))
                                    .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Error: \(error.localizedDescription)")
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.backgroundPrimary)
        .sheet(isPresented: $showingContentSeriesSheet) {
            ContentSeriesSelectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingAPIInspector) {
            if viewModel.isDeveloperModeEnabled {
                DeveloperModeView(viewModel: viewModel)
            }
        }
    }

    private var isGenerating: Bool {
        if case .generating = viewModel.generationState {
            return true
        }
        return false
    }

    private var singleButtonText: String {
        if case .generating = viewModel.generationState {
            return "Creating..."
        }
        return "Create Mindful Post"
    }
    
    private var advancedControlsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // AI Model Selection
            Section {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    MindfulSectionHeader("AI Model", subtitle: "Choose generation engine")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(AIModel.allCases, id: \.self) { model in
                                AIModelButton(
                                    model: model,
                                    isSelected: viewModel.selectedAIModel == model
                                ) {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    viewModel.selectedAIModel = model
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
            // Style Presets
            Section {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    MindfulSectionHeader("Visual Style", subtitle: "Choose your aesthetic")
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.sm) {
                        ForEach(StylePreset.allCases, id: \.self) { style in
                            StylePresetButton(
                                preset: style,
                                isSelected: viewModel.selectedStylePreset == style
                            ) {
                                viewModel.selectedStylePreset = style
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
            // Negative Prompt
            Section {
                MindfulCard {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        MindfulSectionHeader("Avoid These Elements", subtitle: "Refine your creation")
                        
                        TextField("chaotic, busy, stressful...", text: $viewModel.negativePrompt, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Typography.callout)
                            .lineLimit(2...4)
                            .accessibilityLabel("Negative prompt")
                            .accessibilityHint("Describe what you want to avoid in the image")
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
        }
    }
}

struct MinimalSuggestionChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(DesignSystem.Typography.callout)
                .fontWeight(isSelected ? .medium : .regular)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .frame(width: 160, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.backgroundSecondary)
                        .stroke(DesignSystem.Colors.primary.opacity(isSelected ? 1 : 0.2), lineWidth: 1)
                )
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.contentPrimary)
        }
        .accessibilityLabel(text)
        .accessibilityHint("Tap to use this suggestion")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct MinimalAspectRatioButton: View {
    let ratio: AspectRatio
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.contentTertiary)
                    .frame(width: ratioWidth, height: ratioHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .stroke(DesignSystem.Colors.primary.opacity(isSelected ? 1 : 0.3), lineWidth: isSelected ? 2 : 1)
                    )
                
                Text(ratio.rawValue)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.contentSecondary)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .accessibilityLabel("\(ratio.displayName)")
        .accessibilityHint("Select aspect ratio")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
    
    private var ratioWidth: CGFloat {
        switch ratio {
        case .square: return 32
        case .portrait: return 26
        case .story: return 18
        case .landscape: return 40
        }
    }
    
    private var ratioHeight: CGFloat {
        switch ratio {
        case .square: return 32
        case .portrait: return 32
        case .story: return 32
        case .landscape: return 22
        }
    }
}

struct ContentSeriesSelectionView: View {
    @ObservedObject var viewModel: PosterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
                ], spacing: DesignSystem.Spacing.md) {
                    ForEach(ContentSeries.allCases, id: \.self) { series in
                        MinimalContentSeriesCard(
                            series: series,
                            isSelected: viewModel.selectedContentSeries == series
                        ) {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            viewModel.presetPromptForSeries(series)
                            dismiss()
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.backgroundPrimary)
            .navigationTitle("Content Series")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

struct MinimalContentSeriesCard: View {
    let series: ContentSeries
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(series.emoji)
                    .font(.system(size: 36))
                    .accessibilityHidden(true)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(series.rawValue)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(DesignSystem.Colors.contentPrimary)
                    
                    Text(dayOfWeek)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.contentSecondary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.backgroundSecondary)
                    .stroke(DesignSystem.Colors.primary.opacity(isSelected ? 1 : 0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .accessibilityLabel("\(series.rawValue) content series")
        .accessibilityHint("Select this content theme")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
    
    private var dayOfWeek: String {
        switch series {
        case .mondayMotivation: return "Monday"
        case .tuesdayThoughts: return "Tuesday"
        case .wednesdayWisdom: return "Wednesday"
        case .thursdayTherapy: return "Thursday"
        case .fridayReflection: return "Friday"
        case .weekendWellness: return "Weekend"
        case .dailyAffirmation: return "Any Day"
        case .mindfulMoment: return "Any Time"
        }
    }
}

struct DeveloperModeView: View {
    @ObservedObject var viewModel: PosterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // Usage Statistics
                    Section {
                        MindfulCard {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                MindfulSectionHeader("Today's Usage", subtitle: "API metrics")
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                        Text("Total Cost")
                                            .font(DesignSystem.Typography.caption1)
                                            .foregroundColor(DesignSystem.Colors.contentSecondary)
                                        Text(String(format: "$%.4f", viewModel.totalCostToday))
                                            .font(DesignSystem.Typography.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DesignSystem.Colors.success)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                        Text("Requests")
                                            .font(DesignSystem.Typography.caption1)
                                            .foregroundColor(DesignSystem.Colors.contentSecondary)
                                        Text("\(viewModel.apiRequestLogs.count)")
                                            .font(DesignSystem.Typography.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                }
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Usage statistics: \(String(format: "$%.4f", viewModel.totalCostToday)) cost, \(viewModel.apiRequestLogs.count) requests")
                    }
                    
                    // API Request Log
                    Section {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            MindfulSectionHeader("API Request Log", subtitle: "Recent API calls")
                            
                            if viewModel.apiRequestLogs.isEmpty {
                                MindfulCard {
                                    VStack(spacing: DesignSystem.Spacing.sm) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .font(.system(size: 32))
                                            .foregroundColor(DesignSystem.Colors.contentTertiary)
                                        
                                        Text("No requests yet")
                                            .font(DesignSystem.Typography.callout)
                                            .foregroundColor(DesignSystem.Colors.contentSecondary)
                                    }
                                    .padding(DesignSystem.Spacing.lg)
                                }
                                .accessibilityLabel("No API requests logged yet")
                            } else {
                                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                                    ForEach(viewModel.apiRequestLogs) { log in
                                        MinimalAPILogCard(log: log)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.backgroundPrimary)
            .navigationTitle("Developer Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close developer tools")
                }
            }
        }
    }
}

struct MinimalAPILogCard: View {
    let log: APIRequestLog
    
    var body: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.contentSecondary)
                    
                    Spacer()
                    
                    if let cost = log.cost {
                        Text(String(format: "$%.4f", cost))
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.success)
                    }
                    
                    Text(String(format: "%.2fs", log.executionTime))
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if log.error != nil {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.error)
                        Text("Failed")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.error)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.success)
                        Text("Success")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.success)
                    }
                    
                    Spacer()
                }
                
                if log.error == nil {
                    Text("Prompt: \(log.request.positivePrompt.prefix(80))...")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.contentTertiary)
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("API request at \(log.timestamp.formatted(date: .omitted, time: .shortened)), \(log.error == nil ? "successful" : "failed")")
    }
}

struct AIModelButton: View {
    let model: AIModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: model.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primary)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(model.displayName)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.contentPrimary)
                    
                    Text(model.description)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.contentSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(DesignSystem.Spacing.sm)
            .frame(width: 140, height: 90)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.backgroundSecondary)
                    .stroke(DesignSystem.Colors.primary.opacity(isSelected ? 1 : 0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .accessibilityLabel("\(model.displayName): \(model.description)")
        .accessibilityHint("Select this AI model")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct StylePresetButton: View {
    let preset: StylePreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primary)
                
                Text(preset.rawValue)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.contentPrimary)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.backgroundSecondary)
                    .stroke(DesignSystem.Colors.primary.opacity(isSelected ? 1 : 0.2), lineWidth: 1)
            )
        }
        .accessibilityLabel("\(preset.rawValue) style")
        .accessibilityHint("Select this visual style")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    PromptInputView(viewModel: PosterViewModel())
}