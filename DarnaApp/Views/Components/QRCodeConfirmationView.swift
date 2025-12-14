//
//  QRCodeConfirmationView.swift
//  DarnaApp
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// Vue de confirmation avec QR Code
struct QRCodeConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let code: String
    let title: String
    let message: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Icône de succès
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary.opacity(0.2), AppTheme.primary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary)
                }
                .padding(.bottom, 10)
                
                // Titre
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                // Message
                Text(message)
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // QR Code
                if let qrImage = generateQRCode(from: code) {
                    VStack(spacing: 16) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        // Code textuel
                        VStack(spacing: 8) {
                            Text("Code Promo")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(code)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.primaryLight.opacity(0.2))
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Bouton de fermeture
                Button {
                    dismiss()
                } label: {
                    Text("Terminé")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .navigationTitle("Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - QR Code Generation
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up the QR code
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}


