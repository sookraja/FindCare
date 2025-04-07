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
            // Top row
            Location(id: "emergency", name: "Emergency Room", roomNumber: "H101", type: .emergency,
                    coordinate: CGPoint(x: 127, y: 227)),
            Location(id: "icu", name: "Intensive Care Unit", roomNumber: "H102", type: .icu,
                    coordinate: CGPoint(x: 253, y: 227)),
            Location(id: "surgery", name: "Surgery", roomNumber: "H103", type: .surgery,
                    coordinate: CGPoint(x: 300, y: 227)),
            Location(id: "imaging", name: "Imaging", roomNumber: "H104", type: .imaging,
                    coordinate: CGPoint(x: 505, y: 227)),
            
            // Bottom row - corridor
            Location(id: "entrance", name: "Main Entrance", roomNumber: "H-E1", type: .entrance,
                    coordinate: CGPoint(x: 75, y: 280)),
            Location(id: "reception", name: "Reception", roomNumber: "H201", type: .reception,
                    coordinate: CGPoint(x: 160, y: 280)),
            
            // Rooms off corridor
            Location(id: "pharmacy", name: "Pharmacy", roomNumber: "H202", type: .pharmacy,
                    coordinate: CGPoint(x: 225, y: 280)),
           
            Location(id: "cafeteria", name: "Cafeteria", roomNumber: "H203", type: .cafeteria,
                    coordinate: CGPoint(x: 130, y: 280)),
            
            Location(id: "exit", name: "Emergency Exit", roomNumber: "H-X1", type: .exit,
                    coordinate: CGPoint(x: 350, y: 260))
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
        
        let startCorridorPoint = findNearestCorridorPoint(for: start)
        let destCorridorPoint = findNearestCorridorPoint(for: destination)
        
     
        if start.coordinate != startCorridorPoint {
            segments.append(PathSegment(
                from: start.coordinate,
                to: startCorridorPoint,
                instruction: "Exit \(start.name) to the corridor"
            ))
        }
        
        if abs(startCorridorPoint.y - destCorridorPoint.y) > 20 {
        
            let verticalConnectionX: CGFloat = 300
            
            // 2a. From start corridor to vertical connection
            let startVerticalPoint = CGPoint(x: verticalConnectionX, y: startCorridorPoint.y)
            segments.append(PathSegment(
                from: startCorridorPoint,
                to: startVerticalPoint,
                instruction: "Walk along the corridor to the stairs/elevator"
            ))
            
            // 2b. Vertical connection - make it centered in the corridor
            let destVerticalPoint = CGPoint(x: verticalConnectionX, y: destCorridorPoint.y)
            segments.append(PathSegment(
                from: startVerticalPoint,
                to: destVerticalPoint,
                instruction: "Take the stairs/elevator"
            ))
            
            // 2c. From vertical connection to destination corridor point
            segments.append(PathSegment(
                from: destVerticalPoint,
                to: destCorridorPoint,
                instruction: "Walk along the corridor toward \(destination.name)"
            ))
        }
        // If on the same corridor, direct path along corridor
        else if startCorridorPoint != destCorridorPoint {
            segments.append(PathSegment(
                from: startCorridorPoint,
                to: destCorridorPoint,
                instruction: "Walk along the corridor toward \(destination.name)"
            ))
        }
        
        // 3. Final segment: From destination corridor to destination location
        if destCorridorPoint != destination.coordinate {
            segments.append(PathSegment(
                from: destCorridorPoint,
                to: destination.coordinate,
                instruction: "Enter \(destination.name)"
            ))
        }
        
        return segments
    }

  
    func findNearestCorridorPoint(for location: Location) -> CGPoint {
        
        let mainCorridorY: CGFloat = 255
        
       
        return CGPoint(x: location.coordinate.x, y: mainCorridorY)
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

