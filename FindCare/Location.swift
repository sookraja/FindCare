//
//  Location.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-24.
//

import UIKit

struct Location {
    let name: String
    let coordinate: CGPoint
    let type: LocationType
    
    enum LocationType {
        case room
        case exit
        case stairs
        case elevator
        case restroom
    }
}
