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

        // CREATE SCROLL VIEW
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
        // --- Learning Level Selection ---
        let learningLabel = UILabel()
        learningLabel.text = "Starting Level"
        learningLabel.font = UIFont.systemFont(ofSize: 17)

        let learningSegmentedControl = UISegmentedControl(items: ["Beginner", "Intermediate", "Advanced"])
        learningSegmentedControl.selectedSegmentIndex = stageToSegmentIndex(UserSettings.shared.initialLearningStage)
        learningSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        learningSegmentedControl.addTarget(self, action: #selector(learningLevelChanged(_:)), for: .valueChanged)

        let learningStack = UIStackView(arrangedSubviews: [learningLabel, learningSegmentedControl])
        learningStack.axis = .vertical
        learningStack.spacing = 10
        
        let learningDescription = UILabel()
        learningDescription.text = getLevelDescription(for: learningSegmentedControl.selectedSegmentIndex)
        learningDescription.font = UIFont.systemFont(ofSize: 14)
        learningDescription.textColor = .secondaryLabel
        learningDescription.numberOfLines = 3
        learningDescription.tag = 999
        learningDescription.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let learningStackWithDesc = UIStackView(arrangedSubviews: [learningStack, learningDescription])
        learningStackWithDesc.axis = .vertical
        learningStackWithDesc.spacing = 5
        
        // --- Speech Recognition Toggle ---
        let speechLabel = UILabel()
        speechLabel.text = "Voice Input"
        speechLabel.font = UIFont.systemFont(ofSize: 17)
        
        let speechSwitch = UISwitch()
        speechSwitch.isOn = UserSettings.shared.isSpeechRecognitionEnabled
        speechSwitch.addTarget(self, action: #selector(speechToggleChanged(_:)), for: .valueChanged)
        
        let speechHeaderStack = UIStackView(arrangedSubviews: [speechLabel, speechSwitch])
        speechHeaderStack.axis = .horizontal
        speechHeaderStack.distribution = .equalSpacing
        
        let speechDescription = UILabel()
        speechDescription.text = "Say letter names (A-Z) or phonetic alphabet (Alpha, Bravo, etc.) to select pigs"
        speechDescription.font = UIFont.systemFont(ofSize: 14)
        speechDescription.textColor = .secondaryLabel
        speechDescription.numberOfLines = 0
        
        let speechStackWithDesc = UIStackView(arrangedSubviews: [speechHeaderStack, speechDescription])
        speechStackWithDesc.axis = .vertical
        speechStackWithDesc.spacing = 5
        
        // --- Pitch Control (EDITABLE) ---
        let pitchLabel = UILabel()
        pitchLabel.text = "Tone Pitch"
        pitchLabel.font = UIFont.systemFont(ofSize: 17)
        
        let pitchValueLabel = UILabel()
        pitchValueLabel.text = "\(Int(UserSettings.shared.tonePitch)) Hz"
        pitchValueLabel.font = UIFont.systemFont(ofSize: 17)
        pitchValueLabel.textColor = .gray
        pitchValueLabel.tag = 111

        let pitchSlider = UISlider()
        pitchSlider.minimumValue = 400
        pitchSlider.maximumValue = 1200
        pitchSlider.value = Float(UserSettings.shared.tonePitch)
        pitchSlider.addTarget(self, action: #selector(pitchSliderChanged(_:)), for: .valueChanged)
        pitchSlider.addTarget(self, action: #selector(pitchSliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])
        
        let pitchHeaderStack = UIStackView(arrangedSubviews: [pitchLabel, pitchValueLabel])
        pitchHeaderStack.axis = .horizontal
        pitchHeaderStack.distribution = .equalSpacing

        let pitchStack = UIStackView(arrangedSubviews: [pitchHeaderStack, pitchSlider])
        pitchStack.axis = .vertical
        pitchStack.spacing = 10
        
        // --- Character Speed Control (DISABLED) ---
        let charSpeedLabel = UILabel()
        charSpeedLabel.text = "Character Speed"
        charSpeedLabel.font = UIFont.systemFont(ofSize: 17)
        charSpeedLabel.textColor = .secondaryLabel

        let charSpeedValueLabel = UILabel()
        charSpeedValueLabel.text = "\(Int(UserSettings.shared.morseCharacterSpeed)) WPM"
        charSpeedValueLabel.font = UIFont.systemFont(ofSize: 17)
        charSpeedValueLabel.textColor = .tertiaryLabel
        charSpeedValueLabel.tag = 555

        let charSpeedSlider = UISlider()
        charSpeedSlider.minimumValue = 5
        charSpeedSlider.maximumValue = 40
        charSpeedSlider.value = Float(UserSettings.shared.morseCharacterSpeed)
        charSpeedSlider.isEnabled = false
        charSpeedSlider.tag = 5555

        let charSpeedHeaderStack = UIStackView(arrangedSubviews: [charSpeedLabel, charSpeedValueLabel])
        charSpeedHeaderStack.axis = .horizontal
        charSpeedHeaderStack.distribution = .equalSpacing

        let charSpeedStack = UIStackView(arrangedSubviews: [charSpeedHeaderStack, charSpeedSlider])
        charSpeedStack.axis = .vertical
        charSpeedStack.spacing = 10

        let charSpeedDescription = UILabel()
        charSpeedDescription.text = "How fast individual characters are sent (configured in JSON)"
        charSpeedDescription.font = UIFont.systemFont(ofSize: 14)
        charSpeedDescription.textColor = .tertiaryLabel
        charSpeedDescription.numberOfLines = 0

        let charSpeedStackWithDesc = UIStackView(arrangedSubviews: [charSpeedStack, charSpeedDescription])
        charSpeedStackWithDesc.axis = .vertical
        charSpeedStackWithDesc.spacing = 5

        // --- Farnsworth Spacing Control (DISABLED) ---
        let farnsworthLabel = UILabel()
        farnsworthLabel.text = "Letter Spacing"
        farnsworthLabel.font = UIFont.systemFont(ofSize: 17)
        farnsworthLabel.textColor = .secondaryLabel

        let farnsworthValueLabel = UILabel()
        farnsworthValueLabel.text = "\(Int(UserSettings.shared.morseFarnsworthSpeed)) WPM"
        farnsworthValueLabel.font = UIFont.systemFont(ofSize: 17)
        farnsworthValueLabel.textColor = .tertiaryLabel
        farnsworthValueLabel.tag = 444

        let farnsworthSlider = UISlider()
        farnsworthSlider.minimumValue = 5
        farnsworthSlider.maximumValue = 40
        farnsworthSlider.value = Float(UserSettings.shared.morseFarnsworthSpeed)
        farnsworthSlider.isEnabled = false
        farnsworthSlider.tag = 4444

        let farnsworthHeaderStack = UIStackView(arrangedSubviews: [farnsworthLabel, farnsworthValueLabel])
        farnsworthHeaderStack.axis = .horizontal
        farnsworthHeaderStack.distribution = .equalSpacing

        let farnsworthStack = UIStackView(arrangedSubviews: [farnsworthHeaderStack, farnsworthSlider])
        farnsworthStack.axis = .vertical
        farnsworthStack.spacing = 10

        let farnsworthDescription = UILabel()
        farnsworthDescription.text = "Slower spacing gives more time to think (configured in JSON)"
        farnsworthDescription.font = UIFont.systemFont(ofSize: 14)
        farnsworthDescription.textColor = .tertiaryLabel
        farnsworthDescription.numberOfLines = 0

        let farnsworthStackWithDesc = UIStackView(arrangedSubviews: [farnsworthStack, farnsworthDescription])
        farnsworthStackWithDesc.axis = .vertical
        farnsworthStackWithDesc.spacing = 5

        // --- Penalty Duration Control (DISABLED) ---
        let penaltyLabel = UILabel()
        penaltyLabel.text = "Penalty Duration"
        penaltyLabel.font = UIFont.systemFont(ofSize: 17)
        penaltyLabel.textColor = .secondaryLabel
        
        let penaltyValueLabel = UILabel()
        penaltyValueLabel.text = String(format: "%.1f sec", UserSettings.shared.penaltyDuration)
        penaltyValueLabel.font = UIFont.systemFont(ofSize: 17)
        penaltyValueLabel.textColor = .tertiaryLabel
        penaltyValueLabel.tag = 888

        let penaltySlider = UISlider()
        penaltySlider.minimumValue = 0.5
        penaltySlider.maximumValue = 3.0
        penaltySlider.value = Float(UserSettings.shared.penaltyDuration)
        penaltySlider.isEnabled = false
        penaltySlider.tag = 8888
        
        let penaltyHeaderStack = UIStackView(arrangedSubviews: [penaltyLabel, penaltyValueLabel])
        penaltyHeaderStack.axis = .horizontal
        penaltyHeaderStack.distribution = .equalSpacing

        let penaltyStack = UIStackView(arrangedSubviews: [penaltyHeaderStack, penaltySlider])
        penaltyStack.axis = .vertical
        penaltyStack.spacing = 10
        
        let penaltyDescription = UILabel()
        penaltyDescription.text = "How long you're frozen after wrong tap (configured in JSON)"
        penaltyDescription.font = UIFont.systemFont(ofSize: 14)
        penaltyDescription.textColor = .tertiaryLabel
        penaltyDescription.numberOfLines = 0
        
        let penaltyStackWithDesc = UIStackView(arrangedSubviews: [penaltyStack, penaltyDescription])
        penaltyStackWithDesc.axis = .vertical
        penaltyStackWithDesc.spacing = 5
        
        // --- Round Delay Control (DISABLED) ---
        let roundDelayLabel = UILabel()
        roundDelayLabel.text = "Delay Between Rounds"
        roundDelayLabel.font = UIFont.systemFont(ofSize: 17)
        roundDelayLabel.textColor = .secondaryLabel
        
        let roundDelayValueLabel = UILabel()
        roundDelayValueLabel.text = String(format: "%.1f sec", UserSettings.shared.delayBetweenRounds)
        roundDelayValueLabel.font = UIFont.systemFont(ofSize: 17)
        roundDelayValueLabel.textColor = .tertiaryLabel
        roundDelayValueLabel.tag = 777

        let roundDelaySlider = UISlider()
        roundDelaySlider.minimumValue = 2.0
        roundDelaySlider.maximumValue = 10.0
        roundDelaySlider.value = Float(UserSettings.shared.delayBetweenRounds)
        roundDelaySlider.isEnabled = false
        roundDelaySlider.tag = 7777
        
        let roundDelayHeaderStack = UIStackView(arrangedSubviews: [roundDelayLabel, roundDelayValueLabel])
        roundDelayHeaderStack.axis = .horizontal
        roundDelayHeaderStack.distribution = .equalSpacing

        let roundDelayStack = UIStackView(arrangedSubviews: [roundDelayHeaderStack, roundDelaySlider])
        roundDelayStack.axis = .vertical
        roundDelayStack.spacing = 10
        
        let roundDelayDescription = UILabel()
        roundDelayDescription.text = "Give player breathing room between rounds (configured in JSON)"
        roundDelayDescription.font = UIFont.systemFont(ofSize: 14)
        roundDelayDescription.textColor = .tertiaryLabel
        roundDelayDescription.numberOfLines = 0
        
        let roundDelayStackWithDesc = UIStackView(arrangedSubviews: [roundDelayStack, roundDelayDescription])
        roundDelayStackWithDesc.axis = .vertical
        roundDelayStackWithDesc.spacing = 5
        
        // --- Preparation Time Control (DISABLED) ---
        let prepTimeLabel = UILabel()
        prepTimeLabel.text = "Preparation Time"
        prepTimeLabel.font = UIFont.systemFont(ofSize: 17)
        prepTimeLabel.textColor = .secondaryLabel

        let prepTimeValueLabel = UILabel()
        prepTimeValueLabel.text = String(format: "%.1f sec", UserSettings.shared.preparationTime)
        prepTimeValueLabel.font = UIFont.systemFont(ofSize: 17)
        prepTimeValueLabel.textColor = .tertiaryLabel
        prepTimeValueLabel.tag = 666

        let prepTimeSlider = UISlider()
        prepTimeSlider.minimumValue = 0.5
        prepTimeSlider.maximumValue = 5.0
        prepTimeSlider.value = Float(UserSettings.shared.preparationTime)
        prepTimeSlider.isEnabled = false
        prepTimeSlider.tag = 6666

        let prepTimeHeaderStack = UIStackView(arrangedSubviews: [prepTimeLabel, prepTimeValueLabel])
        prepTimeHeaderStack.axis = .horizontal
        prepTimeHeaderStack.distribution = .equalSpacing

        let prepTimeStack = UIStackView(arrangedSubviews: [prepTimeHeaderStack, prepTimeSlider])
        prepTimeStack.axis = .vertical
        prepTimeStack.spacing = 10

        let prepTimeDescription = UILabel()
        prepTimeDescription.text = "Time between hearing Morse and pigs appearing (configured in JSON)"
        prepTimeDescription.font = UIFont.systemFont(ofSize: 14)
        prepTimeDescription.textColor = .tertiaryLabel
        prepTimeDescription.numberOfLines = 0

        let prepTimeStackWithDesc = UIStackView(arrangedSubviews: [prepTimeStack, prepTimeDescription])
        prepTimeStackWithDesc.axis = .vertical
        prepTimeStackWithDesc.spacing = 5
        
        // --- Gravity Control (DISABLED) ---
        let gravityLabel = UILabel()
        gravityLabel.text = "Pig Falling Speed"
        gravityLabel.font = UIFont.systemFont(ofSize: 17)
        gravityLabel.textColor = .secondaryLabel

        let gravityValueLabel = UILabel()
        gravityValueLabel.text = String(format: "%.2f", UserSettings.shared.pigGravity)
        gravityValueLabel.font = UIFont.systemFont(ofSize: 17)
        gravityValueLabel.textColor = .tertiaryLabel
        gravityValueLabel.tag = 333

        let gravitySlider = UISlider()
        gravitySlider.minimumValue = 0.2
        gravitySlider.maximumValue = 0.8
        gravitySlider.value = Float(UserSettings.shared.pigGravity)
        gravitySlider.isEnabled = false
        gravitySlider.tag = 3333

        let gravityHeaderStack = UIStackView(arrangedSubviews: [gravityLabel, gravityValueLabel])
        gravityHeaderStack.axis = .horizontal
        gravityHeaderStack.distribution = .equalSpacing

        let gravityStack = UIStackView(arrangedSubviews: [gravityHeaderStack, gravitySlider])
        gravityStack.axis = .vertical
        gravityStack.spacing = 10

        let gravityDescription = UILabel()
        gravityDescription.text = "How quickly pigs fall toward the grill (configured in JSON)"
        gravityDescription.font = UIFont.systemFont(ofSize: 14)
        gravityDescription.textColor = .tertiaryLabel
        gravityDescription.numberOfLines = 0

        let gravityStackWithDesc = UIStackView(arrangedSubviews: [gravityStack, gravityDescription])
        gravityStackWithDesc.axis = .vertical
        gravityStackWithDesc.spacing = 5
        
        // Update main stack to include all controls
        let mainStack = UIStackView(arrangedSubviews: [
            learningStackWithDesc,
            speechStackWithDesc,
            pitchStack,
            charSpeedStackWithDesc,
            farnsworthStackWithDesc,
            penaltyStackWithDesc,
            roundDelayStackWithDesc,
            prepTimeStackWithDesc,
            gravityStackWithDesc
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 30
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.backgroundColor = .secondarySystemGroupedBackground
        mainStack.layer.cornerRadius = 12

        scrollView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            // Scroll view fills the screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Stack inside scroll view - pin all 4 edges
            mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            // Width constraint - use frameLayoutGuide
            mainStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    // MARK: - Slider Change Handlers (Only for editable controls)
    
    @objc private func learningLevelChanged(_ sender: UISegmentedControl) {
        let stage = segmentIndexToStage(sender.selectedSegmentIndex)
        UserSettings.shared.initialLearningStage = stage
        
        // Update the configuration manager to use the new level FIRST
        GameConfigurationManager.shared.updateLevel(fromStage: stage)
        
        // Update the description
        if let descriptionLabel = view.viewWithTag(999) as? UILabel {
            descriptionLabel.text = getLevelDescription(for: sender.selectedSegmentIndex)
        }
        
        // Now read the updated values from GameConfigurationManager
        let charSpeed = GameConfigurationManager.shared.characterSpeed
        let farnsworth = GameConfigurationManager.shared.farnsworthSpeed
        let penalty = GameConfigurationManager.shared.penaltyDuration
        let roundDelay = GameConfigurationManager.shared.delayBetweenRounds
        let prepTime = GameConfigurationManager.shared.preparationTime
        let gravity = GameConfigurationManager.shared.pigGravity
        
        // Update all disabled slider values with the new values
        if let charSpeedLabel = view.viewWithTag(555) as? UILabel {
            charSpeedLabel.text = "\(Int(charSpeed)) WPM"
        }
        if let charSpeedSlider = view.viewWithTag(5555) as? UISlider {
            charSpeedSlider.value = Float(charSpeed)
        }
        
        if let farnsworthLabel = view.viewWithTag(444) as? UILabel {
            farnsworthLabel.text = "\(Int(farnsworth)) WPM"
        }
        if let farnsworthSlider = view.viewWithTag(4444) as? UISlider {
            farnsworthSlider.value = Float(farnsworth)
        }
        
        if let penaltyLabel = view.viewWithTag(888) as? UILabel {
            penaltyLabel.text = String(format: "%.1f sec", penalty)
        }
        if let penaltySlider = view.viewWithTag(8888) as? UISlider {
            penaltySlider.value = Float(penalty)
        }
        
        if let roundDelayLabel = view.viewWithTag(777) as? UILabel {
            roundDelayLabel.text = String(format: "%.1f sec", roundDelay)
        }
        if let roundDelaySlider = view.viewWithTag(7777) as? UISlider {
            roundDelaySlider.value = Float(roundDelay)
        }
        
        if let prepTimeLabel = view.viewWithTag(666) as? UILabel {
            prepTimeLabel.text = String(format: "%.1f sec", prepTime)
        }
        if let prepTimeSlider = view.viewWithTag(6666) as? UISlider {
            prepTimeSlider.value = Float(prepTime)
        }
        
        if let gravityLabel = view.viewWithTag(333) as? UILabel {
            gravityLabel.text = String(format: "%.2f", gravity)
        }
        if let gravitySlider = view.viewWithTag(3333) as? UISlider {
            gravitySlider.value = Float(gravity)
        }
        
        print("⚙️ Level changed to stage \(stage)")
        print("⚙️ Character Speed: \(charSpeed)")
        print("⚙️ Farnsworth: \(farnsworth)")
        print("⚙️ Penalty: \(penalty)")
        print("⚙️ Round Delay: \(roundDelay)")
        print("⚙️ Prep Time: \(prepTime)")
        print("⚙️ Gravity: \(gravity)")
    }
    
    @objc private func speechToggleChanged(_ sender: UISwitch) {
        print("⚙️ Speech toggle changed to: \(sender.isOn)")
        UserSettings.shared.isSpeechRecognitionEnabled = sender.isOn
        
        if sender.isOn {
            print("⚙️ Requesting speech recognition authorization...")
            SpeechRecognitionManager.shared.requestAuthorization { [weak self] authorized in
                print("⚙️ Authorization result: \(authorized)")
                if !authorized {
                    let alert = UIAlertController(
                        title: "Microphone Access Required",
                        message: "Please enable microphone and speech recognition in Settings to use voice input.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        sender.isOn = false
                        UserSettings.shared.isSpeechRecognitionEnabled = false
                    })
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func pitchSliderChanged(_ sender: UISlider) {
        if let pitchValueLabel = view.viewWithTag(111) as? UILabel {
            let value = Int(sender.value)
            pitchValueLabel.text = "\(value) Hz"
        }
    }
    
    @objc private func pitchSliderDidEndEditing(_ sender: UISlider) {
        let newPitch = Double(sender.value)
        UserSettings.shared.tonePitch = newPitch
        MorseCodePlayer.shared.updateToneFrequency(newPitch)
    }
    
    // MARK: - Helper Methods
    
    private func stageToSegmentIndex(_ stage: Int) -> Int {
        switch stage {
        case 0...2: return 0
        case 3...7: return 1
        default: return 2
        }
    }
    
    private func segmentIndexToStage(_ index: Int) -> Int {
        switch index {
        case 0: return 2
        case 1: return 7
        case 2: return 12
        default: return 2
        }
    }
    
    private func getLevelDescription(for segmentIndex: Int) -> String {
        let letterProgression: [Character] = ["E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G", "O", "H", "V", "F", "L", "P", "J", "B", "X", "C", "Y", "Z", "Q"]
        let stage = segmentIndexToStage(segmentIndex)
        let letters = Array(letterProgression[0...stage]).map(String.init).joined(separator: ", ")
        
        switch segmentIndex {
        case 0:
            return "Start with the simplest letters: \(letters)"
        case 1:
            return "Begin with basic proficiency in: \(letters)"
        case 2:
            return "Start with intermediate knowledge of: \(letters)"
        default:
            return ""
        }
    }
}
