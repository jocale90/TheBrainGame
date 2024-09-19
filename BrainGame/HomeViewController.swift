import UIKit

class HomeViewController: UIViewController {
    
    var themes: [Theme] = [] // Aquí almacenamos las temáticas que vienen del API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Agregar la imagen de fondo
        setBackgroundImage(named: "back")
        
        // Llamamos al API para obtener los temas
        fetchThemes()
    }
    
    // Función para configurar la imagen de fondo
    func setBackgroundImage(named imageName: String) {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage) // Enviamos la imagen al fondo
        
        // Aseguramos que la imagen se ajuste a toda la pantalla
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Función para obtener las temáticas desde el API
    func fetchThemes() {
        guard let url = URL(string: "http://ec2-3-95-197-227.compute-1.amazonaws.com:8081/api/themes") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Aquí deberías agregar el token de autenticación en el header si es necesario
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Hacemos la llamada a la API usando URLSession
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error al obtener las temáticas: \(error)")
                return
            }
            
            guard let data = data else {
                print("No se recibió data del servidor")
                return
            }
            
            // Decodificamos la respuesta en un array de Theme
            do {
                let themes = try JSONDecoder().decode([Theme].self, from: data)
                DispatchQueue.main.async {
                    self?.themes = themes
                    self?.setupThemeButtons() // Creamos los botones una vez que tenemos los temas
                }
            } catch {
                print("Error al decodificar el JSON: \(error)")
            }
        }.resume()
    }
    
    // Función para configurar los botones con los temas obtenidos
    func setupThemeButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Para cada tema obtenido del API, creamos un botón con el nombre del tema
        for theme in themes {
            let button = UIButton(type: .system)
            button.tag = themes.firstIndex(of: theme) ?? 0 // Asignamos un tag para identificar el tema
            button.setTitle(theme.name, for: .normal) // Usamos el nombre del tema como título
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            // Añadir la acción al botón
            button.addTarget(self, action: #selector(themeSelected(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        
        // Configuramos las restricciones para el stackView
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Función que se llama cuando el usuario selecciona un tema
    @objc func themeSelected(_ sender: UIButton) {
        let selectedTheme = themes[sender.tag]
        print("Tema seleccionado: \(selectedTheme.id)")
        
        // Navegamos al ViewController pasando el themeID
        let gameVC = ViewController()
        gameVC.themeID = selectedTheme.id // Asigna el ID del tema a la propiedad themeID
        navigationController?.pushViewController(gameVC, animated: true)
    }

}

