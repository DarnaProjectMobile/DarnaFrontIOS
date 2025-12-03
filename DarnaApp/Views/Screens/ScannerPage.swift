//
//  ScannerPage.swift
//  DarnaApp
//

import SwiftUI

struct ScannerPage: View {
    @State private var navigateToMainApp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.white, Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title and Instructions
                    VStack(spacing: 12) {
                        Text("Scanner votre carte d'identité")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Positionnez votre carte d'identité dans le cadre")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Scanner Frame
                    ZStack {
                        // Dark blue background (camera view)
                        Color(red: 0.1, green: 0.2, blue: 0.4)
                            .frame(height: 400)
                            .cornerRadius(20)
                        
                        // Dashed frame for card placement
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                            .foregroundColor(.white)
                            .frame(width: 280, height: 180)
                            .overlay(
                                VStack {
                                    HStack {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.white)
                                            .padding(8)
                                        Spacer()
                                        Image(systemName: "aspectratio")
                                            .foregroundColor(.white)
                                            .padding(8)
                                    }
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("Placez votre carte dans le cadre")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(8)
                                        Spacer()
                                    }
                                    .padding(.bottom, 10)
                                }
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Capture Button
                        Button {
                            navigateToMainApp = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                Text("Capturer")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.primary, Color(red: 0.2, green: 0.8, blue: 0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        // Import from Gallery Button
                        Button {
                            // Import action
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 18))
                                Text("Importer depuis la galerie")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.primary, lineWidth: 2)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Conseils pour une bonne capture:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TipRow(text: "Assurez-vous d'avoir un bon éclairage")
                            TipRow(text: "Évitez les reflets sur la carte")
                            TipRow(text: "Gardez la carte bien à plat")
                            TipRow(text: "Assurez-vous que toutes les informations sont lisibles")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Footer
                    Text("Verificatio ID Card")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Back action handled by navigation
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Retour")
                        }
                        .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToMainApp) {
                MainAppView()
            }
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                .font(.system(size: 18))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
    }
}

