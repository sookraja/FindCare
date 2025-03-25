//
//  LocationDetailView.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-24.
//

import UIKit

protocol LocationDetailViewDelegate: AnyObject {
    func didTapClose()
    func didTapNavigate(to location: Location)
}

class LocationDetailView: UIView {
    // MARK: - Properties
    private var location: Location!
    weak var delegate: LocationDetailViewDelegate?
    
    private let titleLabel = UILabel()
    private let typeLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let navigateButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Type Label
        typeLabel.font = UIFont.systemFont(ofSize: 14)
        typeLabel.textColor = .secondaryLabel
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(typeLabel)
        
        // Close Button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        // Navigate Button
        navigateButton.setTitle("Navigate", for: .normal)
        navigateButton.backgroundColor = .systemBlue
        navigateButton.setTitleColor(.white, for: .normal)
        navigateButton.layer.cornerRadius = 8
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        navigateButton.addTarget(self, action: #selector(navigateTapped), for: .touchUpInside)
        addSubview(navigateButton)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            navigateButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            navigateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            navigateButton.widthAnchor.constraint(equalToConstant: 120),
            navigateButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configuration
    func configure(with location: Location) {
        self.location = location
        
        titleLabel.text = location.name
        
        switch location.type {
        case .room:
            typeLabel.text = "Room"
        case .exit:
            typeLabel.text = "Exit"
        case .stairs:
            typeLabel.text = "Stairs"
        case .elevator:
            typeLabel.text = "Elevator"
        case .restroom:
            typeLabel.text = "Restroom"
        }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        delegate?.didTapClose()
    }
    
    @objc private func navigateTapped() {
        guard let location = location else { return }
        delegate?.didTapNavigate(to: location)
    }
}
