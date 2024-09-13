//
//  ViewController.swift
//  BrainGame
//
//  Created by Jose Pernia on 2024-09-12.
//

import UIKit

class ViewController: UIViewController {
    
    // Propiedad para recibir el tema seleccionado
    var selectedTheme: String?
    
    let numberOfRows = 5
    let numberOfColumns = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la vista según el tema seleccionado
        if let theme = selectedTheme {
            configureTheme(theme)
        }
        
        // Crear el UIStackView principal para las cartas
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        for _ in 0..<numberOfRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10
            
            for _ in 0..<numberOfColumns {
                let cardView = createCardView()
                rowStackView.addArrangedSubview(cardView)
            }
            
            mainStackView.addArrangedSubview(rowStackView)
        }
    }
    
    // Configurar el fondo y las imágenes de cartas según la temática seleccionada
    func configureTheme(_ theme: String) {
        switch theme {
        case "Vida Marina":
            setBackgroundImage(named: "background")
        case "Espacio Sideral":
            setBackgroundImage(named: "background")
            // Aquí podrías cambiar las imágenes de las cartas también
        case "Animales":
            setBackgroundImage(named: "background")
        case "Autos":
            setBackgroundImage(named: "background")
        case "Banderas":
            setBackgroundImage(named: "background")
        default:
            setBackgroundImage(named: "background")
        }
    }
    
    func createCardView() -> UIView {
        let card = UIButton()
        card.setImage(UIImage(named: "card"), for: .normal) // Aquí puedes cambiar la imagen según la temática si lo deseas
        card.imageView?.contentMode = .scaleAspectFit
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        return card
    }
    
    func setBackgroundImage(named imageName: String) {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
}
