//
//  APIKeySetupView.swift
//  PosterApp
//
//  Created by Ravi Shankar on 28/08/25.
//

import SwiftUI


struct APIKeySetupView: View {
    @ObservedObject var viewModel: PosterViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.bottom, 8)

            // Title
            Text("Welcome to Prompt-to-Poster!")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            // Description
            Text("To get started, you'll need a Runware AI API key. This connects your app to their powerful image generation service.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // API Key input
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.headline)

                SecureField("Enter your Runware API key", text: $viewModel.apiKey)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .frame(height: 44)
            }
            .padding(.horizontal)

            // Save button
            Button(action: viewModel.saveAPIKey) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .disabled(viewModel.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal)

            // Help text
            VStack(spacing: 8) {
                Text("Don't have an API key?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    if let url = URL(string: "https://runware.ai") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Get one at runware.ai")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    APIKeySetupView(viewModel: PosterViewModel())
}
