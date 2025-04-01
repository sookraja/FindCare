//
//  Location.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-31.
//


import UIKit

class Location: NSObject {
    let id: String
    let name: String
    let roomNumber: String
    let type: LocationType
    let coordinate: CGPoint
   
    private var _description: String
    
    override var description: String {
        return _description
    }
    
    enum LocationType {
        case classroom
        case lab
        case office
        case washroom
        case exit
        case stairs
        case entrance
        
        // Get color for location type
        var color: UIColor {
            switch self {
            case .classroom:
                return .systemBlue
            case .lab:
                return .systemGreen
            case .office:
                return .systemPurple
            case .washroom:
                return .systemTeal
            case .exit:
                return .systemRed
            case .stairs:
                return .systemOrange
            case .entrance:
                return .systemYellow
            }
        }
        
        // Get icon name for location type
        var iconName: String {
            switch self {
            case .classroom:
                return "person.2"
            case .lab:
                return "desktopcomputer"
            case .office:
                return "person.text.rectangle"
            case .washroom:
                return "figure.wave"
            case .exit:
                return "door.right.hand.open"
            case .stairs:
                return "arrow.up.arrow.down"
            case .entrance:
                return "arrow.right.to.line"
            }
        }
    }
    
    // Updated initializer
    init(id: String, name: String, roomNumber: String, type: LocationType, coordinate: CGPoint, description: String = "") {
        self.id = id
        self.name = name
        self.roomNumber = roomNumber
        self.type = type
        self.coordinate = coordinate
        self._description = description.isEmpty ? "\(name) (\(roomNumber))" : description
        super.init()
    }
}
