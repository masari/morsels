import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func setupViews() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Morsels"
        titleLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let playButton = createMenuButton(title: "Play", backgroundColor: .systemGreen)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        let instructionsButton = createMenuButton(title: "Instructions", backgroundColor: .systemBlue)
        instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped), for: .touchUpInside)
        
        let configButton = createMenuButton(title: "Configuration", backgroundColor: .systemGray)
        configButton.addTarget(self, action: #selector(configButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [playButton, instructionsButton, configButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -60),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
    }
    
    func createMenuButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }

    @objc func playButtonTapped() {
        // Instantiate GameViewController from storyboard
        if let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") {
            navigationController?.pushViewController(gameViewController, animated: true)
        }
    }

    @objc func instructionsButtonTapped() {
        let instructionsVC = InstructionsViewController()
        navigationController?.pushViewController(instructionsVC, animated: true)
    }

    @objc func configButtonTapped() {
        let configVC = ConfigurationViewController()
        navigationController?.pushViewController(configVC, animated: true)
    }
}