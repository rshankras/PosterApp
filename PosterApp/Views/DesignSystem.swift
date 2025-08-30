//
//  DesignSystem.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import SwiftUI

// MARK: - Apple HIG Compliant Design System
struct DesignSystem {
    
    // MARK: - Colors (Semantic, System Colors)
    struct Colors {
        // Primary semantic colors
        static let primary = Color.blue
        static let secondary = Color(.systemBlue)
        static let accent = Color.accentColor
        
        // Content colors (automatically adapt to light/dark mode)
        static let contentPrimary = Color.primary
        static let contentSecondary = Color.secondary
        static let contentTertiary = Color(.tertiaryLabel)
        
        // Background colors (system adaptive)
        static let backgroundPrimary = Color(.systemBackground)
        static let backgroundSecondary = Color(.secondarySystemBackground)
        static let backgroundTertiary = Color(.tertiarySystemBackground)
        
        // Grouped background colors
        static let groupedPrimary = Color(.systemGroupedBackground)
        static let groupedSecondary = Color(.secondarySystemGroupedBackground)
        
        // Mindfulness-specific semantic colors
        static let mindfulPrimary = Color.blue
        static let mindfulSecondary = Color(.systemIndigo)
        
        // Status colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }
    
    // MARK: - Typography (Supporting Dynamic Type)
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption1 = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing (8pt grid system)
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    // MARK: - Shadows (Subtle, HIG-compliant)
    struct Shadows {
        static let subtle = Color.black.opacity(0.05)
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
    }
}

// MARK: - Reusable Components

struct MindfulCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .shadow(color: DesignSystem.Shadows.subtle, radius: 1, x: 0, y: 1)
            )
    }
}

struct MindfulButton: View {
    let title: String
    let systemImage: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
    }
    
    init(_ title: String, systemImage: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(accessibilityHint)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primary
        case .secondary:
            return DesignSystem.Colors.backgroundTertiary
        case .tertiary:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DesignSystem.Colors.primary
        case .tertiary:
            return DesignSystem.Colors.primary
        }
    }
    
    private var accessibilityHint: String {
        switch style {
        case .primary:
            return "Double tap to \(title.lowercased())"
        case .secondary, .tertiary:
            return "Button"
        }
    }
}

struct MindfulSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.contentPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.contentSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}