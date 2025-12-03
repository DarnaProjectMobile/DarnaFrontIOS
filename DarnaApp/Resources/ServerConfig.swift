//
//  ServerConfig.swift
//  DarnaApp
//
//

import Foundation

enum ServerConfig {
    /// Adresse IP du serveur Nest hébergé sur la machine distante.
    /// Modifiez `host` si l'API tourne sur une autre machine/réseau.
    private static let host = "192.168.137.228"
    private static let port = 3007
    
    static var baseURL: String {
        "http://\(host):\(port)"
    }
}
