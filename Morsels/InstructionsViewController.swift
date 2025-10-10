//
//  InstructionsViewController.swift
//  Morsels
//
//  Full UIKit implementation
//

import UIKit

class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Instructions"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Create scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create content stack
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true
        
        // Instructions
        let instructions = [
            ("ear", "Listen carefully to the sequence of Morse code letters played at the start of each round."),
            ("hand.tap.fill", "Tap the falling pigs in the same sequence you heard."),
            ("checkmark.circle.fill", "Correct selections will save the pigs and send them to the pigpen."),
            ("xmark.octagon.fill", "An incorrect tap will trigger a brief penalty where you cannot select any pigs."),
            ("flame.fill", "Don't let the pigs fall into the grill! Too many failed rounds will end the game."),
            ("arrow.up.circle.fill", "Progress through difficulty levels by mastering letters. The game adjusts speed and timing as you advance."),
            ("pause.circle.fill", "Tap the grill at any time to pause the game.")
        ]
        
        for (icon, text) in instructions {
            let row = InstructionRowView(icon: icon, text: text)
            contentStack.addArrangedSubview(row)
        }
        
        // Add a separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(separator)
        
        // Tips section
        let tipsLabel = UILabel()
        tipsLabel.text = "Tips"
        tipsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        tipsLabel.numberOfLines = 0
        contentStack.addArrangedSubview(tipsLabel)
        
        let tips = [
            ("lightbulb.fill", "Start with the Beginner level in Configuration to learn the basics with slower speeds and more time."),
            ("waveform", "Focus on the rhythm and pattern of the Morse code rather than counting dots and dashes."),
            ("speaker.wave.2.fill", "Adjust the Tone Pitch in Configuration to find a frequency that's comfortable for your ears."),
            ("mic.fill", "Enable Voice Input in settings to speak the letters using the International Phonetic Alphabet instead of tapping.")
        ]
        
        for (icon, text) in tips {
            let row = InstructionRowView(icon: icon, text: text)
            contentStack.addArrangedSubview(row)
        }
        
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}
