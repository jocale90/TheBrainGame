//
//  HomeViewController.swift
//  BrainGame
//
//  Created by Jose Pernia on 2024-09-12.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupThemeButtons()
    }
    
    // Configurar los botones de los temas
    func setupThemeButtons() {
        let themes = ["Vida Marina", "Espacio Sideral", "Animales", "Autos", "Banderas"]
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Crear un botón por cada temática
        for theme in themes {
            let button = UIButton(type: .system)
            button.setTitle(theme, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.addTarget(self, action: #selector(themeSelected(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        
        // Centramos el stackView en la vista
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Función que se llama cuando el usuario selecciona un tema
    @objc func themeSelected(_ sender: UIButton) {
        guard let theme = sender.titleLabel?.text else { return }
        let gameVC = ViewController() // Instanciar el controlador del juego
        gameVC.selectedTheme = theme // Pasar la temática seleccionada
        navigationController?.pushViewController(gameVC, animated: true) // Navegar al controlador del juego
    }
}

