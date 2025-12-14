//
//  MarquePartenaireView.swift
//  DarnaApp
//
//  Section des marques partenaires avec scroll horizontal
//

import SwiftUI

struct MarquePartenaireView: View {
    let marques: [(id: String, name: String, logo: String?)]
    var onAddTap: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec titre et bouton +
            HStack {
                Text("Nos Marques Partenaires")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onAddTap) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            // Scroll horizontal des marques
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(marques, id: \.id) { marque in
                        MarqueCard(
                            name: marque.name,
                            logo: marque.logo,
                            initial: String(marque.name.prefix(1))
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MarqueCard: View {
    let name: String
    let logo: String?
    let initial: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Logo circulaire
            ZStack {
                Circle()
                    .fill(randomColor(for: name))
                    .frame(width: 64, height: 64)
                
                if let logo = logo, let url = URL(string: logo) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                        case .failure, .empty:
                            initialView
                        @unknown default:
                            initialView
                        }
                    }
                } else {
                    initialView
                }
            }
            
            // Nom de la marque
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: 80)
        }
    }
    
    private var initialView: some View {
        Text(initial)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
    }
    
    // Couleur aléatoire basée sur le nom
    private func randomColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .green, .pink, .indigo]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    MarquePartenaireView(marques: [
        (id: "1", name: "Pizza Express", logo: nil),
        (id: "2", name: "TechCorp", logo: nil),
        (id: "3", name: "BookShop", logo: nil),
        (id: "4", name: "StyleUp", logo: nil)
    ])
}
