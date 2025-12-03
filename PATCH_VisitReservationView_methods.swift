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
            print("📡 Tentative de connexion au backend: \(ServerConfig.baseURL)")
            properties = try await PropertyService.shared.fetchProperties()
            print("✅ \(properties.count) logements chargés depuis le backend")
            propertyLoadError = nil
        } catch {
            print("⚠️ Erreur : \(error)")
            print("🎭 Chargement de 6 logements de démonstration...")
            
            // FALLBACK: Données de test
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
