//
//  PropertyMapView.swift
//  DarnaApp
//
//  Full-screen map that displays properties as price markers.
//

import SwiftUI
import MapKit

private struct PropertyAnnotation: Identifiable {
    let id = UUID()
    let property: Property
    let coordinate: CLLocationCoordinate2D
}

struct PropertyMapView: View {
    let properties: [Property]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    @State private var annotations: [PropertyAnnotation] = []
    @State private var selectedProperty: Property?
    @State private var isLoading = true
    @State private var navigateToDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                mapView
                
                if isLoading {
                    ProgressView("Chargement de la carte...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                
                if let property = selectedProperty {
                    bottomCard(for: property)
                }
            }
            .ignoresSafeArea(edges: [.bottom])
            .navigationTitle("Carte des annonces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .task {
                await buildAnnotations()
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let property = selectedProperty {
                    PropertyDetailPage(property: property)
                }
            }
        }
    }
    
    // MARK: - Map
    
    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { item in
            MapAnnotation(coordinate: item.coordinate) {
                VStack(spacing: 2) {
                    Text("\(Int(item.property.price)) DT")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(AppTheme.primary)
                        .rotationEffect(.degrees(180))
                }
                .onTapGesture {
                    selectedProperty = item.property
                }
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
            }
        }
    }
    
    // MARK: - Bottom card
    
    @ViewBuilder
    private func bottomCard(for property: Property) -> some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    PropertyImageView(imageString: property.image)
                        .frame(width: 70, height: 70)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(property.price)) DT / mois")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                        
                        Text(property.location ?? "Lieu non spécifié")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                        
                        Text(property.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                    }
                }
                
                Button {
                    navigateToDetail = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                        Text("Voir les détails de l'annonce")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .animation(.spring(), value: selectedProperty)
    }
    
    // MARK: - Build annotations
    
    @MainActor
    private func buildAnnotations() async {
        isLoading = true
        var newAnnotations: [PropertyAnnotation] = []
        
        for property in properties {
            guard let locationText = property.location,
                  !locationText.isEmpty else { continue }
            
            do {
                let results = try await NominatimService.shared.search(query: locationText, limit: 1)
                if let first = results.first, let coordinate = first.coordinate {
                    let annotation = PropertyAnnotation(property: property, coordinate: coordinate)
                    newAnnotations.append(annotation)
                }
            } catch {
                // Ignore individual failures
                continue
            }
        }
        
        annotations = newAnnotations
        if let first = newAnnotations.first {
            region.center = first.coordinate
        }
        isLoading = false
    }
}
