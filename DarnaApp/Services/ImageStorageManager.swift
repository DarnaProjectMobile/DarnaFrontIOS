//
//  ImageStorageManager.swift
//  DarnaApp
//
//  Gestionnaire de stockage local des images uploadées

import Foundation
import UIKit

/// Gère le stockage local des images uploadées pour persistance après déconnexion
final class ImageStorageManager {
    static let shared = ImageStorageManager()
    
    private let fileManager = FileManager.default
    private var imagesDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesPath = documentsPath.appendingPathComponent("PubliciteImages", isDirectory: true)
        
        // Créer le dossier s'il n'existe pas
        if !fileManager.fileExists(atPath: imagesPath.path) {
            try? fileManager.createDirectory(at: imagesPath, withIntermediateDirectories: true)
        }
        
        return imagesPath
    }
    
    private init() {}
    
    /// Sauvegarde une image localement et retourne le chemin relatif
    /// - Parameters:
    ///   - image: L'image à sauvegarder
    ///   - publiciteId: L'ID de la publicité (optionnel, pour associer l'image)
    /// - Returns: Le nom du fichier sauvegardé ou nil en cas d'erreur
    func saveImage(_ image: UIImage, publiciteId: String? = nil) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let fileName: String
        if let id = publiciteId {
            fileName = "\(id)_\(UUID().uuidString).jpg"
        } else {
            fileName = "\(UUID().uuidString).jpg"
        }
        
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("ImageStorageManager - Erreur lors de la sauvegarde: \(error)")
            return nil
        }
    }
    
    /// Charge une image depuis le stockage local
    /// - Parameter fileName: Le nom du fichier
    /// - Returns: L'image chargée ou nil si non trouvée
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    /// Charge toutes les images associées à une publicité
    /// - Parameter publiciteId: L'ID de la publicité
    /// - Returns: Un tableau d'images
    func loadImagesForPublicite(_ publiciteId: String) -> [UIImage] {
        guard let files = try? fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        
        return files
            .filter { $0.lastPathComponent.hasPrefix("\(publiciteId)_") }
            .compactMap { url -> UIImage? in
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else {
                    return nil
                }
                return image
            }
    }
    
    /// Retourne le nom du fichier de la première image associée à une publicité
    /// - Parameter publiciteId: L'ID de la publicité
    /// - Returns: Le nom du fichier ou nil
    func getFirstImageFileName(for publiciteId: String) -> String? {
        guard let files = try? fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        return files
            .first(where: { $0.lastPathComponent.hasPrefix("\(publiciteId)_") })?
            .lastPathComponent
    }
    
    /// Supprime une image du stockage local
    /// - Parameter fileName: Le nom du fichier à supprimer
    func deleteImage(fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Supprime toutes les images associées à une publicité
    /// - Parameter publiciteId: L'ID de la publicité
    func deleteImagesForPublicite(_ publiciteId: String) {
        guard let files = try? fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        files
            .filter { $0.lastPathComponent.hasPrefix("\(publiciteId)_") }
            .forEach { url in
                try? fileManager.removeItem(at: url)
            }
    }
    
    /// Convertit une image sauvegardée localement en base64 pour l'envoi au backend
    /// - Parameter fileName: Le nom du fichier
    /// - Returns: La chaîne base64 ou nil
    func imageToBase64(fileName: String) -> String? {
        guard let image = loadImage(fileName: fileName),
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }
}
