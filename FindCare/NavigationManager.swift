import UIKit

class NavigationManager: NSObject {
    // MARK: - Properties
    private(set) var locations: [Location] = []
    private(set) var selectedStartLocation: Location?
    private(set) var selectedDestLocation: Location?
    
    // MARK: - Path Model
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
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocations()
    }
    
    // MARK: - Location Setup
    private func setupLocations() {
        // Define key locations in the M Building
        locations = [
            Location(id: "entrance1", name: "Main Entrance", roomNumber: "M-E1", type: .entrance, coordinate: CGPoint(x: 130, y: 460)),
            Location(id: "m101", name: "Classroom", roomNumber: "M101", type: .classroom, coordinate: CGPoint(x: 180, y: 430)),
            Location(id: "m102", name: "Classroom", roomNumber: "M102", type: .classroom, coordinate: CGPoint(x: 230, y: 430)),
            Location(id: "m103", name: "Computer Lab", roomNumber: "M103", type: .lab, coordinate: CGPoint(x: 280, y: 430)),
            Location(id: "m104", name: "Faculty Office", roomNumber: "M104", type: .office, coordinate: CGPoint(x: 330, y: 430)),
            Location(id: "washroom1", name: "Washroom", roomNumber: "M-W1", type: .washroom, coordinate: CGPoint(x: 380, y: 430)),
            Location(id: "stairs1", name: "Stairwell", roomNumber: "M-S1", type: .stairs, coordinate: CGPoint(x: 430, y: 430)),
            Location(id: "exit1", name: "Emergency Exit", roomNumber: "M-X1", type: .exit, coordinate: CGPoint(x: 450, y: 460)),
            
            // Bottom row of rooms
            Location(id: "m201", name: "Classroom", roomNumber: "M201", type: .classroom, coordinate: CGPoint(x: 180, y: 490)),
            Location(id: "m202", name: "Classroom", roomNumber: "M202", type: .classroom, coordinate: CGPoint(x: 230, y: 490)),
            Location(id: "m203", name: "Computer Lab", roomNumber: "M203", type: .lab, coordinate: CGPoint(x: 280, y: 490)),
            Location(id: "m204", name: "Faculty Office", roomNumber: "M204", type: .office, coordinate: CGPoint(x: 330, y: 490)),
            Location(id: "washroom2", name: "Washroom", roomNumber: "M-W2", type: .washroom, coordinate: CGPoint(x: 380, y: 490))
        ]
    }
    
    // MARK: - Navigation Methods
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
        
        // For simplicity, we'll create a direct path with waypoints
        // In a real app, you would implement A* or Dijkstra's algorithm
        
        // Create a simple path with waypoints
        var segments: [PathSegment] = []
        
        // Determine if we need to go through the corridor
        let needsCorridor = abs(start.coordinate.y - destination.coordinate.y) > 20
        
        if needsCorridor {
            // Add segment from start to corridor
            let corridorY = 460 // Y-coordinate of the main corridor
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