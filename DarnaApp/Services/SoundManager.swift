//
//  SoundManager.swift
//  DarnaApp
//

import Foundation
import AVFoundation
import UIKit // Pour NSDataAsset

/// Gestionnaire centralisé des effets sonores de la roulette
final class SoundManager: NSObject {
    static let shared = SoundManager()
    
    private var spinPlayer: AVAudioPlayer?
    private var winPlayer: AVAudioPlayer?
    private var losePlayer: AVAudioPlayer?
    private let queue = DispatchQueue(label: "sound-manager-queue")
    
    private override init() {
        super.init()
        configureAudioSession()
    }
    
    /// Lecture du son de rotation
    func playSpinSound() {
        queue.async { [weak self] in
            guard let self else { return }
            self.playSound(named: "spin", cachedPlayer: &self.spinPlayer)
        }
    }
    
    /// Lecture du son de victoire
    func playWinSound() {
        queue.async { [weak self] in
            guard let self else { return }
            self.playSound(named: "win", cachedPlayer: &self.winPlayer)
        }
    }
    
    /// Lecture du son d'échec
    func playLoseSound() {
        queue.async { [weak self] in
            guard let self else { return }
            self.playSound(named: "lose", cachedPlayer: &self.losePlayer)
        }
    }
}

// MARK: - Private helpers
private extension SoundManager {
    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .playback pour jouer même en mode silencieux, tout en mélangeant avec d'autres apps
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            debugPrint("SoundManager - Audio session error:", error)
        }
    }
    
    func playSound(named name: String, cachedPlayer: inout AVAudioPlayer?) {
        do {
            let player = try makePlayerIfNeeded(named: name, cachedPlayer: &cachedPlayer)
            player?.currentTime = 0
            player?.play()
        } catch {
            debugPrint("SoundManager - Unable to play \(name):", error)
        }
    }
    
    /// Cherche d'abord un Data Asset (Assets.xcassets), puis un fichier du bundle principal.
    func makePlayerIfNeeded(named name: String, cachedPlayer: inout AVAudioPlayer?) throws -> AVAudioPlayer? {
        if let cached = cachedPlayer {
            return cached
        }
        
        if let asset = NSDataAsset(name: name) {
            let player = try AVAudioPlayer(data: asset.data)
            player.prepareToPlay()
            cachedPlayer = player
            return player
        }
        
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            cachedPlayer = player
            return player
        }
        
        debugPrint("SoundManager - Audio file '\(name).mp3' not found in assets or bundle.")
        return nil
    }
}
