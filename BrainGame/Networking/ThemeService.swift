//
//  ThemeService.swift
//  BrainGame
//
//  Created by Jose Pernia on 2024-09-17.
//

import Foundation

class ThemeService {
    
    static let shared = ThemeService()
    
    let baseURL = "http://ec2-3-95-197-227.compute-1.amazonaws.com:8081/api"
    
    // Función para obtener el token guardado
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // Obtener las temáticas disponibles
    func fetchThemes(completion: @escaping ([Theme]?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/themes") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Agregar el token en los headers
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                let themes = try JSONDecoder().decode([Theme].self, from: data)
                completion(themes, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    // Obtener las imágenes de una temática específica
    func fetchImages(for themeId: String, completion: @escaping ([String]?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/themes/\(themeId)/images") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Agregar el token en los headers
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                let themeImagesResponse = try JSONDecoder().decode(ThemeImagesResponse.self, from: data)
                completion(themeImagesResponse.images, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

