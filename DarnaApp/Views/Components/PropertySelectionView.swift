//
//  PropertySelectionView.swift
//  DarnaApp
//
//  Enhanced premium UI with glassmorphism and animations

import SwiftUI

/// A premium property selection component with advanced visual effects
struct PropertySelectionView: View {
    let properties: [Property]
    @Binding var selectedPropertyId: String
    var onPropertySelected: ((Property) -> Void)? = nil
    
    @State private var isExpanded = false
    @State private var animateGlow = false
    
    private var selectedProperty: Property? {
        properties.first { $0.id == selectedPropertyId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Premium Header with gradient
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .blur(radius: animateGlow ? 8 : 4)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animateGlow.toggle()
                    }
                }
                
                Text("Choisir un logement")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !selectedPropertyId.isEmpty {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 4)
            
            // Premium Selection Button with Glassmorphism
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    if let property = selectedProperty {
                        // Selected property display
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            PropertyImageView(imageString: property.image)
                                .cornerRadius(12)
                        }
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(property.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if let location = property.location {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 4, height: 4)
                                    
                                    Text(location)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    } else {
                        // Empty state - premium design
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .blue.opacity(0.08),
                                            .purple.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Sélectionnez votre logement...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Animated chevron
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    selectedPropertyId.isEmpty
                                        ? Color.gray.opacity(0.2)
                                        : LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                    lineWidth: selectedPropertyId.isEmpty ? 1 : 2
                                )
                        )
                        .shadow(color: selectedPropertyId.isEmpty ? .clear : .blue.opacity(0.15), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
            
            // Expanded property list with staggered animation
            if isExpanded {
                if properties.isEmpty {
                    // Empty state - no properties available
                    VStack(spacing: 16) {
                        Image(systemName: "house.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.gray, .gray.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Aucun logement disponible")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Il n'y a pas encore de logements dans la base de données.\n\nVeuillez ajouter des logements via l'interface web ou l'API.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("💡 Astuce")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Vérifiez aussi que le backend est démarré et accessible.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(properties.enumerated()), id: \.element.id) { index, property in
                            PropertyRow(
                                property: property,
                                isSelected: property.id == selectedPropertyId
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.05)),
                                removal: .opacity.animation(.easeOut(duration: 0.2))
                            ))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPropertyId = property.id
                                    isExpanded = false
                                }
                                onPropertySelected?(property)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Premium Property Row
private struct PropertyRow: View {
    let property: Property
    let isSelected: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Premium image with gradient border
            ZStack {
                PropertyImageView(imageString: property.image)
                    .frame(width: 70, height: 70)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected
                                    ? LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: isSelected ? 2.5 : 0
                            )
                    )
                
                if isSelected {
                    // Selection badge
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                                    .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                    .frame(width: 70, height: 70)
                }
            }
            
            // Property info
            VStack(alignment: .leading, spacing: 7) {
                Text(property.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(1)
                
                if let location = property.location {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? .blue : .secondary)
                        
                        Text(location)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Price & occupancy badges
                HStack(spacing: 10) {
                    // Price badge
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 10))
                        Text("\(Int(property.price)) DT")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.15), .blue.opacity(0.15)],
                                    startPoint: .leading,
                                    endPoint:trailing
                                )
                            )
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    // Occupancy badge
                    if let current = property.nbrCollocateurActuel,
                       let max = property.nbrCollocateurMax {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                            Text("\(current)/\(max)")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.12))
                        )
                        .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isSelected
                        ? LinearGradient(
                            colors: [
                                .blue.opacity(0.08),
                                .purple.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.white, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isSelected
                                ? LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.04),
                    radius: isSelected ? 12 : 6,
                    x: 0,
                    y: isSelected ? 6 : 3
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
#if DEBUG
struct PropertySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(initialValue: "") { selectedId in
            PropertySelectionView(
                properties: [],
                selectedPropertyId: selectedId
            )
            .padding()
        }
        .background(Color(red: 0.95, green: 0.96, blue: 0.98))
    }
    
    struct StatefulPreviewWrapper<Value, Content: View>: View {
        @State private var value: Value
        private let content: (Binding<Value>) -> Content
        
        init(initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
            _value = State(initialValue: initialValue)
            self.content = content
        }
        
        var body: some View {
            content($value)
        }
    }
}
#endif

