//
//  MapLocationPickerView.swift
//  DarnaApp
//
//  Map-based location picker using MapKit and OpenStreetMap Nominatim
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Location Picker State

struct SelectedLocation: Equatable {
    var coordinate: CLLocationCoordinate2D
    var address: String
    
    static func == (lhs: SelectedLocation, rhs: SelectedLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.address == rhs.address
    }
}

// MARK: - Map Location Picker View

struct MapLocationPickerView: View {
    @Binding var selectedAddress: String
    @Environment(\.dismiss) var dismiss
    
    // Map state
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815), // Tunisia default
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var selectedLocation: SelectedLocation?
    @State private var annotations: [MapAnnotationItem] = []
    
    // Search state
    @State private var searchQuery = ""
    @State private var searchResults: [NominatimResult] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var showSearchResults = false
    
    // Reverse geocoding state
    @State private var isResolvingAddress = false
    @State private var mapError: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                mapView
                
                // Bottom card overlay
                VStack {
                    Spacer()
                    selectedAddressCard
                }
            }
            .safeAreaInset(edge: .top) {
                searchSection
            }
            .navigationTitle("Sélectionner un lieu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                // Search field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Rechercher une adresse...", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                            searchResults = []
                            searchError = nil
                            showSearchResults = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Search button
                if !searchQuery.isEmpty {
                    Button {
                        performSearch()
                    } label: {
                        HStack {
                            Image(systemName: "location.magnifyingglass")
                            Text("Rechercher")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                    }
                    .disabled(isSearching || searchQuery.count < 3)
                    .opacity(searchQuery.count < 3 ? 0.6 : 1)
                }
                
                // Error message
                if let error = searchError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Search results dropdown
            if showSearchResults && !searchResults.isEmpty {
                searchResultsList
            }
        }
    }
    
    // MARK: - Search Results List
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { result in
                    Button {
                        selectSearchResult(result)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Text("Lat: \(result.lat) / Lon: \(result.lon)")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            annotationItems: annotations
        ) { item in
            MapAnnotation(coordinate: item.coordinate) {
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.primary)
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.primary)
                        .offset(y: -4)
                }
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onTapGesture { location in
            // This won't work directly with SwiftUI Map
            // We need a different approach for tap-to-select
        }
        .overlay(alignment: .center) {
            // Center crosshair for tap selection indicator
            if selectedLocation == nil {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // Tap-to-select button
            VStack(spacing: 12) {
                Button {
                    selectCenterLocation()
                } label: {
                    Image(systemName: "scope")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                
                // Zoom controls
                VStack(spacing: 0) {
                    Button {
                        withAnimation {
                            region.span.latitudeDelta /= 2
                            region.span.longitudeDelta /= 2
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Divider()
                    
                    Button {
                        withAnimation {
                            region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 180)
                            region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 180)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
            .padding()
            .padding(.bottom, 180) // Space for the bottom card
        }
    }
    
    // MARK: - Selected Address Card
    
    private var selectedAddressCard: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Adresse sélectionnée")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }
            
            // Address or placeholder
            HStack {
                if isResolvingAddress {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Récupération de l'adresse...")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                } else if let location = selectedLocation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.address)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(2)
                        
                        Text(location.coordinate.formattedString)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aucun lieu sélectionné")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Recherchez une adresse ou appuyez sur le bouton cible")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                    }
                }
                Spacer()
            }
            
            // Error
            if let error = mapError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    clearSelection()
                } label: {
                    Text("Effacer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                }
                
                Button {
                    confirmSelection()
                } label: {
                    Text("Confirmer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedLocation != nil ? AppTheme.primary : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(selectedLocation == nil)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 16, y: -4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        guard searchQuery.count >= 3 else {
            searchError = "Entrez au moins 3 caractères"
            return
        }
        
        isSearching = true
        searchError = nil
        mapError = nil
        
        Task {
            do {
                let results = try await NominatimService.shared.search(query: searchQuery)
                
                await MainActor.run {
                    searchResults = results
                    showSearchResults = true
                    isSearching = false
                    
                    if results.isEmpty {
                        searchError = "Aucun résultat trouvé pour cette recherche."
                    }
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    searchError = error.localizedDescription
                }
            }
        }
    }
    
    private func selectSearchResult(_ result: NominatimResult) {
        guard let coordinate = result.coordinate else {
            searchError = "Coordonnées invalides"
            return
        }
        
        // Update selection
        selectedLocation = SelectedLocation(
            coordinate: coordinate,
            address: result.displayName
        )
        
        // Update map
        annotations = [MapAnnotationItem(coordinate: coordinate)]
        
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Clear search
        searchQuery = ""
        searchResults = []
        showSearchResults = false
        searchError = nil
    }
    
    private func selectCenterLocation() {
        let coordinate = region.center
        
        // Update annotation
        annotations = [MapAnnotationItem(coordinate: coordinate)]
        
        // Perform reverse geocoding
        isResolvingAddress = true
        mapError = nil
        
        Task {
            do {
                let result = try await NominatimService.shared.reverse(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                
                await MainActor.run {
                    isResolvingAddress = false
                    
                    let address = result.displayName ?? result.address?.formattedAddress ?? coordinate.formattedString
                    
                    selectedLocation = SelectedLocation(
                        coordinate: coordinate,
                        address: address
                    )
                }
            } catch {
                await MainActor.run {
                    isResolvingAddress = false
                    
                    // Use coordinates as fallback
                    selectedLocation = SelectedLocation(
                        coordinate: coordinate,
                        address: coordinate.formattedString
                    )
                    
                    mapError = "Impossible de récupérer l'adresse: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func clearSelection() {
        selectedLocation = nil
        annotations = []
        mapError = nil
    }
    
    private func confirmSelection() {
        if let location = selectedLocation {
            selectedAddress = location.address
        }
        dismiss()
    }
}

// MARK: - Map Annotation Item

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Inline Location Picker (for form integration)

struct InlineMapLocationPicker: View {
    @Binding var location: String
    @State private var showFullMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Localisation")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button {
                showFullMap = true
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 50, height: 50)
                        .background(AppTheme.primaryLight)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.isEmpty ? "Sélectionner sur la carte" : "Localisation sélectionnée")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(location.isEmpty ? "Appuyez pour ouvrir la carte" : location)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Mini map preview if location is selected
            if !location.isEmpty {
                MiniMapPreview(address: location)
            }
        }
        .sheet(isPresented: $showFullMap) {
            MapLocationPickerView(selectedAddress: $location)
        }
    }
}

// MARK: - Mini Map Preview

struct MiniMapPreview: View {
    let address: String
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var annotations: [MapAnnotationItem] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: .constant(region),
                interactionModes: [],
                annotationItems: annotations
            ) { item in
                MapMarker(coordinate: item.coordinate, tint: AppTheme.primary)
            }
            .frame(height: 120)
            .cornerRadius(12)
            .disabled(true)
            
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            geocodeAddress()
        }
        .onChange(of: address) { _ in
            geocodeAddress()
        }
    }
    
    private func geocodeAddress() {
        isLoading = true
        
        Task {
            do {
                let results = try await NominatimService.shared.search(query: address, limit: 1)
                
                await MainActor.run {
                    isLoading = false
                    
                    if let first = results.first, let coordinate = first.coordinate {
                        region = MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                        annotations = [MapAnnotationItem(coordinate: coordinate)]
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MapLocationPickerView(selectedAddress: .constant(""))
}

