import UIKit

class ConfigurationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        title = "Configuration"
        navigationController?.navigationBar.prefersLargeTitles = true

        // --- Level Selection ---
        let levelLabel = UILabel()
        levelLabel.text = "Level"
        levelLabel.font = UIFont.systemFont(ofSize: 17)

        let levelSegmentedControl = UISegmentedControl(items: ["Beginner", "Intermediate", "Expert"])
        levelSegmentedControl.selectedSegmentIndex = 0
        levelSegmentedControl.translatesAutoresizingMaskIntoConstraints = false

        let levelStack = UIStackView(arrangedSubviews: [levelLabel, levelSegmentedControl])
        levelStack.axis = .horizontal
        levelStack.spacing = 20
        
        // --- Pitch Control ---
        let pitchLabel = UILabel()
        pitchLabel.text = "Tone Pitch"
        pitchLabel.font = UIFont.systemFont(ofSize: 17)
        
        let pitchValueLabel = UILabel()
        pitchValueLabel.text = "800 Hz" // Default value
        pitchValueLabel.font = UIFont.systemFont(ofSize: 17)
        pitchValueLabel.textColor = .gray

        let pitchSlider = UISlider()
        pitchSlider.minimumValue = 400
        pitchSlider.maximumValue = 1200
        pitchSlider.value = Float(UserSettings.shared.tonePitch) // Load saved value
        pitchSlider.addTarget(self, action: #selector(pitchSliderChanged(_:)), for: .valueChanged)
        pitchSlider.addTarget(self, action: #selector(pitchSliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside]) // Add action for saving
        
        let pitchHeaderStack = UIStackView(arrangedSubviews: [pitchLabel, pitchValueLabel])
        pitchHeaderStack.axis = .horizontal
        pitchHeaderStack.distribution = .equalSpacing

        let pitchStack = UIStackView(arrangedSubviews: [pitchHeaderStack, pitchSlider])
        pitchStack.axis = .vertical
        pitchStack.spacing = 10
        
        // --- Main Stack ---
        let mainStack = UIStackView(arrangedSubviews: [levelStack, pitchStack])
        mainStack.axis = .vertical
        mainStack.spacing = 30
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.backgroundColor = .secondarySystemGroupedBackground
        mainStack.layer.cornerRadius = 12

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Update label with initial value
        pitchSliderChanged(pitchSlider)
    }
    
    @objc private func pitchSliderChanged(_ sender: UISlider) {
        if let pitchValueLabel = findPitchValueLabel(in: view) {
            let value = Int(sender.value)
            pitchValueLabel.text = "\(value) Hz"
        }
    }
    
    @objc private func pitchSliderDidEndEditing(_ sender: UISlider) {
        let newPitch = Double(sender.value)
        UserSettings.shared.tonePitch = newPitch
        MorseCodePlayer.shared.updateToneFrequency(newPitch)
    }
    
    // Helper to find the label to update
    private func findPitchValueLabel(in view: UIView) -> UILabel? {
        for subview in view.subviews {
            if let stackView = subview as? UIStackView {
                if let foundLabel = findPitchValueLabel(in: stackView) {
                    return foundLabel
                }
            } else if let label = subview as? UILabel, let text = label.text, text.contains("Hz") {
                return label
            }
        }
        return nil
    }
}