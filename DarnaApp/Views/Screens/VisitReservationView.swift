//
//  VisitReservationView.swift
//  DarnaApp
//
//  Creative UI with modern design patterns

import SwiftUI

struct VisitReservationView: View {
    @ObservedObject var viewModel: VisitViewModel
    
    @State private var properties: [Property] = []
    @State private var isLoadingProperties = false
    @State private var propertyLoadError: String?
    @State private var currentStep: ReservationStep = .property
    @State private var animateGradient = false
    
    enum ReservationStep: Int, CaseIterable {
        case property = 0
        case datetime = 1
        case contact = 2
        
        var title: String {
            switch self {
            case .property: return "Logement"
            case .datetime: return "Date & Heure"
            case .contact: return "Contact"
            }
        }
        
        var icon: String {
            switch self {
            case .property: return "house.fill"
            case .datetime: return "calendar"
            case .contact: return "person.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Header
                    HeroHeaderView()
                        .padding(.top, 20)
                    
                    // Progress Stepper
                    StepProgressView(currentStep: currentStep)
                        .padding(.horizontal)
                    
                    // ⚠️ Active Visit Warning
                    if viewModel.hasActiveVisit(), let activeVisit = viewModel.getActiveVisit() {
                        ActiveVisitWarningCard(visit: activeVisit)
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    
                    // Property Selection Section
                    if isLoadingProperties {
                        LoadingCardView()
                            .padding(.horizontal)
                    } else if let error = propertyLoadError {
                        ErrorCardView(message: error) {
                            loadProperties()
                        }
                        .padding(.horizontal)
                    } else {
                        CreativePropertySelectionCard(
                            properties: properties,
                            selectedPropertyId: $viewModel.reservationDraft.logementId
                        )
                        .padding(.horizontal)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentStep = .property
                            }
                        }
                    }
                    
                    // Date & Time Section
                    CreativeDateTimeCard(
                        date: $viewModel.reservationDraft.date,
                        isActive: currentStep == .datetime,
                        propertyId: viewModel.reservationDraft.logementId
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentStep = .datetime
                        }
                    }
                    
                    // Contact Information Section
                    CreativeContactCard(
                        phone: $viewModel.reservationDraft.contactPhone,
                        notes: $viewModel.reservationDraft.notes,
                        isActive: currentStep == .contact
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentStep = .contact
                        }
                    }
                    
                    // Submit Button with Animation
                    PremiumSubmitButton(
                        isSubmitting: viewModel.isSubmitting,
                        isEnabled: !viewModel.reservationDraft.logementId.isEmpty
                    ) {
                        Task { await viewModel.submitReservation() }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPropertiesIfNeeded()
        }
        .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.clearFeedback()
            }
        } message: {
            if let message = viewModel.successMessage {
                Text(message)
            }
        }
        .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearFeedback()
            }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }
    
    private func loadProperties() {
        Task {
            await loadPropertiesIfNeeded(force: true)
        }
    }
    
    private func loadPropertiesIfNeeded(force: Bool = false) async {
        guard properties.isEmpty || force else { 
            print("📋 Logements déjà chargés: \(properties.count) propriétés")
            return 
        }
        
        print("🔄 Chargement des logements...")
        isLoadingProperties = true
        defer { isLoadingProperties = false }
        
        do {
            print("�� Tentative de connexion au backend: \("http://172.18.5.91:3007")")
            properties = try await PropertyService.shared.fetchProperties()
            print("✅ \(properties.count) logements chargés depuis le backend")
            
            // Si le backend ne renvoie rien (vide), on force le chargement des démos pour que l'utilisateur puisse tester
            if properties.isEmpty {
                print("⚠️ Backend retourne une liste vide. Passage automatique aux données de démonstration.")
                throw NetworkError.serverError("Liste vide")
            }
            
            propertyLoadError = nil
        } catch {
            print("⚠️ Erreur : \(error)")
            print("🎭 Chargement de 6 logements de démonstration...")
            
            properties = [
                Property(id: "demo1", title: "Appartement Vue Mer", description: "Superbe appartement", price: 1200, images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267"], type: "Appartement", location: "La Marsa", nbrCollocateurMax: 3, nbrCollocateurActuel: 1, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365)),
                Property(id: "demo2", title: "Studio Centre Ville", description: "Studio cosy", price: 800, images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688"], type: "Studio", location: "Tunis Centre", nbrCollocateurMax: 1, nbrCollocateurActuel: 0, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365)),
                Property(id: "demo3", title: "Villa avec Piscine", description: "Grande villa", price: 2500, images: ["https://images.unsplash.com/photo-1600596542815-6000255addc2"], type: "Villa", location: "Carthage", nbrCollocateurMax: 5, nbrCollocateurActuel: 2, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365)),
                Property(id: "demo4", title: "Penthouse Moderne", description: "Penthouse", price: 3000, images: ["https://images.unsplash.com/photo-1512917774080-9991f1c4c750"], type: "Penthouse", location: "Gammarth", nbrCollocateurMax: 4, nbrCollocateurActuel: 1, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365)),
                Property(id: "demo5", title: "Maison Traditionnelle", description: "Maison avec jardin", price: 1500, images: ["https://images.unsplash.com/photo-1568605114967-8130f3a36994"], type: "Maison", location: "Sidi Bou Said", nbrCollocateurMax: 3, nbrCollocateurActuel: 2, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365)),
                Property(id: "demo6", title: "Loft Industriel", description: "Loft style industriel", price: 1800, images: ["https://images.unsplash.com/photo-1560448204-e02f11c3d0e2"], type: "Loft", location: "Lac 2", nbrCollocateurMax: 2, nbrCollocateurActuel: 0, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 365))
            ]
            
            print("✅ \(properties.count) logements de démonstration chargés")
            propertyLoadError = nil
        }
    }
}
    
struct AnimatedGradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.92, green: 0.94, blue: 0.99),
                Color(red: 0.94, green: 0.95, blue: 0.98)
            ],
            startPoint: animate ? .topLeading : .bottomLeading,
            endPoint: animate ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Hero Header
struct HeroHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.4, blue: 1.0),
                                Color(red: 0.4, green: 0.2, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Réserver une visite")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.2, blue: 0.3),
                            Color(red: 0.3, green: 0.3, blue: 0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Planifiez votre visite en quelques étapes")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Step Progress View
struct StepProgressView: View {
    let currentStep: VisitReservationView.ReservationStep
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(VisitReservationView.ReservationStep.allCases, id: \.self) { step in
                StepIndicator(
                    step: step,
                    isCompleted: step.rawValue <= currentStep.rawValue,
                    isCurrent: step == currentStep
                )
                
                if step != VisitReservationView.ReservationStep.allCases.last {
                    StepConnector(isCompleted: step.rawValue < currentStep.rawValue)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct StepIndicator: View {
    let step: VisitReservationView.ReservationStep
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 3)
                            .frame(width: 52, height: 52)
                    )
                
                Image(systemName: isCompleted ? "checkmark" : step.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCompleted ? .white : .gray)
            }
            .scaleEffect(isCurrent ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCurrent)
            
            Text(step.title)
                .font(.system(size: 11, weight: isCurrent ? .bold : .medium))
                .foregroundColor(isCompleted ? .blue : .gray)
        }
    }
}

struct StepConnector: View {
    let isCompleted: Bool
    
    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.blue : Color.gray.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .padding(.bottom, 30)
    }
}

// MARK: - Creative Property Selection Card
struct CreativePropertySelectionCard: View {
    let properties: [Property]
    @Binding var selectedPropertyId: String
    @State private var isExpanded = false
    
    private var selectedProperty: Property? {
        properties.first { $0.id == selectedPropertyId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Choisir un logement")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !selectedPropertyId.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                }
            }
            
            // Selection Button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    if let property = selectedProperty {
                        PropertyImageView(imageString: property.image)
                            .frame(width: 50, height: 50)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if let location = property.location {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 10))
                                    Text(location)
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Sélectionner un logement")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
            
            // Expanded List
            if isExpanded {
                if properties.isEmpty {
                    // Message quand aucun logement n'est disponible
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
                        
                        Text("Les logements seront chargés depuis le backend.\nVeuillez vérifier que le serveur est démarré.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.05))
                    )
                    .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 12) {
                        ForEach(properties) { property in
                            PropertyRowCard(
                                property: property,
                                isSelected: property.id == selectedPropertyId
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPropertyId = property.id
                                    isExpanded = false
                                }
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .blue.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct PropertyRowCard: View {
    let property: Property
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            PropertyImageView(imageString: property.image)
                .frame(width: 70, height: 70)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(property.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(1)
                
                if let location = property.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(location)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                        Text("\(Int(property.price)) DT")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    if let current = property.nbrCollocateurActuel,
                       let max = property.nbrCollocateurMax {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                            Text("\(current)/\(max)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue.opacity(0.05) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(color: isSelected ? .blue.opacity(0.2) : .clear, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Creative Date Time Card
struct CreativeDateTimeCard: View {
    @Binding var date: Date
    let isActive: Bool
    let propertyId: String // Added propertyId
    
    @State private var availableDates: Set<DateComponents> = []
    @State private var unavailableDates: Set<DateComponents> = []
    @State private var isLoadingAvailability = false
    @State private var showUnavailableAlert = false
    @State private var selectedUnavailableDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Date & Heure")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isLoadingAvailability {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Availability Info Banner
            if !isLoadingAvailability {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Disponibilités du colocataire")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Les dates grisées ou bloquées ne sont pas disponibles.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.08))
                )
            }
            
            VStack(spacing: 16) {
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Date de la visite", systemImage: "calendar.badge.clock")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Confirmation visuelle de la date
                        Text(date.formatted(date: .long, time: .omitted))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    DatePicker(
                        "",
                        selection: $date,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    .onChange(of: date) { newDate in
                        print("📅 Date sélectionnée : \(newDate)")
                        checkDateAvailability(newDate)
                    }
                }
                
                // Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Label("Heure de la visite", systemImage: "clock.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                }
                
                // Suggested Time Slots
                VStack(alignment: .leading, spacing: 12) {
                    Text("Créneaux suggérés")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(suggestedTimeSlots, id: \.self) { timeSlot in
                                TimeSlotButton(
                                    time: timeSlot,
                                    isSelected: isSameTime(date, timeSlot)
                                ) {
                                    selectTimeSlot(timeSlot)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isActive ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 2)
                )
                .shadow(color: isActive ? .orange.opacity(0.2) : .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        .task {
            // Future integration: Load real availability here
             print("✅ Prêt pour vérifier les disponibilités")
        }
        .alert("Colocataire non disponible", isPresented: $showUnavailableAlert) {
            Button("OK", role: .cancel) {
                // Reset to today's date or keep selected
            }
        } message: {
            Text("Le colocataire n'est pas disponible à cette date ou le logement est déjà réservé. Veuillez sélectionner une autre date.")
        }
    }
    
    // Suggested time slots (9 AM to 6 PM)
    private var suggestedTimeSlots: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var slots: [Date] = []
        
        for hour in [9, 11, 14, 16, 18] {
            if let slot = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                slots.append(slot)
            }
        }
        
        return slots
    }
    
    private func isSameTime(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let hour1 = calendar.component(.hour, from: date1)
        let minute1 = calendar.component(.minute, from: date1)
        let hour2 = calendar.component(.hour, from: date2)
        let minute2 = calendar.component(.minute, from: date2)
        
        return hour1 == hour2 && minute1 == minute2
    }
    
    private func selectTimeSlot(_ timeSlot: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: timeSlot)
        let minute = calendar.component(.minute, from: timeSlot)
        
        if let newDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
            date = newDate
        }
    }
    
    private func checkDateAvailability(_ selectedDate: Date) {
        // Logique de vérification (actuellement désactivée pour éviter les blocages)
        // À connecter avec le backend réel
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        if unavailableDates.contains(components) {
            showUnavailableAlert = true
        }
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                
                Text(formattedTime)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Creative Contact Card
struct CreativeContactCard: View {
    @Binding var phone: String
    @Binding var notes: String
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Contact")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Phone Input
                VStack(alignment: .leading, spacing: 8) {
                    Label("Numéro de téléphone", systemImage: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        TextField("Votre numéro", text: $phone)
                            .keyboardType(.phonePad)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                }
                
                // Notes Input
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notes (optionnel)", systemImage: "note.text")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .frame(height: 120)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isActive ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 2)
                )
                .shadow(color: isActive ? .purple.opacity(0.2) : .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: - Premium Submit Button
struct PremiumSubmitButton: View {
    let isSubmitting: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                    
                    Text("Confirmer la réservation")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: isEnabled ? [
                        Color(red: 0.2, green: 0.4, blue: 1.0),
                        Color(red: 0.4, green: 0.2, blue: 0.9)
                    ] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(
                color: isEnabled ? Color.blue.opacity(0.4) : .clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .disabled(!isEnabled || isSubmitting)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isEnabled)
    }
}

// MARK: - Loading Card
struct LoadingCardView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            Text("Chargement des logements...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Error Card
struct ErrorCardView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Réessayer")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .red.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Active Visit Warning Card
struct ActiveVisitWarningCard: View {
    let visit: Visit
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visite active en cours")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Vous ne pouvez avoir qu'une seule visite active")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Visit Details
            VStack(spacing: 12) {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Logement", systemImage: "house.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(visit.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Label("Statut", systemImage: visit.status.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(visit.status.displayName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(visit.status.badgeColor)
                            )
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Date", systemImage: "calendar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(visit.formattedDate)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Label("Heure", systemImage: "clock.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(visit.formattedTime)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.05))
            )
            
            // Info Message
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
                Text("Annulez ou terminez cette visite pour en réserver une nouvelle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.5), Color.red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.orange.opacity(0.15), radius: 15, x: 0, y: 8)
        )
    }
}

