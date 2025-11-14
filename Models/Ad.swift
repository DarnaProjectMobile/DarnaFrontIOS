//
//  Ad.swift
//  DarnaApp
//

import Foundation

enum AdType: String, CaseIterable, Identifiable, Codable {
    case reduction = "Réduction"
    case promo = "Promo"
    case bonPlan = "Bon plan"
    
    var id: String { rawValue }
}

struct Ad: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var brand: String
    var type: AdType
    var discountText: String
    var description: String
    var promoCode: String?
    var startDate: Date
    var endDate: Date
    var imageURL: String?
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}

// MARK: - DTO pour correspondre au backend
struct AdDTO: Codable {
    let id: UUID?
    let title: String
    let brand: String
    let type: String
    let discountText: String
    let description: String
    let promoCode: String?
    let startDate: String
    let endDate: String
    let imageURL: String?
}

// MARK: - Extensions pour convertir entre Ad et AdDTO
extension Ad {
    init(from dto: AdDTO) {
        let dateFormatter = ISO8601DateFormatter()
        self.id = dto.id ?? UUID()
        self.title = dto.title
        self.brand = dto.brand
        self.type = AdType(rawValue: dto.type) ?? .reduction
        self.discountText = dto.discountText
        self.description = dto.description
        self.promoCode = dto.promoCode
        self.startDate = dateFormatter.date(from: dto.startDate) ?? Date()
        self.endDate = dateFormatter.date(from: dto.endDate) ?? Date()
        self.imageURL = dto.imageURL
    }
    
    func toDTO() -> AdDTO {
        let dateFormatter = ISO8601DateFormatter()
        return AdDTO(
            id: id,
            title: title,
            brand: brand,
            type: type.rawValue,
            discountText: discountText,
            description: description,
            promoCode: promoCode,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            imageURL: imageURL
        )
    }
}
