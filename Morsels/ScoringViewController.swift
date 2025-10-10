//
//  ScoringViewController.swift
//  Morsels
//
//  Full UIKit implementation
//

import UIKit

class ScoringViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Scoring Details"
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
        
        // Title
//        let titleLabel = UILabel()
//        titleLabel.text = "Scoring"
//        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
//        titleLabel.numberOfLines = 0
//        contentStack.addArrangedSubview(titleLabel)
//        
//        // Add spacing after title
//        let titleSpacer = UIView()
//        titleSpacer.translatesAutoresizingMaskIntoConstraints = false
//        titleSpacer.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        contentStack.addArrangedSubview(titleSpacer)
        
        // Scoring rules
        let scoringRules = [
            ("10.circle", "You get 10 points for each correctly selected pig in the proper sequence."),
            ("star.fill", "Completing a full sequence perfectly (3+ pigs) earns a completion bonus of 50 points per pig."),
            ("flame.circle.fill", "Achieving 3 consecutive perfect rounds unlocks a streak bonus that grows with each additional perfect round."),
            ("xmark.octagon.fill", "In tap mode: Tapping the wrong pig triggers a penalty where you're frozen briefly. In voice mode: Incorrect selections are simply ignored."),
            ("hand.thumbsdown.fill", "Failing to select any pigs correctly in a round counts as a failed round. Three failed rounds ends the game."),
            ("arrow.up.circle.fill", "As you master letters, the game automatically progresses to include more letters and increases difficulty.")
        ]
        
        for (icon, text) in scoringRules {
            let row = InstructionRowView(icon: icon, text: text)
            contentStack.addArrangedSubview(row)
        }
        
        // Add a separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(separator)
        
        // Strategy section
        let strategyLabel = UILabel()
        strategyLabel.text = "Strategy Tips"
        strategyLabel.font = .systemFont(ofSize: 24, weight: .bold)
        strategyLabel.numberOfLines = 0
        contentStack.addArrangedSubview(strategyLabel)
        
        let strategyTips = [
            ("brain.head.profile", "Focus on accuracy over speed. It's better to get the sequence right than to tap quickly and break your streak."),
            ("speaker.wave.3.fill", "In tap mode, take your time during the penalty-free period after correct selections to plan your next move."), 
            ("chart.line.uptrend.xyaxis", "Build up perfect round streaks to maximize your score with the growing streak bonus.")
        ]
        
        for (icon, text) in strategyTips {
            let row = InstructionRowView(icon: icon, text: text)
            contentStack.addArrangedSubview(row)
        }
        
        // Flexible spacer to push content to top
        let flexibleSpacer = UIView()
        flexibleSpacer.translatesAutoresizingMaskIntoConstraints = false
        flexibleSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStack.addArrangedSubview(flexibleSpacer)
        
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
