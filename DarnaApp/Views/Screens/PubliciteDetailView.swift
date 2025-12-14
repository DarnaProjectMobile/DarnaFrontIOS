//
//  PubliciteDetailView.swift
//  DarnaApp
//

import SwiftUI

struct PubliciteDetailView: View {
    @StateObject private var viewModel: PubliciteDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(publicite: Publicite) {
        _viewModel = StateObject(wrappedValue: PubliciteDetailViewModel(publicite: publicite))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerImage
                VStack(spacing: 24) {
                    typeBadge
                    titleSection
                    typeSpecificContent
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .center) {
            if viewModel.showWinAnimation {
                ConfettiView()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .onAppear {
                        // Masquer l'animation après 3 secondes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                viewModel.showWinAnimation = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $viewModel.showQRCode) {
            qrCodeView
        }
        .overlay(alignment: .bottom) {
            if viewModel.showResult,
               let result = viewModel.gameResult,
               let isWin = viewModel.isWinResult {
                resultBanner(result: result, isWin: isWin)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var headerImage: some View {
        Group {
            if let imageUrl = viewModel.publicite.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty: placeholderImage
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill).frame(height: 250).clipped()
                    case .failure: placeholderImage
                    @unknown default: placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(LinearGradient(colors: [AppTheme.primary.opacity(0.6), AppTheme.primary.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 250)
            .overlay {
                Image(systemName: "photo").font(.system(size: 60)).foregroundColor(.white.opacity(0.5))
            }
    }
    
    private var typeBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: typeIcon).font(.system(size: 16, weight: .semibold))
            Text(viewModel.publicite.type.capitalized).font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(typeColor))
        .shadow(color: typeColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var typeIcon: String {
        switch viewModel.publicite.publiciteType {
        case .reduction: return "percent"
        case .promotion: return "tag.fill"
        case .jeu: return "gamecontroller.fill"
        case .none: return "star.fill"
        }
    }
    
    private var typeColor: Color {
        switch viewModel.publicite.publiciteType {
        case .reduction: return Color.green
        case .promotion: return Color.orange
        case .jeu: return Color.purple
        case .none: return AppTheme.primary
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.publicite.titre).font(.system(size: 28, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text(viewModel.publicite.description).font(.body).foregroundColor(AppTheme.textSecondary).lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var typeSpecificContent: some View {
        switch viewModel.publicite.publiciteType {
        case .reduction: reductionContent
        case .promotion: promotionContent
        case .jeu: gameContent
        case .none: EmptyView()
        }
    }
    
    private var reductionContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Code Promo").font(.headline).foregroundColor(AppTheme.textSecondary)
                Text(viewModel.promoCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.primaryLight.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 5])).foregroundColor(AppTheme.primary.opacity(0.3)))
                    )
            }
            if let detailReduction = viewModel.publicite.detailReduction, let conditions = detailReduction.conditionsUtilisation, !conditions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conditions d'utilisation").font(.subheadline).fontWeight(.semibold).foregroundColor(AppTheme.textPrimary)
                    Text(conditions).font(.caption).foregroundColor(AppTheme.textSecondary).padding().frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                }
            }
            Button { viewModel.utiliserCodePromo() } label: {
                HStack {
                    Image(systemName: "qrcode")
                    Text("Utiliser ce code").fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
            }
        }
        .padding(.top, 10)
    }
    
    private var promotionContent: some View {
        VStack(spacing: 20) {
            if let detailPromo = viewModel.publicite.detailPromotion, let offre = detailPromo.offre {
                VStack(spacing: 12) {
                    Image(systemName: "gift.fill").font(.system(size: 50)).foregroundColor(.orange)
                    Text(offre).font(.title2).fontWeight(.bold).foregroundColor(AppTheme.textPrimary).multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                
                if let conditions = detailPromo.conditions, !conditions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Conditions").font(.subheadline).fontWeight(.semibold).foregroundColor(AppTheme.textPrimary)
                        Text(conditions).font(.caption).foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                }
            }
        }
        .padding(.top, 10)
    }
    
    private var gameContent: some View {
        VStack(spacing: 30) {
            if let config = viewModel.rouletteConfig {
                if !viewModel.hasPlayedGame {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles").font(.system(size: 30)).foregroundColor(.purple)
                        Text("Tentez votre chance !").font(.title3).fontWeight(.bold).foregroundColor(AppTheme.textPrimary)
                        Text("Tournez la roue pour gagner une réduction").font(.subheadline).foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                }
                RouletteView(
                    config: config,
                    rotation: $viewModel.angleRotation,
                    isSpinning: $viewModel.isSpinning,
                    hasPlayedGame: viewModel.hasPlayedGame,
                    onSpin: viewModel.jouerRoulette
                )
                .padding(.vertical, 20)
                
                // Message si l'utilisateur a déjà joué à cette annonce
                if viewModel.hasPlayedGame && !viewModel.isSpinning {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.green)
                        Text("Vous avez déjà joué à cette annonce")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private func resultBanner(result: String, isWin: Bool) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(isWin ? " Félicitations !" : " Dommage").font(.headline).foregroundColor(AppTheme.textPrimary)
                Text(isWin ? "Vous avez gagné :" : "Aucun gain cette fois.").font(.subheadline).foregroundColor(AppTheme.textSecondary)
                Text(result).font(.system(size: 32, weight: .bold)).foregroundColor(isWin ? AppTheme.primary : .gray)
            }
            if isWin {
                Button { viewModel.utiliserReduction() } label: {
                    HStack {
                        Image(systemName: "qrcode")
                        Text("Utiliser ma réduction").fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
                }
            }
            Button { withAnimation { viewModel.showResult = false } } label: {
                Text("Fermer").font(.subheadline).foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(AppTheme.card).shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5))
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var qrCodeView: some View {
        QRCodeConfirmationView(
            code: viewModel.gameResult ?? viewModel.promoCode,
            title: "Code activé !",
            message: "Présentez ce QR code en caisse pour bénéficier de votre réduction."
        )
    }
}
