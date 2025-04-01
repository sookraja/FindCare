//
//  LocationMarkerDelegate.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-31.
//


import UIKit

protocol LocationMarkerDelegate: AnyObject {
    func locationMarkerTapped(_ location: Location)
}

class LocationMarkerView: UIButton {

    private var location: Location!
    weak var delegate: LocationMarkerDelegate?
    
    // Change this to avoid ambiguity with UIButton's isHighlighted
    var markerHighlighted: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(location: Location) {
        // Make markers smaller to fit your map better
        self.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.location = location
        setupView()
    }
    // MARK: - Setup
    private func setupView() {
        // Set appearance based on location type
        backgroundColor = location.type.color
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
        // Add icon based on location type
        let iconImage = UIImage(systemName: location.type.iconName)
        setImage(iconImage, for: .normal)
        tintColor = .white
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Add action
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    

    @objc private func buttonTapped() {
        delegate?.locationMarkerTapped(location)
    }
    
    
    func updatePosition(at point: CGPoint, scale: CGFloat = 1.0) {
        let size = frame.size
        frame = CGRect(
            x: point.x * scale - size.width/2,
            y: point.y * scale - size.height/2,
            width: size.width,
            height: size.height
        )
    }
    private func updateAppearance() {
        if markerHighlighted {
            transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            layer.borderWidth = 3
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
        } else {
            transform = CGAffineTransform.identity
            layer.borderWidth = 2
            layer.shadowOpacity = 0
        }
    }
}
