//
//  ImageGalleryView.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import SwiftUI
import Photos


struct ImageGalleryView: View {
    @ObservedObject var viewModel: PosterViewModel
    @State private var selectedPoster: PosterImage? = nil
    @State private var showingShareSheet = false
    @State private var shareData: Data? = nil

    // Fixed grid with consistent sizing
    private let columns = [
        GridItem(.fixed(165), spacing: DesignSystem.Spacing.md),
        GridItem(.fixed(165), spacing: DesignSystem.Spacing.md)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {
                if viewModel.generatedImages.isEmpty {
                    emptyStateView
                } else {
                    galleryContent
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.backgroundPrimary)
        .sheet(item: $selectedPoster) { poster in
            PosterDetailView(poster: poster, viewModel: viewModel)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = shareData {
                ShareSheet(data: data)
            }
        }
    }

    private var emptyStateView: some View {
        MindfulCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(DesignSystem.Colors.contentTertiary)

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("No content yet")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.contentPrimary)

                    Text("Create your first mindful visual using the Create tab")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.contentSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .padding(.top, 100)
        .accessibilityLabel("Gallery is empty. Create your first mindful visual using the Create tab.")
    }

    private var galleryContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            MindfulSectionHeader("Your Creations", subtitle: "\(viewModel.generatedImages.count) mindful visuals")

            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                ForEach(viewModel.generatedImages) { poster in
                    MinimalPosterCard(
                        poster: poster,
                        onTap: { selectedPoster = poster },
                        onShare: {
                            shareData = poster.imageData
                            showingShareSheet = true
                        },
                        onRegenerate: {
                            Task {
                                await viewModel.regeneratePoster(from: poster)
                            }
                        },
                        onDelete: {
                            viewModel.deletePoster(poster)
                        }
                    )
                }
            }
        }
    }
}

struct MinimalPosterCard: View {
    let poster: PosterImage
    let onTap: () -> Void
    let onShare: () -> Void
    let onRegenerate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Fixed-size image container
            ZStack {
                if let imageData = poster.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 165, height: 165) // Fixed square size
                        .clipped()
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(DesignSystem.Colors.backgroundTertiary)
                        .frame(width: 165, height: 165)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.contentTertiary)
                        )
                }
                
                // Content series badge
                if let series = poster.contentSeries {
                    VStack {
                        HStack {
                            Spacer()
                            Text(series.emoji)
                                .font(.caption)
                                .padding(DesignSystem.Spacing.xs)
                                .background(
                                    Circle()
                                        .fill(DesignSystem.Colors.backgroundPrimary.opacity(0.9))
                                )
                        }
                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.xs)
                }
            }
            .onTapGesture(perform: onTap)
            .accessibilityLabel("Mindful visual: \(poster.prompt)")
            .accessibilityHint("Double tap to view details")

            // Prompt preview
            Text(poster.prompt)
                .font(DesignSystem.Typography.caption1)
                .lineLimit(2)
                .foregroundColor(DesignSystem.Colors.contentSecondary)
                .frame(height: 32, alignment: .top) // Fixed height to maintain alignment

            // Minimal actions
            HStack(spacing: DesignSystem.Spacing.md) {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                .accessibilityLabel("Share")


                Button(action: onRegenerate) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.success)
                }
                .accessibilityLabel("Regenerate")

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.error)
                }
                .accessibilityLabel("Delete")
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(width: 165) // Fixed card width
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.backgroundSecondary)
                .shadow(color: DesignSystem.Shadows.subtle, radius: 2, x: 0, y: 1)
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let data: Data

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let image = UIImage(data: data) ?? UIImage()
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}

#Preview {
    @Previewable @State var viewModel = PosterViewModel()
    
    ImageGalleryView(viewModel: viewModel)
}

struct PosterDetailView: View {
    let poster: PosterImage
    @ObservedObject var viewModel: PosterViewModel
    @State private var showingShareSheet = false
    @State private var saveResult: Bool? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Image
                    if let imageData = poster.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                            .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .cornerRadius(16)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                            .padding(.horizontal)
                    }

                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        // Prompt
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(poster.prompt)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Metadata
                        VStack(alignment: .leading, spacing: 12) {
                            if let seed = poster.seed {
                                HStack {
                                    Text("Seed:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(seed)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button(action: {
                                        UIPasteboard.general.string = "\(seed)"
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            if let cost = poster.cost {
                                HStack {
                                    Text("Cost:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "$%.4f", cost))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }

                            HStack {
                                Text("Created:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(poster.generatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }

                            HStack {
                                Text("Model:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(AIModel.displayName(for: poster.model))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Action buttons
                    VStack(spacing: 12) {
                        // Save to Photos
                        Button(action: saveToPhotos) {
                            HStack {
                                Image(systemName: saveResult == true ? "checkmark.circle.fill" : "square.and.arrow.down")
                                Text(saveResult == true ? "Saved!" : "Save to Photos")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(poster.imageData == nil)

                        // Share
                        Button(action: { showingShareSheet = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Poster")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(poster.imageData == nil)

                        // Regenerate
                        Button(action: {
                            Task {
                                await viewModel.regeneratePoster(from: poster)
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Poster Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = poster.imageData {
                    ShareSheet(data: data)
                }
            }
            .alert(item: $saveResult) {
                result in
                Alert(
                    title: Text(result ? "Saved!" : "Failed to Save"),
                    message: Text(result ? "Poster saved to your photo library" : "Could not save poster to photo library"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveToPhotos() {
        guard poster.imageData != nil else { return }

        Task {
            let success = await viewModel.saveToPhotoLibrary(poster)
            saveResult = success
        }
    }
}

extension Bool: @retroactive Identifiable {
    public var id: Bool { self }
}

#Preview {
    let mockPoster = PosterImage(
        prompt: "A stunning landscape with mountains and a lake at sunset, with vibrant colors and dramatic lighting",
        response: RunwareImageResponse(
            taskType: "imageInference",
            taskUUID: "test-uuid",
            imageUUID: "test-image-uuid",
            imageURL: nil,
            imageBase64Data: nil,
            imageDataURI: nil,
            seed: 1234567890,
            NSFWContent: false,
            cost: 0.0015
        ),
        imageData: nil
    )

    PosterDetailView(poster: mockPoster, viewModel: PosterViewModel())
}
