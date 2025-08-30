//
//  ContentView.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import SwiftUI
import UIKit
import Photos


struct ContentView: View {
    @StateObject private var viewModel = PosterViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.showAPIKeySetup {
                    APIKeySetupView(viewModel: viewModel)
                } else {
                    mainContent
                }
            }
            .background(DesignSystem.Colors.backgroundPrimary)
        }
        .tint(DesignSystem.Colors.primary)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                developerModeButton
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mindful Content Creator")
    }

    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Clean, minimal header
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Mindful Creator")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.contentPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Create inspiring content for your mindfulness journey")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.contentSecondary)
                    .multilineTextAlignment(.center)
                    .accessibilityHint("App description")
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.md)

            TabView(selection: $selectedTab) {
                PromptInputView(viewModel: viewModel)
                    .tabItem {
                        Label("Create", systemImage: "plus.circle")
                    }
                    .tag(0)

                ImageGalleryView(viewModel: viewModel)
                    .tabItem {
                        Label("Gallery", systemImage: "photo.on.rectangle")
                    }
                    .tag(1)
            }
            .tint(DesignSystem.Colors.primary)
            .onChange(of: viewModel.shouldNavigateToGallery) { _, shouldNavigate in
                if shouldNavigate {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 1
                    }
                    viewModel.shouldNavigateToGallery = false
                }
            }
        }
        .background(DesignSystem.Colors.backgroundPrimary)
    }
    
    private var developerModeButton: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            viewModel.toggleDeveloperMode()
        }) {
            Image(systemName: viewModel.isDeveloperModeEnabled ? "hammer.fill" : "hammer")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.isDeveloperModeEnabled ? DesignSystem.Colors.warning : DesignSystem.Colors.contentSecondary)
        }
        .accessibilityLabel("Developer mode")
        .accessibilityHint("Toggle developer tools and API logging")
        .accessibilityAddTraits(.isButton)
    }
}


#Preview {
    ContentView()
}
