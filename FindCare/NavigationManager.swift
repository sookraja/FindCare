//
//  NavigationManager.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-31.
//


import UIKit

class NavigationManager: NSObject {
    
    var locations: [Location] = []
    var selectedStartLocation: Location?
    var selectedDestLocation: Location?
    
    class PathSegment: NSObject {
        let from: CGPoint
        let to: CGPoint
        let instruction: String
        
        init(from: CGPoint, to: CGPoint, instruction: String) {
            self.from = from
            self.to = to
            self.instruction = instruction
            super.init()
        }
    }
    
    override init() {
        super.init()
        setupLocations()
    }
    
    func setupLocations() {
        locations = [
        
            Location(id: "emergency", name: "Emergency Room", roomNumber: "H101", type: .emergency,
                    coordinate: CGPoint(x: 127, y: 227)),
            Location(id: "icu", name: "Intensive Care Unit", roomNumber: "H102", type: .icu,
                    coordinate: CGPoint(x: 253, y: 227)),
            Location(id: "surgery", name: "Surgery", roomNumber: "H103", type: .surgery,
                    coordinate: CGPoint(x: 379, y: 227)),
            Location(id: "imaging", name: "Imaging", roomNumber: "H104", type: .imaging,
                    coordinate: CGPoint(x: 505, y: 227)),
            

            Location(id: "entrance", name: "Main Entrance", roomNumber: "H-E1", type: .entrance,
                    coordinate: CGPoint(x: 75, y: 280)),
            Location(id: "reception", name: "Reception", roomNumber: "H201", type: .reception,
                    coordinate: CGPoint(x: 190, y: 280)),
            Location(id: "pharmacy", name: "Pharmacy", roomNumber: "H202", type: .pharmacy,
                    coordinate: CGPoint(x: 316, y: 280)),
            Location(id: "cafeteria", name: "Cafeteria", roomNumber: "H203", type: .cafeteria,
                    coordinate: CGPoint(x: 442, y: 280)),
            Location(id: "exit", name: "Emergency Exit", roomNumber: "H-X1", type: .exit,
                    coordinate: CGPoint(x: 568, y: 280))
        ]
    }
    
    func setStartLocation(_ location: Location) {
        selectedStartLocation = location
    }
    
    func setDestinationLocation(_ location: Location) {
        selectedDestLocation = location
    }
    
    func clearNavigation() {
        selectedStartLocation = nil
        selectedDestLocation = nil
    }
    
    func findPath() -> [PathSegment]? {
        guard let start = selectedStartLocation, let destination = selectedDestLocation else {
            return nil
        }
        
       
        var segments: [PathSegment] = []
        
      
        let needsCorridor = abs(start.coordinate.y - destination.coordinate.y) > 20
        
        if needsCorridor {

            let corridorY: CGFloat = 253
            let startToCorridorPoint = CGPoint(x: start.coordinate.x, y: corridorY)
            segments.append(PathSegment(
                from: start.coordinate,
                to: startToCorridorPoint,
                instruction: "Exit \(start.name) (\(start.roomNumber)) and head to the main corridor"
            ))
            
 
            let corridorToDestPoint = CGPoint(x: destination.coordinate.x, y: corridorY)
            let direction = start.coordinate.x < destination.coordinate.x ? "right" : "left"
                segments.append(PathSegment(
                from: startToCorridorPoint,
                to: corridorToDestPoint,
                instruction: "Turn \(direction) and walk along the main corridor"
            ))
                segments.append(PathSegment(
                from: corridorToDestPoint,
                to: destination.coordinate,
                instruction: "Enter \(destination.name) (\(destination.roomNumber))"
            ))
        } else {
                segments.append(PathSegment(
                from: start.coordinate,
                to: destination.coordinate,
                instruction: "Walk directly from \(start.name) to \(destination.name)"
            ))
        }
        
        return segments
    }
    
    func getNavigationInstructions() -> [String] {
        guard let start = selectedStartLocation,
              let destination = selectedDestLocation,
              let pathSegments = findPath() else {
            return ["Select a starting point and destination to get directions."]
        }
        
        
        var instructions: [String] = []
        

        instructions.append("Start at \(start.name) (\(start.roomNumber))")
        

        for segment in pathSegments {
            instructions.append(segment.instruction)
        }
        

        instructions.append("Arrive at \(destination.name) (\(destination.roomNumber))")
        

        let totalDistance = calculateTotalDistance(pathSegments)
        instructions.append("Total distance: approximately \(Int(totalDistance)) meters")
        
        return instructions
    }
    
    private func calculateTotalDistance(_ pathSegments: [PathSegment]) -> CGFloat {
        var totalDistance: CGFloat = 0
        
        for segment in pathSegments {
            let dx = segment.to.x - segment.from.x
            let dy = segment.to.y - segment.from.y
            let segmentDistance = sqrt(dx*dx + dy*dy)
            let metersPerPoint: CGFloat = 0.2
            totalDistance += segmentDistance * metersPerPoint
        }
        
        return totalDistance
    }
}

