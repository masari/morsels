import UIKit

protocol PauseMenuDelegate: AnyObject {
    func didTapContinue()
    func didTapQuit()
}

class PauseMenuViewController: UIViewController {

    weak var delegate: PauseMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let titleLabel = UILabel()
        titleLabel.text = "Paused"
        titleLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let continueButton = createMenuButton(title: "Continue", backgroundColor: .systemGreen)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        let quitButton = createMenuButton(title: "Quit", backgroundColor: .systemRed)
        quitButton.addTarget(self, action: #selector(quitButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [continueButton, quitButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -40),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
    }

    private func createMenuButton(title: String, backgroundColor: UIColor) -> UIButton {
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

    @objc private func continueButtonTapped() {
        delegate?.didTapContinue()
    }

    @objc private func quitButtonTapped() {
        delegate?.didTapQuit()
    }
}