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
    
    init(id: String, name: String, roomNumber: String, type: LocationType, coordinate: CGPoint) {
        self.id = id
        self.name = name
        self.roomNumber = roomNumber
        self.type = type
        self.coordinate = coordinate
        super.init()
    }
    
    enum LocationType {
        case entrance
        case exit
        case emergency
        case icu
        case surgery
        case imaging
        case pharmacy
        case reception
        case cafeteria
        case restroom
        case elevator
        case stairs
        
        var color: UIColor {
            switch self {
            case .entrance, .exit:
                return .systemGreen
            case .emergency:
                return .systemRed
            case .icu:
                return .systemOrange
            case .surgery:
                return .systemPink
            case .imaging:
                return .systemPurple
            case .pharmacy:
                return .systemTeal
            case .reception:
                return .systemBlue
            case .cafeteria:
                return .systemBrown
            case .restroom:
                return .systemIndigo
            case .elevator, .stairs:
                return .systemGray
            }
        }
        
        var iconName: String {
            switch self {
            case .entrance:
                return "door.right.hand.open"
            case .exit:
                return "door.left.hand.open"
            case .emergency:
                return "cross.case"
            case .icu:
                return "heart.text.square"
            case .surgery:
                return "scissors"
            case .imaging:
                return "rays"
            case .pharmacy:
                return "pills"
            case .reception:
                return "person.text.rectangle"
            case .cafeteria:
                return "cup.and.saucer"
            case .restroom:
                return "figure.dress.line.vertical.figure"
            case .elevator:
                return "arrow.up.arrow.down"
            case .stairs:
                return "stairs"
            }
        }
    }
}

