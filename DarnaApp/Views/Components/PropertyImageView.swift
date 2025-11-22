//
//  PropertyImageView.swift
//  DarnaApp
//

import SwiftUI

struct PropertyImageView: View {
    let imageString: String?
    let placeholder: String = "house"
    
    var body: some View {
        Group {
            if let imageString = imageString, !imageString.isEmpty {
                if imageString.hasPrefix("data:image") {
                    // Base64 image
                    if let base64String = imageString.components(separatedBy: ",").last,
                       let imageData = Data(base64Encoded: base64String),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderImage
                    }
                } else if let url = URL(string: imageString) {
                    // URL image
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(placeholder)
            .resizable()
            .scaledToFill()
    }
}

