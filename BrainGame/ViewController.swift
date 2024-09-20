import UIKit

class ViewController: UIViewController {

    var themeID: String?
    var assignedImages: [String] = []
    var imageViews: [UIImageView] = []
    var selectedCards: [UIImageView] = []
    
    var defaultImageURL: String? // La URL de la imagen por defecto

    let numberOfRows = 4
    let numberOfColumns = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let themeID = themeID {
            loadTheme(for: themeID)
        }
    }

    // Cargar la información del tema seleccionado
    func loadTheme(for themeID: String) {
        guard let url = URL(string: "http://ec2-3-95-197-227.compute-1.amazonaws.com:8081/api/themes/\(themeID)") else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error al cargar el tema: \(error)")
                return
            }
            

            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Error: código de estado HTTP \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Respuesta del servidor: \(responseString)") // Imprime la respuesta completa para ver qué se recibe
                    }
                    return
                }
            }

            guard let data = data else {
                print("No se recibió data")
                return
            }

            //  decodificar el JSON
            do {
                let themeResponse = try JSONDecoder().decode(ThemeResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.setupGame(with: themeResponse)
                }
            } catch {
                print("Error al decodificar el JSON: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Respuesta completa: \(responseString)") // Imprime el JSON recibido para depuración
                }
            }
        }.resume()
    }

    func setupGame(with themeResponse: ThemeResponse) {

        setBackgroundImage(named: themeResponse.backgroundImage)
        
        defaultImageURL = themeResponse.backgroundCard
        
        assignedImages = generateRandomImages(from: themeResponse.images)
        
        setupImageViews()
    }


    func generateRandomImages(from images: [String]) -> [String] {
        var duplicatedImages = images + images
        duplicatedImages.shuffle() // Mezclar las imágenes aleatoriamente
        print("Imágenes asignadas a las cartas: \(duplicatedImages)")
        return duplicatedImages
    }


    func setupImageViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        for _ in 0..<numberOfRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 10
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually

            for _ in 0..<numberOfColumns {
                let imageView = createCardImageView()
                rowStackView.addArrangedSubview(imageView)
                imageViews.append(imageView)
            }

            stackView.addArrangedSubview(rowStackView)
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }

    // Crear una vista de imagen para cada carta con la imagen por defecto
    func createCardImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // Habilitar la interacción
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Cargar la imagen por defecto
        if let defaultImageURL = defaultImageURL {
            loadImage(from: defaultImageURL) { image in
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }

    // Manejar el toque en una carta
    @objc func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let index = imageViews.firstIndex(of: tappedImageView) else { return }
        
        let imageURL = assignedImages[index]
        print("URL de la imagen para esta carta: \(imageURL)")

        // Cargar la imagen seleccionada
        loadImage(from: imageURL) { [weak self] image in
            DispatchQueue.main.async {
                tappedImageView.image = image
                self?.selectedCards.append(tappedImageView)

                if self?.selectedCards.count == 2 {
                    self?.checkForMatch()
                }
            }
        }
    }

    // Verificar si las dos cartas seleccionadas son iguales
    func checkForMatch() {
        guard selectedCards.count == 2 else { return }

        let firstCardIndex = imageViews.firstIndex(of: selectedCards[0])!
        let secondCardIndex = imageViews.firstIndex(of: selectedCards[1])!
        
        if assignedImages[firstCardIndex] == assignedImages[secondCardIndex] {
            print("¡Pareja encontrada!")
            selectedCards.removeAll() // Limpiar las cartas seleccionadas
        } else {
            // Si no coinciden, ocultarlas nuevamente después de un pequeño retraso
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                // Volver a poner la imagen por defecto
                if let defaultImageURL = self?.defaultImageURL {
                    self?.loadImage(from: defaultImageURL) { image in
                        DispatchQueue.main.async {
                            self?.selectedCards[0].image = image
                            self?.selectedCards[1].image = image
                            self?.selectedCards.removeAll() // Limpiar las cartas seleccionadas
                        }
                    }
                }
            }
        }
    }

    // Cargar imagen desde URL
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    // Establecer la imagen de fondo
    func setBackgroundImage(named imageName: String) {
        guard let url = URL(string: imageName) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                backgroundImage.image = image
                backgroundImage.contentMode = .scaleAspectFill
                self.view.addSubview(backgroundImage)
                self.view.sendSubviewToBack(backgroundImage)
            }
        }.resume()
    }
}

struct ThemeResponse: Codable {
    let theme: String
    let images: [String] 
    let backgroundImage: String
    let backgroundCard: String
}




