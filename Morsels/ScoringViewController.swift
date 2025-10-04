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
        let titleLabel = UILabel()
        titleLabel.text = "Scoring"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)
        
        // Add spacing after title
        let titleSpacer = UIView()
        titleSpacer.translatesAutoresizingMaskIntoConstraints = false
        titleSpacer.heightAnchor.constraint(equalToConstant: 10).isActive = true
        contentStack.addArrangedSubview(titleSpacer)
        
        // Scoring rules
        let scoringRules = [
            ("10.circle", "You get 10 points for each correctly tapped pig in sequence."),
            ("star.fill", "Completing a full sequence perfectly earns a completion bonus of 50 points per pig."),
            ("arrow.up.circle.fill", "Achieve a streak of 3 perfect rounds for a streak bonus that grows over time."),
            ("hand.thumbsdown.fill", "Failing to tap any pigs in the correct sequence will count as a failed round.")
        ]
        
        for (icon, text) in scoringRules {
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
