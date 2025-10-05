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
        learningDescription.numberOfLines = 0
        learningDescription.tag = 999
        
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
        
          // --- Main Stack ---
          let mainStack = UIStackView(arrangedSubviews: [
              learningStackWithDesc,
              speechStackWithDesc,
              pitchStack,
              penaltyStackWithDesc,
              roundDelayStackWithDesc, // ADD THIS
              prepTimeStackWithDesc  // ADD THIS
          ])
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
