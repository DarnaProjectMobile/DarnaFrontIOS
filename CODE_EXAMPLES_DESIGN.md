# 💻 Exemples de Code - Design Patterns

## Composants Réutilisables

### 1. Cercle avec Icône et Dégradé

```swift
// Utilisé pour les indicateurs de statut et les icônes de section
ZStack {
    Circle()
        .fill(
            LinearGradient(
                colors: [color1, color2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(width: size, height: size)
        .shadow(color: color1.opacity(0.4), radius: shadowRadius, x: 0, y: shadowY)
    
    Image(systemName: iconName)
        .font(.system(size: iconSize, weight: .semibold))
        .foregroundColor(.white)
}
```

**Exemples d'utilisation:**
```swift
// Header de carte (48x48)
statusIndicator(colors: [.blue, .purple], size: 48, icon: "clock.fill")

// Icône de section (40x40)
sectionIcon(colors: [.orange, .red], size: 40, icon: "calendar.badge.clock")

// Header principal (70x70)
mainIcon(colors: selectedSection.gradient, size: 70, icon: selectedSection.icon)
```

---

### 2. Bouton avec Dégradé et Ombre

```swift
Button(action: action) {
    HStack(spacing: 8) {
        Image(systemName: icon)
            .font(.system(size: 18))
        Text(title)
            .font(.system(size: 15, weight: .bold))
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .background(
        LinearGradient(
            colors: [color, color.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .cornerRadius(12)
    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
}
```

**Exemple:**
```swift
gradientButton(
    title: "Accepter",
    icon: "checkmark.circle.fill",
    color: .green,
    action: { /* action */ }
)
```

---

### 3. Chip de Filtre Moderne

```swift
extension View {
    func modernChipStyle(isSelected: Bool, color: Color) -> some View {
        self
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}
```

**Utilisation:**
```swift
Text("Toutes")
    .modernChipStyle(isSelected: true, color: .blue)

HStack(spacing: 6) {
    Image(systemName: "clock.fill")
    Text("En attente")
}
.modernChipStyle(isSelected: false, color: .orange)
```

---

### 4. Card avec Glassmorphism

```swift
struct GlassmorphicCard<Content: View>: View {
    let content: Content
    let borderColor: Color
    
    init(borderColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                borderColor.opacity(0.3),
                                borderColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: borderColor.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}
```

**Utilisation:**
```swift
GlassmorphicCard(borderColor: .blue) {
    VStack {
        // Contenu de la carte
    }
    .padding(20)
}
```

---

### 5. Section avec Icône Circulaire

```swift
struct IconSection: View {
    let icon: String
    let colors: [Color]
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}
```

**Utilisation:**
```swift
IconSection(
    icon: "person.fill",
    colors: [.blue, .purple],
    title: "Demandeur",
    subtitle: "Jean Dupont"
)

IconSection(
    icon: "calendar.badge.clock",
    colors: [.orange, .red],
    title: "Date",
    subtitle: "15 Décembre 2025"
)
```

---

### 6. Loading Spinner Animé

```swift
struct AnimatedSpinner: View {
    @State private var isAnimating = false
    let colors: [Color]
    let size: CGFloat
    
    init(colors: [Color] = [.blue, .purple], size: CGFloat = 60) {
        self.colors = colors
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(colors[0].opacity(0.2), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
```

**Utilisation:**
```swift
VStack(spacing: 20) {
    AnimatedSpinner(colors: [.blue, .purple], size: 60)
    Text("Chargement...")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
}
```

---

### 7. Empty State Moderne

```swift
struct ModernEmptyState: View {
    let icon: String
    let message: String
    let iconColors: [Color]
    
    init(icon: String, message: String, iconColors: [Color] = [.gray, .gray.opacity(0.6)]) {
        self.icon = icon
        self.message = message
        self.iconColors = iconColors
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: iconColors.map { $0.opacity(0.1) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
    }
}
```

**Utilisation:**
```swift
ModernEmptyState(
    icon: "calendar.badge.plus",
    message: "Aucune visite pour l'instant\nRéservez votre première visite"
)
```

---

### 8. Animated Background

```swift
struct AnimatedGradientBackground: View {
    @State private var animate = false
    let colors: [Color]
    let duration: Double
    
    init(
        colors: [Color] = [
            Color(red: 0.96, green: 0.97, blue: 0.99),
            Color(red: 0.94, green: 0.95, blue: 0.98),
            Color(red: 0.95, green: 0.96, blue: 0.99)
        ],
        duration: Double = 4
    ) {
        self.colors = colors
        self.duration = duration
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animate ? .topLeading : .bottomLeading,
            endPoint: animate ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
```

**Utilisation:**
```swift
ZStack {
    AnimatedGradientBackground()
        .ignoresSafeArea()
    
    // Contenu de la vue
}
```

---

### 9. Segmented Control Moderne

```swift
struct ModernSegmentedControl<T: Hashable & Identifiable>: View {
    let items: [T]
    @Binding var selection: T
    let itemIcon: (T) -> String
    let itemTitle: (T) -> String
    let itemGradient: (T) -> [Color]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { item in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = item
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: itemIcon(item))
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(itemTitle(item))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(selection == item ? .white : .primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selection == item {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: itemGradient(item),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: itemGradient(item)[0].opacity(0.4), radius: 15, x: 0, y: 8)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.5))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}
```

**Utilisation:**
```swift
ModernSegmentedControl(
    items: sections,
    selection: $selectedSection,
    itemIcon: { $0.icon },
    itemTitle: { $0.rawValue },
    itemGradient: { $0.gradient }
)
```

---

### 10. Texte avec Dégradé

```swift
extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
```

**Utilisation:**
```swift
Text("Gestion des visites")
    .font(.system(size: 32, weight: .bold))
    .gradientForeground(colors: [
        Color(red: 0.1, green: 0.1, blue: 0.2),
        Color(red: 0.2, green: 0.2, blue: 0.3)
    ])
```

---

## Animations Communes

### 1. Spring Animation
```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    // Changements d'état
}
```

### 2. Scale Effect avec Animation
```swift
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
```

### 3. Transition Asymétrique
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

### 4. Rotation Continue
```swift
.rotationEffect(.degrees(isAnimating ? 360 : 0))
.onAppear {
    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
        isAnimating = true
    }
}
```

---

## Bonnes Pratiques

### 1. Réutilisabilité
✅ Créer des composants génériques
✅ Utiliser des extensions de View
✅ Paramétrer les couleurs et tailles

### 2. Performance
✅ Utiliser LazyVStack pour les listes
✅ Limiter les animations simultanées
✅ Optimiser les dégradés

### 3. Accessibilité
✅ Tailles minimales de toucher (44pt)
✅ Contraste suffisant
✅ Labels descriptifs

### 4. Cohérence
✅ Utiliser les mêmes animations partout
✅ Respecter les espacements définis
✅ Maintenir la palette de couleurs

---

**Créé le** : 29 Novembre 2025  
**Version** : 2.0  
**Langage** : SwiftUI
