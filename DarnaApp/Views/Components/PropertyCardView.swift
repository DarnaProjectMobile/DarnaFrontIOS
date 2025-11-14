//
//  PropertyCardView.swift
//  DarnaApp
//

import SwiftUI

struct PropertyCardView: View {
    let property: Property
    var canManage: Bool = false
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(property.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(String(format: "%.0f DT", property.price))
                    .font(.subheadline).bold()
                    .foregroundColor(AppTheme.primary)
            }
            
            if let description = property.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(3)
            }
            
            if let location = property.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            if !property.tags.isEmpty {
                FlowLayout(tags: property.tags)
            }
            
            if let createdAt = property.createdAt {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            if canManage {
                HStack(spacing: 12) {
                    Button {
                        onEdit?()
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.primary.opacity(0.12))
                            .foregroundColor(AppTheme.primary)
                            .clipShape(Capsule())
                    }
                    
                    Button(role: .destructive) {
                        onDelete?()
                    } label: {
                        Label("Supprimer", systemImage: "trash.fill")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

private struct FlowLayout: View {
    let tags: [String]
    
    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 64,
            data: tags,
            spacing: 8,
            alignment: .leading
        ) { tag in
            Text(tag)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.primaryLight)
                .foregroundColor(AppTheme.primary)
                .clipShape(Capsule())
        }
    }
}

private struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                                }
                            )
                            .onPreferenceChange(SizePreferenceKey.self) { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        for element in data {
            let elementSize = elementsSize[element, default: .zero]
            let elementWidth = elementSize.width + spacing
            
            if currentRowWidth + elementWidth > availableWidth {
                rows.append([element])
                currentRowWidth = elementWidth
            } else {
                rows[rows.count - 1].append(element)
                currentRowWidth += elementWidth
            }
        }
        
        return rows
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        // no-op
    }
}

