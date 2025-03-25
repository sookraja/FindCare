//
//  LocationMarker.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-24.
//

import UIKit

protocol LocationMarkerDelegate: AnyObject {
    func didTapMarker(_ marker: LocationMarker)
}

class LocationMarker: UIView {
    // MARK: - Properties
    let location: Location
    weak var delegate: LocationMarkerDelegate?
    
    var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private let circleView = UIView()
    private let iconImageView = UIImageView()
    
    // MARK: - Initialization
    init(location: Location) {
        self.location = location
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        setupViews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        // Circle background
        circleView.frame = bounds
        circleView.layer.cornerRadius = bounds.width / 2
        circleView.backgroundColor = markerColor
        addSubview(circleView)
        
        // Icon
        iconImageView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.image = markerIcon
        addSubview(iconImageView)
        
        updateAppearance()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        delegate?.didTapMarker(self)
    }
    
    // MARK: - Appearance
    private func updateAppearance() {
        // Update size based on selection state
        let size: CGFloat = isSelected ? 40 : 30
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size, height: size)
        
        // Update circle view
        circleView.frame = bounds
        circleView.layer.cornerRadius = bounds.width / 2
        
        // Update icon view
        let iconSize: CGFloat = isSelected ? 30 : 20
        let iconPadding: CGFloat = isSelected ? 5 : 5
        iconImageView.frame = CGRect(x: iconPadding, y: iconPadding, width: iconSize, height: iconSize)
        
        // Add shadow if selected
        if isSelected {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 4
        } else {
            layer.shadowOpacity = 0
        }
    }
    
    // MARK: - Helper Properties
    private var markerColor: UIColor {
        switch location.type {
        case .room:
            return .systemBlue
        case .exit:
            return .systemGreen
        case .stairs:
            return .systemOrange
        case .elevator:
            return .systemPurple
        case .restroom:
            return .systemGray
        }
    }
    
    private var markerIcon: UIImage? {
        let iconName: String
        
        switch location.type {
        case .room:
            iconName = "door.right.hand"
        case .exit:
            iconName = "arrow.right.square"
        case .stairs:
            iconName = "arrow.up.arrow.down"
        case .elevator:
            iconName = "arrow.up.and.down.square"
        case .restroom:
            iconName = "person"
        }
        
        return UIImage(systemName: iconName)
    }
}
