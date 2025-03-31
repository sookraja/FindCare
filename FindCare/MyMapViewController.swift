//
//  MyMapViewController.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-26.
//

import UIKit

class MyMapViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    // Add properties for the dots and path
    private var dotsView: DotsAndPathView!
    private var currentRotationIndex: Int = 0
    private let rotationAngles: [CGFloat] = [0, CGFloat.pi/2, CGFloat.pi, 3 * CGFloat.pi/2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupDotsAndPath()
    }
    
    private func setupScrollView() {
        // Your existing code
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 4.0
        
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.clipsToBounds = true
    }
    
    private func setupDotsAndPath() {
            dotsView = DotsAndPathView(frame: mapImageView.bounds)
            dotsView.isUserInteractionEnabled = true
            
            // Initialize with the map image if available
            if let image = mapImageView.image {
                dotsView.setupWithMapImage(image)
            }
            
            mapImageView.addSubview(dotsView)
            dotsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    
    // Your existing IBAction methods...
    
    // Override the reset function to also reset dot positions
    @IBAction func resetButtonTapped(_ sender: UIButton) {
            // Reset rotation
            currentRotationIndex = 0
            
            // Reset zoom and rotation
            scrollView.zoomScale = scrollView.minimumZoomScale
            mapImageView.transform = .identity
            
            // Reset dot positions
            dotsView.resetDotPositions()
        }
    
    @IBAction func zoomInButtonTapped(_ sender: UIButton) {
            // Simple zoom in with safety check
            let currentScale = scrollView.zoomScale
            let newScale = min(currentScale * 1.5, scrollView.maximumZoomScale)
            scrollView.setZoomScale(newScale, animated: true)
        }
        
        @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
            // Simple zoom out with safety check
            let currentScale = scrollView.zoomScale
            let newScale = max(currentScale / 1.5, scrollView.minimumZoomScale)
            scrollView.setZoomScale(newScale, animated: true)
        }
        
        @IBAction func rotateClockwiseButtonTapped(_ sender: UIButton) {
            // Move to next rotation angle
            currentRotationIndex = (currentRotationIndex + 1) % rotationAngles.count
            let angle = rotationAngles[currentRotationIndex]
            
            // Apply rotation directly to image view
            UIView.animate(withDuration: 0.3) {
                self.mapImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
        
        @IBAction func rotateCounterclockwiseButtonTapped(_ sender: UIButton) {
            // Move to previous rotation angle
            currentRotationIndex = (currentRotationIndex - 1 + rotationAngles.count) % rotationAngles.count
            let angle = rotationAngles[currentRotationIndex]
            
            // Apply rotation directly to image view
            UIView.animate(withDuration: 0.3) {
                self.mapImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    private func centerImage() {
        // Your existing centering logic
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
}

// Custom view for drawing and interacting with dots and path
class DotsAndPathView: UIView {
    
    // Dot properties
    private let dotRadius: CGFloat = 2
    private var startPoint: CGPoint = CGPoint(x: 100, y: 240)
    private var endPoint: CGPoint = CGPoint(x: 300, y: 275)
    
    // Track which dot is being dragged
    private var draggingStartDot = false
    private var draggingEndDot = false
    
    private var wallGrid: [[Bool]] = []
    private let gridSize: CGFloat = 2 // Size of each grid cell
    
    private var pathPoints: [CGPoint] = []
    
    var showDebugGrid: Bool = true
    var showWalls: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
        
        // Add pan gesture recognizer for dragging dots
        //let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        //addGestureRecognizer(panGesture)
    }
    
    override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
        if showDebugGrid && !wallGrid.isEmpty {
                    // Draw grid lines
                    context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
                    context.setLineWidth(0.5)
                    
                    let width = wallGrid[0].count
                    let height = wallGrid.count
                    
                    // Draw vertical lines
                    for x in 0...width {
                        let xPos = CGFloat(x) * gridSize
                        context.move(to: CGPoint(x: xPos, y: 0))
                        context.addLine(to: CGPoint(x: xPos, y: CGFloat(height) * gridSize))
                    }
                    
                    // Draw horizontal lines
                    for y in 0...height {
                        let yPos = CGFloat(y) * gridSize
                        context.move(to: CGPoint(x: 0, y: yPos))
                        context.addLine(to: CGPoint(x: CGFloat(width) * gridSize, y: yPos))
                    }
                    
                    context.strokePath()
                    
                    // Highlight wall cells
                    if showWalls {
                        context.setFillColor(UIColor.red.withAlphaComponent(0.4).cgColor)
                        
                        for y in 0..<height {
                            for x in 0..<width {
                                if wallGrid[y][x] {
                                    let rect = CGRect(
                                        x: CGFloat(x) * gridSize,
                                        y: CGFloat(y) * gridSize,
                                        width: gridSize,
                                        height: gridSize
                                    )
                                    context.fill(rect)
                                }
                            }
                        }
                    }
            
            // Optionally, add grid coordinates for even more detailed debugging
                        let fontSize: CGFloat = min(gridSize * 0.5, 8) // Adjust based on grid size
                        let font = UIFont.systemFont(ofSize: fontSize)
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: UIColor.darkGray
                        ]
                        
                        // Only show coordinates for larger grid sizes to avoid clutter
                        if gridSize >= 20 {
                            for y in 0..<height {
                                for x in 0..<width {
                                    let text = "(\(x),\(y))"
                                    let textRect = CGRect(
                                        x: CGFloat(x) * gridSize + 2,
                                        y: CGFloat(y) * gridSize + 2,
                                        width: gridSize - 4,
                                        height: gridSize - 4
                                    )
                                    text.draw(in: textRect, withAttributes: attributes)
                                }
                            }
                        }
                    }
            
            // Draw the path between dots
            if pathPoints.isEmpty {
                // Calculate path if empty
                pathPoints = findPath(from: startPoint, to: endPoint)
            }
            
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(3)
            
            if !pathPoints.isEmpty {
                context.move(to: pathPoints[0])
                for i in 1..<pathPoints.count {
                    context.addLine(to: pathPoints[i])
                }
                context.strokePath()
            }
            
            // Draw the start dot
            context.setFillColor(UIColor.red.cgColor)
            context.fillEllipse(in: CGRect(x: startPoint.x - dotRadius,
                                           y: startPoint.y - dotRadius,
                                           width: dotRadius * 2,
                                           height: dotRadius * 2))
            
            // Draw the end dot
            context.fillEllipse(in: CGRect(x: endPoint.x - dotRadius,
                                           y: endPoint.y - dotRadius,
                                           width: dotRadius * 2,
                                           height: dotRadius * 2))
        }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            // Check if touch is on either dot
            if isPointInDot(location, dot: startPoint) {
                draggingStartDot = true
            } else if isPointInDot(location, dot: endPoint) {
                draggingEndDot = true
            }
            
        case .changed:
            // Update dot position if dragging
            if draggingStartDot {
                startPoint = location
                setNeedsDisplay()
            } else if draggingEndDot {
                endPoint = location
                setNeedsDisplay()
            }
            
        case .ended, .cancelled:
            // Reset dragging flags
            draggingStartDot = false
            draggingEndDot = false
            
        default:
            break
        }
    }
    
    func detectWallsFromImage(_ image: UIImage) {
            // Convert image to grayscale and detect dark areas as walls
            guard let cgImage = image.cgImage else { return }
            
            let width = Int(bounds.width / gridSize)
            let height = Int(bounds.height / gridSize)
            
            // Initialize grid
            wallGrid = Array(repeating: Array(repeating: false, count: width), count: height)
            
            // Process image to detect walls (simplified)
            // This would require more complex image processing in a real app
            if let provider = cgImage.dataProvider,
               let data = provider.data,
               let bytes = CFDataGetBytePtr(data) {
                
                let bytesPerRow = cgImage.bytesPerRow
                let bitsPerPixel = cgImage.bitsPerPixel
                
                for y in 0..<height {
                    for x in 0..<width {
                        let pixelX = Int(CGFloat(x) * gridSize)
                        let pixelY = Int(CGFloat(y) * gridSize)
                        
                        // Skip if out of bounds
                        if pixelX >= Int(cgImage.width) || pixelY >= Int(cgImage.height) {
                            continue
                        }
                        
                        // Get pixel data (simplified)
                        let offset = (pixelY * bytesPerRow) + (pixelX * bitsPerPixel / 8)
                        let alpha = bytes[offset + 3]
                        
                        // If pixel is dark and opaque, consider it a wall
                        if alpha > 200 {
                            let red = bytes[offset]
                            let green = bytes[offset + 1]
                            let blue = bytes[offset + 2]
                            
                            // Dark pixel detection (adjust threshold as needed)
                            if red < 200 && green < 200 && blue < 200 {
                                wallGrid[y][x] = true
                            }
                        }
                    }
                }
            }
        }
    
    // A* pathfinding
        func findPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
            // Convert points to grid coordinates
            let startGridX = Int(start.x / gridSize)
            let startGridY = Int(start.y / gridSize)
            let endGridX = Int(end.x / gridSize)
            let endGridY = Int(end.y / gridSize)
            
            // Check bounds
            let width = wallGrid[0].count
            let height = wallGrid.count
            
            if startGridX < 0 || startGridX >= width || startGridY < 0 || startGridY >= height ||
               endGridX < 0 || endGridX >= width || endGridY < 0 || endGridY >= height {
                return [start, end] // Direct line if out of bounds
            }
            
            // A* algorithm implementation
            struct Node: Hashable {
                let x, y: Int
                var f, g, h: Int
                var parent: (Int, Int)?
                
                func hash(into hasher: inout Hasher) {
                    hasher.combine(x)
                    hasher.combine(y)
                }
                
                static func == (lhs: Node, rhs: Node) -> Bool {
                    return lhs.x == rhs.x && lhs.y == rhs.y
                }
            }
            
            // Create start and end nodes
            let startNode = Node(x: startGridX, y: startGridY, f: 0, g: 0, h: 0, parent: nil)
            let endNode = Node(x: endGridX, y: endGridY, f: 0, g: 0, h: 0, parent: nil)
            
            var openSet = [startNode]
            var closedSet = Set<Node>()
            
            // Directions: up, right, down, left, and diagonals
            let directions = [
                (0, -1), (1, 0), (0, 1), (-1, 0),
                (1, -1), (1, 1), (-1, 1), (-1, -1)
            ]
            
            while !openSet.isEmpty {
                // Find node with lowest f score
                openSet.sort { $0.f < $1.f }
                let current = openSet.removeFirst()
                
                // If reached end
                if current.x == endNode.x && current.y == endNode.y {
                    // Reconstruct path
                    var path = [(current.x, current.y)]
                    var currentBacktrack = current
                    
                    while let parent = currentBacktrack.parent {
                        path.append(parent)
                        let parentNode = Node(x: parent.0, y: parent.1, f: 0, g: 0, h: 0, parent: nil)
                        if let found = closedSet.first(where: { $0 == parentNode }) {
                            currentBacktrack = found
                        } else {
                            break
                        }
                    }
                    
                    // Convert grid coordinates back to points
                    return path.reversed().map {
                        CGPoint(x: CGFloat($0.0) * gridSize + gridSize/2,
                                y: CGFloat($0.1) * gridSize + gridSize/2)
                    }
                }
                
                closedSet.insert(current)
                
                // Check neighbors
                for dir in directions {
                    let neighborX = current.x + dir.0
                    let neighborY = current.y + dir.1
                    
                    // Skip if out of bounds
                    if neighborX < 0 || neighborX >= width || neighborY < 0 || neighborY >= height {
                        continue
                    }
                    
                    // Skip if wall
                    if wallGrid[neighborY][neighborX] {
                        continue
                    }
                    
                    // Skip if in closed set
                    let neighborNode = Node(x: neighborX, y: neighborY, f: 0, g: 0, h: 0, parent: nil)
                    if closedSet.contains(neighborNode) {
                        continue
                    }
                    
                    // Calculate g, h, and f values
                    let isDiagonal = abs(dir.0) + abs(dir.1) == 2
                    let movementCost = isDiagonal ? 14 : 10 // 10 for cardinal, 14 for diagonal (√2 * 10)
                    let g = current.g + movementCost
                    
                    // Manhattan distance heuristic
                    let h = (abs(neighborX - endNode.x) + abs(neighborY - endNode.y)) * 10
                    let f = g + h
                    
                    // Check if neighbor is in open set with a better path
                    if let existingIndex = openSet.firstIndex(where: { $0 == neighborNode }) {
                        if openSet[existingIndex].g <= g {
                            continue
                        }
                    }
                    
                    // Add neighbor to open set
                    let neighbor = Node(x: neighborX, y: neighborY, f: f, g: g, h: h, parent: (current.x, current.y))
                    if let existingIndex = openSet.firstIndex(where: { $0 == neighborNode }) {
                        openSet[existingIndex] = neighbor
                    } else {
                        openSet.append(neighbor)
                    }
                }
            }
            
            // No path found, return direct line
            return [start, end]
        }
    
    private func isPointInDot(_ point: CGPoint, dot: CGPoint) -> Bool {
        // Check if the touch point is within the dot's radius
        let distance = hypot(point.x - dot.x, point.y - dot.y)
        return distance <= dotRadius * 1.5 // Slightly larger touch area for better UX
    }
    
    func resetDotPositions() {
        // Reset dots to default positions
        startPoint = CGPoint(x: 100, y: 100)
        endPoint = CGPoint(x: 300, y: 200)
        setNeedsDisplay()
    }
    
    // Setup with map image
    func setupWithMapImage(_ image: UIImage) {
        detectWallsFromImage(image)
        pathPoints = findPath(from: startPoint, to: endPoint)
        setNeedsDisplay()
    }
}


