//
//  Booking.swift
//  DarnaApp
//

import Foundation

struct Booking: Codable, Identifiable {
    var id: String {
        // Use user ID + booking date as unique identifier if no ID is provided
        if let bookingId = _id {
            return bookingId
        } else if let userId = user?.id {
            return "\(userId)-\(bookingStartDate.timeIntervalSince1970)"
        } else {
            return UUID().uuidString
        }
    }
    private let _id: String?
    let user: BookingUser?
    let bookingStartDate: Date
    
    enum CodingKeys: String, CodingKey {
        case _id
        case user
        case bookingStartDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try? container.decode(String.self, forKey: ._id)
        
        // Handle user - can be string ID or populated object
        if let userString = try? container.decode(String.self, forKey: .user) {
            user = BookingUser(id: userString, username: nil, email: nil, numTel: nil, gender: nil, dateDeNaissance: nil)
        } else if let userObject = try? container.decode(BookingUser.self, forKey: .user) {
            user = userObject
        } else {
            user = nil
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let dateString = try? container.decode(String.self, forKey: .bookingStartDate) {
            bookingStartDate = isoFormatter.date(from: dateString) ?? Date()
        } else {
            bookingStartDate = Date()
        }
    }
}

struct BookingUser: Codable {
    let id: String?
    let username: String?
    let email: String?
    let numTel: String?  // Backend uses numTel
    let gender: String?
    let dateDeNaissance: String?  // Backend uses dateDeNaissance as string
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case email
        case numTel
        case gender
        case dateDeNaissance
    }
    
    init(id: String?, username: String?, email: String?, numTel: String?, gender: String?, dateDeNaissance: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.numTel = numTel
        self.gender = gender
        self.dateDeNaissance = dateDeNaissance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decode(String.self, forKey: .id)
        username = try? container.decode(String.self, forKey: .username)
        email = try? container.decode(String.self, forKey: .email)
        numTel = try? container.decode(String.self, forKey: .numTel)
        gender = try? container.decode(String.self, forKey: .gender)
        dateDeNaissance = try? container.decode(String.self, forKey: .dateDeNaissance)
    }
    
    // Computed properties for easier access
    var phone: String? { numTel }
    var dateOfBirth: Date? {
        guard let dateString = dateDeNaissance else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.date(from: dateString)
    }
}

struct PropertyWithBookings {
    let property: Property
    let bookings: [Booking]  // Confirmed bookings
    let attendingListBookings: [Booking]  // Pending bookings waiting for approval
    
    init(property: Property, bookings: [Booking], attendingListBookings: [Booking] = []) {
        self.property = property
        self.bookings = bookings
        self.attendingListBookings = attendingListBookings
    }
}

