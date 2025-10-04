//
//  InstructionRowView.swift
//  Morsels
//
//  Created by Mark Messer on 10/4/25.
//


//
//  InstructionRowView.swift
//  Morsels
//
//  Reusable instruction row component for UIKit
//

import UIKit

class InstructionRowView: UIView {
    
    private let iconView = UIImageView()
    private let textLabel = UILabel()
    
    init(icon: String, text: String) {
        super.init(frame: .zero)
        setupView(icon: icon, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(icon: String, text: String) {
        // Configure icon
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Configure text label
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 17)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create horizontal stack
        let stack = UIStackView(arrangedSubviews: [iconView, textLabel])
        stack.axis = .horizontal
        stack.spacing = 15
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 35),
            iconView.heightAnchor.constraint(equalToConstant: 35),
            
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}