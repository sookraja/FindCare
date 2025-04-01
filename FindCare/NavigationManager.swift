//
//  NavigationManager.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-31.
//


import UIKit

class NavigationManager: NSObject {
    
    private(set) var locations: [Location] = []
    private(set) var selectedStartLocation: Location?
    private(set) var selectedDestLocation: Location?
    

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
            // Top row of rooms (left to right)
            Location(id: "m101", name: "Classroom", roomNumber: "M101", type: .classroom, coordinate: CGPoint(x: 127, y: 227)),
            Location(id: "m102", name: "Classroom", roomNumber: "M102", type: .classroom, coordinate: CGPoint(x: 190, y: 227)),
            Location(id: "m103", name: "Computer Lab", roomNumber: "M103", type: .lab, coordinate: CGPoint(x: 253, y: 227)),
            Location(id: "m104", name: "Faculty Office", roomNumber: "M104", type: .office, coordinate: CGPoint(x: 316, y: 227)),
            Location(id: "washroom1", name: "Washroom", roomNumber: "M-W1", type: .washroom, coordinate: CGPoint(x: 379, y: 227)),
            Location(id: "stairs1", name: "Stairwell", roomNumber: "M-S1", type: .stairs, coordinate: CGPoint(x: 442, y: 227)),
            Location(id: "exit1", name: "Emergency Exit", roomNumber: "M-X1", type: .exit, coordinate: CGPoint(x: 505, y: 227)),
            Location(id: "exit2", name: "Emergency Exit", roomNumber: "M-X2", type: .exit, coordinate: CGPoint(x: 568, y: 227)),
            
            // Bottom row of rooms (left to right)
            Location(id: "entrance1", name: "Main Entrance", roomNumber: "M-E1", type: .entrance, coordinate: CGPoint(x: 75, y: 280)),
            Location(id: "m201", name: "Classroom", roomNumber: "M201", type: .classroom, coordinate: CGPoint(x: 127, y: 280)),
            Location(id: "m202", name: "Classroom", roomNumber: "M202", type: .classroom, coordinate: CGPoint(x: 190, y: 280)),
            Location(id: "m203", name: "Classroom", roomNumber: "M203", type: .classroom, coordinate: CGPoint(x: 253, y: 280)),
            Location(id: "m204", name: "Computer Lab", roomNumber: "M204", type: .lab, coordinate: CGPoint(x: 316, y: 280)),
            Location(id: "m205", name: "Faculty Office", roomNumber: "M205", type: .office, coordinate: CGPoint(x: 379, y: 280)),
            Location(id: "m206", name: "Classroom", roomNumber: "M206", type: .classroom, coordinate: CGPoint(x: 442, y: 280)),
            Location(id: "m207", name: "Classroom", roomNumber: "M207", type: .classroom, coordinate: CGPoint(x: 505, y: 280)),
            Location(id: "m208", name: "Classroom", roomNumber: "M208", type: .classroom, coordinate: CGPoint(x: 568, y: 280))
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
        
        // Create a simple path with waypoints
        var segments: [PathSegment] = []
        
        // Determine if we need to go through the corridor
        let needsCorridor = abs(start.coordinate.y - destination.coordinate.y) > 20
        
        if needsCorridor {
            // Add segment from start to corridor
            let corridorY: CGFloat = 253 // Adjusted Y-coordinate of the main corridor
            let startToCorridorPoint = CGPoint(x: start.coordinate.x, y: corridorY)
            segments.append(PathSegment(
                from: start.coordinate,
                to: startToCorridorPoint,
                instruction: "Exit \(start.name) (\(start.roomNumber)) and head to the main corridor"
            ))
            
            // Add segment along corridor
            let corridorToDestPoint = CGPoint(x: destination.coordinate.x, y: corridorY)
            let direction = start.coordinate.x < destination.coordinate.x ? "right" : "left"
            segments.append(PathSegment(
                from: startToCorridorPoint,
                to: corridorToDestPoint,
                instruction: "Turn \(direction) and walk along the main corridor"
            ))
            
            // Add segment from corridor to destination
            segments.append(PathSegment(
                from: corridorToDestPoint,
                to: destination.coordinate,
                instruction: "Enter \(destination.name) (\(destination.roomNumber))"
            ))
        } else {
            // Direct path if both are on the same side of the corridor
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
        
        // Create instructions from path segments
        var instructions: [String] = []
        
        // Add start instruction
        instructions.append("Start at \(start.name) (\(start.roomNumber))")
        
        // Add segment instructions
        for segment in pathSegments {
            instructions.append(segment.instruction)
        }
        
        // Add destination instruction
        instructions.append("Arrive at \(destination.name) (\(destination.roomNumber))")
        
        // Calculate approximate distance
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
            
            // Convert from points to approximate meters (adjust this factor based on your map scale)
            let metersPerPoint: CGFloat = 0.2
            totalDistance += segmentDistance * metersPerPoint
        }
        
        return totalDistance
    }
}
