//
//  ThemeImagesResponse.swift
//  BrainGame
//
//  Created by Jose Pernia on 2024-09-17.
//

import Foundation

// Modelo para la respuesta de imágenes de una temática
struct ThemeImagesResponse: Codable {
    let theme: String
    let images: [String]
}
