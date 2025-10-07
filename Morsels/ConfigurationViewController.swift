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
        scrollView.isScrollEnabled = true  // Add this
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
        //speechSwitch.isUserInteractionEnabled = false;
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
        
        // --- Pitch Control ---
        let pitchLabel = UILabel()
        pitchLabel.text = "Tone Pitch"
        pitchLabel.font = UIFont.systemFont(ofSize: 17)
        
        let pitchValueLabel = UILabel()
        pitchValueLabel.text = "\(Int(UserSettings.shared.tonePitch)) Hz"
        pitchValueLabel.font = UIFont.systemFont(ofSize: 17)
        pitchValueLabel.textColor = .gray

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
        
        // --- Penalty Duration Control ---
        let penaltyLabel = UILabel()
        penaltyLabel.text = "Penalty Duration"
        penaltyLabel.font = UIFont.systemFont(ofSize: 17)
        
        let penaltyValueLabel = UILabel()
        penaltyValueLabel.text = String(format: "%.1f sec", UserSettings.shared.penaltyDuration)
        penaltyValueLabel.font = UIFont.systemFont(ofSize: 17)
        penaltyValueLabel.textColor = .gray
        penaltyValueLabel.tag = 888

        let penaltySlider = UISlider()
        penaltySlider.minimumValue = 0.5
        penaltySlider.maximumValue = 3.0
        penaltySlider.value = Float(UserSettings.shared.penaltyDuration)
        penaltySlider.addTarget(self, action: #selector(penaltySliderChanged(_:)), for: .valueChanged)
        penaltySlider.addTarget(self, action: #selector(penaltySliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])
        
        let penaltyHeaderStack = UIStackView(arrangedSubviews: [penaltyLabel, penaltyValueLabel])
        penaltyHeaderStack.axis = .horizontal
        penaltyHeaderStack.distribution = .equalSpacing

        let penaltyStack = UIStackView(arrangedSubviews: [penaltyHeaderStack, penaltySlider])
        penaltyStack.axis = .vertical
        penaltyStack.spacing = 10
        
        let penaltyDescription = UILabel()
        penaltyDescription.text = "How long you're frozen after tapping the wrong pig"
        penaltyDescription.font = UIFont.systemFont(ofSize: 14)
        penaltyDescription.textColor = .secondaryLabel
        penaltyDescription.numberOfLines = 0
        
        let penaltyStackWithDesc = UIStackView(arrangedSubviews: [penaltyStack, penaltyDescription])
        penaltyStackWithDesc.axis = .vertical
        penaltyStackWithDesc.spacing = 5
        
        // --- ADD THIS: Round Delay Control ---
          let roundDelayLabel = UILabel()
          roundDelayLabel.text = "Delay Between Rounds"
          roundDelayLabel.font = UIFont.systemFont(ofSize: 17)
          
          let roundDelayValueLabel = UILabel()
          roundDelayValueLabel.text = String(format: "%.1f sec", UserSettings.shared.delayBetweenRounds)
          roundDelayValueLabel.font = UIFont.systemFont(ofSize: 17)
          roundDelayValueLabel.textColor = .gray
          roundDelayValueLabel.tag = 777

          let roundDelaySlider = UISlider()
          roundDelaySlider.minimumValue = 2.0
          roundDelaySlider.maximumValue = 10.0
          roundDelaySlider.value = Float(UserSettings.shared.delayBetweenRounds)
          roundDelaySlider.addTarget(self, action: #selector(roundDelaySliderChanged(_:)), for: .valueChanged)
          roundDelaySlider.addTarget(self, action: #selector(roundDelaySliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])
          
          let roundDelayHeaderStack = UIStackView(arrangedSubviews: [roundDelayLabel, roundDelayValueLabel])
          roundDelayHeaderStack.axis = .horizontal
          roundDelayHeaderStack.distribution = .equalSpacing

          let roundDelayStack = UIStackView(arrangedSubviews: [roundDelayHeaderStack, roundDelaySlider])
          roundDelayStack.axis = .vertical
          roundDelayStack.spacing = 10
          
          let roundDelayDescription = UILabel()
          roundDelayDescription.text = "Give player breathing room between rounds"
          roundDelayDescription.font = UIFont.systemFont(ofSize: 14)
          roundDelayDescription.textColor = .secondaryLabel
          roundDelayDescription.numberOfLines = 0
          
          let roundDelayStackWithDesc = UIStackView(arrangedSubviews: [roundDelayStack, roundDelayDescription])
          roundDelayStackWithDesc.axis = .vertical
          roundDelayStackWithDesc.spacing = 5
          
        // --- ADD THIS: Preparation Time Control ---
        let prepTimeLabel = UILabel()
        prepTimeLabel.text = "Preparation Time"
        prepTimeLabel.font = UIFont.systemFont(ofSize: 17)

        let prepTimeValueLabel = UILabel()
        prepTimeValueLabel.text = String(format: "%.1f sec", UserSettings.shared.preparationTime)
        prepTimeValueLabel.font = UIFont.systemFont(ofSize: 17)
        prepTimeValueLabel.textColor = .gray
        prepTimeValueLabel.tag = 666

        let prepTimeSlider = UISlider()
        prepTimeSlider.minimumValue = 0.5
        prepTimeSlider.maximumValue = 5.0
        prepTimeSlider.value = Float(UserSettings.shared.preparationTime)
        prepTimeSlider.addTarget(self, action: #selector(prepTimeSliderChanged(_:)), for: .valueChanged)
        prepTimeSlider.addTarget(self, action: #selector(prepTimeSliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])

        let prepTimeHeaderStack = UIStackView(arrangedSubviews: [prepTimeLabel, prepTimeValueLabel])
        prepTimeHeaderStack.axis = .horizontal
        prepTimeHeaderStack.distribution = .equalSpacing

        let prepTimeStack = UIStackView(arrangedSubviews: [prepTimeHeaderStack, prepTimeSlider])
        prepTimeStack.axis = .vertical
        prepTimeStack.spacing = 10

        let prepTimeDescription = UILabel()
        prepTimeDescription.text = "Time between hearing Morse code and pigs appearing"
        prepTimeDescription.font = UIFont.systemFont(ofSize: 14)
        prepTimeDescription.textColor = .secondaryLabel
        prepTimeDescription.numberOfLines = 0

        let prepTimeStackWithDesc = UIStackView(arrangedSubviews: [prepTimeStack, prepTimeDescription])
        prepTimeStackWithDesc.axis = .vertical
        prepTimeStackWithDesc.spacing = 5
        
        // --- Character Speed Control ---
        let charSpeedLabel = UILabel()
        charSpeedLabel.text = "Character Speed"
        charSpeedLabel.font = UIFont.systemFont(ofSize: 17)

        let charSpeedValueLabel = UILabel()
        charSpeedValueLabel.text = "\(Int(UserSettings.shared.morseCharacterSpeed)) WPM"
        charSpeedValueLabel.font = UIFont.systemFont(ofSize: 17)
        charSpeedValueLabel.textColor = .gray
        charSpeedValueLabel.tag = 555

        let charSpeedSlider = UISlider()
        charSpeedSlider.minimumValue = 5
        charSpeedSlider.maximumValue = 40
        charSpeedSlider.value = Float(UserSettings.shared.morseCharacterSpeed)
        charSpeedSlider.addTarget(self, action: #selector(charSpeedSliderChanged(_:)), for: .valueChanged)
        charSpeedSlider.addTarget(self, action: #selector(charSpeedSliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])

        let charSpeedHeaderStack = UIStackView(arrangedSubviews: [charSpeedLabel, charSpeedValueLabel])
        charSpeedHeaderStack.axis = .horizontal
        charSpeedHeaderStack.distribution = .equalSpacing

        let charSpeedStack = UIStackView(arrangedSubviews: [charSpeedHeaderStack, charSpeedSlider])
        charSpeedStack.axis = .vertical
        charSpeedStack.spacing = 10

        let charSpeedDescription = UILabel()
        charSpeedDescription.text = "How fast individual characters are sent (words per minute)"
        charSpeedDescription.font = UIFont.systemFont(ofSize: 14)
        charSpeedDescription.textColor = .secondaryLabel
        charSpeedDescription.numberOfLines = 0

        let charSpeedStackWithDesc = UIStackView(arrangedSubviews: [charSpeedStack, charSpeedDescription])
        charSpeedStackWithDesc.axis = .vertical
        charSpeedStackWithDesc.spacing = 5

        // --- Farnsworth Spacing Control ---
        let farnsworthLabel = UILabel()
        farnsworthLabel.text = "Letter Spacing"
        farnsworthLabel.font = UIFont.systemFont(ofSize: 17)

        let farnsworthValueLabel = UILabel()
        farnsworthValueLabel.text = "\(Int(UserSettings.shared.morseFarnsworthSpacing)) WPM"
        farnsworthValueLabel.font = UIFont.systemFont(ofSize: 17)
        farnsworthValueLabel.textColor = .gray
        farnsworthValueLabel.tag = 444

        let farnsworthSlider = UISlider()
        farnsworthSlider.minimumValue = 5
        farnsworthSlider.maximumValue = 40
        farnsworthSlider.value = Float(UserSettings.shared.morseFarnsworthSpacing)
        farnsworthSlider.addTarget(self, action: #selector(farnsworthSliderChanged(_:)), for: .valueChanged)
        farnsworthSlider.addTarget(self, action: #selector(farnsworthSliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])

        let farnsworthHeaderStack = UIStackView(arrangedSubviews: [farnsworthLabel, farnsworthValueLabel])
        farnsworthHeaderStack.axis = .horizontal
        farnsworthHeaderStack.distribution = .equalSpacing

        let farnsworthStack = UIStackView(arrangedSubviews: [farnsworthHeaderStack, farnsworthSlider])
        farnsworthStack.axis = .vertical
        farnsworthStack.spacing = 10

        let farnsworthDescription = UILabel()
        farnsworthDescription.text = "Slower spacing gives more time to think between letters"
        farnsworthDescription.font = UIFont.systemFont(ofSize: 14)
        farnsworthDescription.textColor = .secondaryLabel
        farnsworthDescription.numberOfLines = 0

        let farnsworthStackWithDesc = UIStackView(arrangedSubviews: [farnsworthStack, farnsworthDescription])
        farnsworthStackWithDesc.axis = .vertical
        farnsworthStackWithDesc.spacing = 5

        // --- Gravity Control ---
        let gravityLabel = UILabel()
        gravityLabel.text = "Pig Falling Speed"
        gravityLabel.font = UIFont.systemFont(ofSize: 17)

        let gravityValueLabel = UILabel()
        gravityValueLabel.text = String(format: "%.2f", UserSettings.shared.pigGravity)
        gravityValueLabel.font = UIFont.systemFont(ofSize: 17)
        gravityValueLabel.textColor = .gray
        gravityValueLabel.tag = 333

        let gravitySlider = UISlider()
        gravitySlider.minimumValue = 0.2
        gravitySlider.maximumValue = 0.8
        gravitySlider.value = Float(UserSettings.shared.pigGravity)
        gravitySlider.addTarget(self, action: #selector(gravitySliderChanged(_:)), for: .valueChanged)
        gravitySlider.addTarget(self, action: #selector(gravitySliderDidEndEditing(_:)), for: [.touchUpInside, .touchUpOutside])

        let gravityHeaderStack = UIStackView(arrangedSubviews: [gravityLabel, gravityValueLabel])
        gravityHeaderStack.axis = .horizontal
        gravityHeaderStack.distribution = .equalSpacing

        let gravityStack = UIStackView(arrangedSubviews: [gravityHeaderStack, gravitySlider])
        gravityStack.axis = .vertical
        gravityStack.spacing = 10

        let gravityDescription = UILabel()
        gravityDescription.text = "How quickly pigs fall toward the grill"
        gravityDescription.font = UIFont.systemFont(ofSize: 14)
        gravityDescription.textColor = .secondaryLabel
        gravityDescription.numberOfLines = 0

        let gravityStackWithDesc = UIStackView(arrangedSubviews: [gravityStack, gravityDescription])
        gravityStackWithDesc.axis = .vertical
        gravityStackWithDesc.spacing = 5

        // Add gravityStackWithDesc to your mainStack array
        
        // Update main stack to include new controls
        let mainStack = UIStackView(arrangedSubviews: [
            learningStackWithDesc,
            speechStackWithDesc,
            pitchStack,
            charSpeedStackWithDesc,  // ADD
            farnsworthStackWithDesc,  // ADD
            penaltyStackWithDesc,
            roundDelayStackWithDesc,
            prepTimeStackWithDesc,
            gravityStackWithDesc
        ])
        
          mainStack.axis = .vertical
          mainStack.spacing = 50 //TEMP WAS 30
          mainStack.translatesAutoresizingMaskIntoConstraints = false
          mainStack.isLayoutMarginsRelativeArrangement = true
          mainStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
          mainStack.backgroundColor = .secondarySystemGroupedBackground
          mainStack.layer.cornerRadius = 12

        scrollView.addSubview(mainStack)  // NEW - add to scrollView instead
        
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
            
            // Width constraint - use frameLayoutGuide instead
            mainStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
      }

      // ADD THESE METHODS:
      @objc private func roundDelaySliderChanged(_ sender: UISlider) {
          if let roundDelayValueLabel = view.viewWithTag(777) as? UILabel {
              let value = sender.value
              roundDelayValueLabel.text = String(format: "%.1f sec", value)
          }
      }

      @objc private func roundDelaySliderDidEndEditing(_ sender: UISlider) {
          let newDelay = TimeInterval(sender.value)
          UserSettings.shared.delayBetweenRounds = newDelay
      }
    
    @objc private func prepTimeSliderChanged(_ sender: UISlider) {
        if let prepTimeValueLabel = view.viewWithTag(666) as? UILabel {
            let value = sender.value
            prepTimeValueLabel.text = String(format: "%.1f sec", value)
        }
    }

    @objc private func prepTimeSliderDidEndEditing(_ sender: UISlider) {
        let newTime = TimeInterval(sender.value)
        UserSettings.shared.preparationTime = newTime
    }
    
    @objc private func learningLevelChanged(_ sender: UISegmentedControl) {
        let stage = segmentIndexToStage(sender.selectedSegmentIndex)
       UserSettings.shared.initialLearningStage = stage
        
        if let descriptionLabel = view.viewWithTag(999) as? UILabel {
            descriptionLabel.text = getLevelDescription(for: sender.selectedSegmentIndex)
        }
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
    
    @objc private func penaltySliderChanged(_ sender: UISlider) {
        if let penaltyValueLabel = view.viewWithTag(888) as? UILabel {
            let value = sender.value
            penaltyValueLabel.text = String(format: "%.1f sec", value)
        }
    }
    
    @objc private func penaltySliderDidEndEditing(_ sender: UISlider) {
        let newDuration = TimeInterval(sender.value)
        UserSettings.shared.penaltyDuration = newDuration
    }
    
    @objc private func charSpeedSliderChanged(_ sender: UISlider) {
        if let valueLabel = view.viewWithTag(555) as? UILabel {
            let value = Int(sender.value)
            valueLabel.text = "\(value) WPM"
        }
    }

    @objc private func charSpeedSliderDidEndEditing(_ sender: UISlider) {
        let newSpeed = Double(sender.value)
        UserSettings.shared.morseCharacterSpeed = newSpeed
        MorseCodePlayer.shared.updateCharacterSpeed(newSpeed)
    }

    @objc private func farnsworthSliderChanged(_ sender: UISlider) {
        if let valueLabel = view.viewWithTag(444) as? UILabel {
            let value = Int(sender.value)
            valueLabel.text = "\(value) WPM"
        }
    }

    @objc private func farnsworthSliderDidEndEditing(_ sender: UISlider) {
        let newSpacing = Double(sender.value)
        UserSettings.shared.morseFarnsworthSpacing = newSpacing
        MorseCodePlayer.shared.updateFarnsworthSpacing(newSpacing)
    }
    
    @objc private func gravitySliderChanged(_ sender: UISlider) {
        if let gravityValueLabel = view.viewWithTag(333) as? UILabel {
            let value = sender.value
            gravityValueLabel.text = String(format: "%.2f", value)
        }
    }

    @objc private func gravitySliderDidEndEditing(_ sender: UISlider) {
        let newGravity = CGFloat(sender.value)
        UserSettings.shared.pigGravity = newGravity
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
