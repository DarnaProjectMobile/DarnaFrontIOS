//
//  QRCodeView.swift
//  DarnaApp
//
//  Composant pour générer et afficher des QR codes

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let qrData: String
    var size: CGFloat = 200
    
    var body: some View {
        if let qrImage = generateQRCode(from: qrData) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: size * 0.5))
                .foregroundColor(.gray)
                .frame(width: size, height: size)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        // Si c'est une data URL base64, extraire les données
        var dataString = string
        if string.hasPrefix("data:image") {
            // Extraire la partie base64 après la virgule
            if let commaIndex = string.firstIndex(of: ",") {
                dataString = String(string[string.index(after: commaIndex)...])
            }
        }
        
        // Si c'est du base64, décoder
        if let base64Data = Data(base64Encoded: dataString),
           let image = UIImage(data: base64Data) {
            return image
        }
        
        // Sinon, générer un QR code à partir du texte
        let filter = CIFilter.qrCodeGenerator()
        let context = CIContext()
        
        guard let data = dataString.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

