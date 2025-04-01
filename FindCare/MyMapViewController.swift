//
//  MyMapViewController.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-26.
//

import UIKit

class MyMapViewController: UIViewController, UIScrollViewDelegate, LocationMarkerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    // MARK: - Properties
    private var currentRotationIndex: Int = 0
    private let rotationAngles: [CGFloat] = [0, CGFloat.pi/2, CGFloat.pi, 3 * CGFloat.pi/2]
    
    // Navigation properties
    private let navigationManager = NavigationManager()
    private var locationMarkers: [LocationMarkerView] = []
    private var pathLayer: CAShapeLayer?
    
    private var navigationButton: UIButton!
    private var navigationPanel: UIView!
    private var startLocationButton: UIButton!
    private var destLocationButton: UIButton!
    private var navigateButton: UIButton!
    private var clearButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupNavigationUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Center the image initially
        centerImage()
        
        // Setup location markers after layout is complete
        if locationMarkers.isEmpty {
            setupLocationMarkers()
        }
        
        // Update marker positions
        updateMarkerPositions()
        
        // Make sure navigation button is properly positioned
        navigationButton.frame = CGRect(
            x: view.bounds.width - 60,
            y: view.safeAreaInsets.top + 20,
            width: 44,
            height: 44
        )
        
        // Make sure navigation panel is properly positioned
        navigationPanel.frame = CGRect(
            x: 0,
            y: view.bounds.height,
            width: view.bounds.width,
            height: 200
        )
    }
    
    // MARK: - Setup Methods
    private func setupScrollView() {
        // Basic scroll view setup
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 4.0
        
        // Ensure the image view is properly set up
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.clipsToBounds = true
        
        // Set initial zoom to fit the map properly
        DispatchQueue.main.async {
            self.scrollView.zoomScale = 1.0
            self.centerImage()
        }
    }
    
    private func setupLocationMarkers() {
        // Remove existing markers
        locationMarkers.forEach { $0.removeFromSuperview() }
        locationMarkers.removeAll()
        
        // Add markers for each location
        for (index, location) in navigationManager.locations.enumerated() {
            let marker = LocationMarkerView(location: location)
            marker.delegate = self
            marker.tag = index  // Store index for later reference
            scrollView.addSubview(marker)
            locationMarkers.append(marker)
            
            // Position marker
            marker.updatePosition(at: location.coordinate, scale: scrollView.zoomScale)
        }
        
        // Make sure markers are above the map but below other UI elements
        locationMarkers.forEach { marker in
            scrollView.bringSubviewToFront(marker)
        }
    }
    
    private func setupNavigationUI() {
        // Add navigation button
        navigationButton = UIButton(type: .system)
        navigationButton.frame = CGRect(x: view.bounds.width - 60, y: view.safeAreaInsets.top + 20, width: 44, height: 44)
        navigationButton.backgroundColor = .systemBlue
        navigationButton.layer.cornerRadius = 22
        navigationButton.tintColor = .white
        navigationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .touchUpInside)
        view.addSubview(navigationButton)
        
        // Create navigation panel
        navigationPanel = UIView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 200))
        navigationPanel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        navigationPanel.layer.cornerRadius = 20
        navigationPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navigationPanel.layer.shadowColor = UIColor.black.cgColor
        navigationPanel.layer.shadowOpacity = 0.3
        navigationPanel.layer.shadowOffset = CGSize(width: 0, height: -3)
        navigationPanel.layer.shadowRadius = 5
        view.addSubview(navigationPanel)
        
        // Add title label
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: navigationPanel.bounds.width - 40, height: 30))
        titleLabel.text = "Navigation"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        navigationPanel.addSubview(titleLabel)
        
        // Add start location button
        startLocationButton = UIButton(type: .system)
        startLocationButton.frame = CGRect(x: 20, y: 55, width: navigationPanel.bounds.width - 40, height: 40)
        startLocationButton.setTitle("Select Start Location", for: .normal)
        startLocationButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        startLocationButton.layer.cornerRadius = 8
        startLocationButton.addTarget(self, action: #selector(startLocationButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(startLocationButton)
        
        // Add destination button
        destLocationButton = UIButton(type: .system)
        destLocationButton.frame = CGRect(x: 20, y: 105, width: navigationPanel.bounds.width - 40, height: 40)
        destLocationButton.setTitle("Select Destination", for: .normal)
        destLocationButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        destLocationButton.layer.cornerRadius = 8
        destLocationButton.addTarget(self, action: #selector(destLocationButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(destLocationButton)
        
        // Add navigate button
        navigateButton = UIButton(type: .system)
        navigateButton.frame = CGRect(x: 20, y: 155, width: (navigationPanel.bounds.width - 50) / 2, height: 40)
        navigateButton.setTitle("Navigate", for: .normal)
        navigateButton.backgroundColor = .systemBlue
        navigateButton.setTitleColor(.white, for: .normal)
        navigateButton.layer.cornerRadius = 8
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(navigateButton)
        
        // Add clear button
        clearButton = UIButton(type: .system)
        clearButton.frame = CGRect(x: navigationPanel.bounds.width/2 + 5, y: 155, width: (navigationPanel.bounds.width - 50) / 2, height: 40)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(clearButton)
    }
    
    // MARK: - Button Actions
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
        } completion: { _ in
            // Update marker positions after rotation
            self.updateMarkerPositions()
            
            // Redraw path if needed
            if let pathSegments = self.navigationManager.findPath() {
                self.drawPath(pathSegments)
            }
        }
    }
    
    @IBAction func rotateCounterclockwiseButtonTapped(_ sender: UIButton) {
        // Move to previous rotation angle
        currentRotationIndex = (currentRotationIndex - 1 + rotationAngles.count) % rotationAngles.count
        let angle = rotationAngles[currentRotationIndex]
        
        // Apply rotation directly to image view
        UIView.animate(withDuration: 0.3) {
            self.mapImageView.transform = CGAffineTransform(rotationAngle: angle)
        } completion: { _ in
            // Update marker positions after rotation
            self.updateMarkerPositions()
            
            // Redraw path if needed
            if let pathSegments = self.navigationManager.findPath() {
                self.drawPath(pathSegments)
            }
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // Reset rotation
        currentRotationIndex = 0
        
        // Reset zoom and rotation
        scrollView.zoomScale = 1.0
        mapImageView.transform = .identity
        
        // Center the image
        centerImage()
        
        // Update marker positions
        updateMarkerPositions()
    }
    
    // MARK: - Navigation Methods
    func locationMarkerTapped(_ location: Location) {
        // Show location options
        showLocationOptions(location)
    }
    
     func showLocationOptions(_ location: Location) {
        // Create alert controller
        let alert = UIAlertController(title: location.name, message: "Room: \(location.roomNumber)", preferredStyle: .actionSheet)
        
        // Add actions
        alert.addAction(UIAlertAction(title: "Set as Start", style: .default) { [weak self] _ in
            self?.navigationManager.setStartLocation(location)
            self?.startLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
            self?.updateMarkerAppearances()
            
            // Show navigation panel if it's hidden
            if self?.navigationPanel.frame.origin.y ?? 0 >= self?.view.bounds.height ?? 0 {
                self?.navigationButtonTapped()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Set as Destination", style: .default) { [weak self] _ in
            self?.navigationManager.setDestinationLocation(location)
            self?.destLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
            self?.updateMarkerAppearances()
            
            // Show navigation panel if it's hidden
            if self?.navigationPanel.frame.origin.y ?? 0 >= self?.view.bounds.height ?? 0 {
                self?.navigationButtonTapped()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        present(alert, animated: true)
    }
    
    @objc private func navigationButtonTapped() {
       
        UIView.animate(withDuration: 0.3) {
            if self.navigationPanel.frame.origin.y >= self.view.bounds.height {
                // Show panel
                self.navigationPanel.frame.origin.y = self.view.bounds.height - 200
            } else {
                // Hide panel
                self.navigationPanel.frame.origin.y = self.view.bounds.height
            }
        }
    }
    
    @objc private func startLocationButtonTapped() {
        showLocationSelectionAlert(forStart: true)
    }
    
    @objc private func destLocationButtonTapped() {
        showLocationSelectionAlert(forStart: false)
    }
    
    private func showLocationSelectionAlert(forStart: Bool) {
        let title = forStart ? "Select Start Location" : "Select Destination"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        // Add an action for each location
        for location in navigationManager.locations {
            alert.addAction(UIAlertAction(title: "\(location.name) (\(location.roomNumber))", style: .default) { [weak self] _ in
                if forStart {
                    self?.navigationManager.setStartLocation(location)
                    self?.startLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
                } else {
                    self?.navigationManager.setDestinationLocation(location)
                    self?.destLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
                }
                self?.updateMarkerAppearances()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        present(alert, animated: true)
    }
    
    @objc private func navigateButtonTapped() {
        guard navigationManager.selectedStartLocation != nil && navigationManager.selectedDestLocation != nil else {
            // Show alert if start or destination is not selected
            let alert = UIAlertController(title: "Navigation Error", message: "Please select both start and destination locations", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Find path between locations
        guard let pathSegments = navigationManager.findPath() else { return }
        
        // Draw path on map
        drawPath(pathSegments)
        
        // Show navigation instructions
        showNavigationInstructions()
    }
    
    @objc private func clearButtonTapped() {
        // Clear selected locations
        navigationManager.clearNavigation()
        
        // Reset buttons
        startLocationButton.setTitle("Select Start Location", for: .normal)
        destLocationButton.setTitle("Select Destination", for: .normal)
        
        // Remove path
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        
        // Reset marker appearances
        updateMarkerAppearances()
    }
    
    private func drawPath(_ pathSegments: [NavigationManager.PathSegment]) {
        // Remove existing path
        pathLayer?.removeFromSuperlayer()
        
        // Create path
        let path = UIBezierPath()
        
        if let firstSegment = pathSegments.first {
            path.move(to: CGPoint(x: firstSegment.from.x * scrollView.zoomScale,
                                 y: firstSegment.from.y * scrollView.zoomScale))
        }
        
        // Add lines for each segment, accounting for zoom scale
        for segment in pathSegments {
            path.addLine(to: CGPoint(x: segment.to.x * scrollView.zoomScale,
                                    y: segment.to.y * scrollView.zoomScale))
        }
        
        // Create shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [10, 5]
        
        // Add animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.5
        shapeLayer.add(animation, forKey: "drawPathAnimation")
        
        // Add to scroll view
        scrollView.layer.addSublayer(shapeLayer)
        pathLayer = shapeLayer
    }
    
    private func showNavigationInstructions() {
        let instructions = navigationManager.getNavigationInstructions()
        
        // Show alert with instructions
        let alert = UIAlertController(title: "Navigation Instructions", message: instructions.joined(separator: "\n\n"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateMarkerAppearances() {
        // Reset all markers
        for marker in locationMarkers {
            marker.markerHighlighted = false
        }
        
     
        if let start = navigationManager.selectedStartLocation {
            if let index = navigationManager.locations.firstIndex(where: { $0.id == start.id }),
               index < locationMarkers.count {
                locationMarkers[index].markerHighlighted = true
                locationMarkers[index].backgroundColor = .systemGreen
            }
        }
        
       
        if let destination = navigationManager.selectedDestLocation {
            if let index = navigationManager.locations.firstIndex(where: { $0.id == destination.id }),
               index < locationMarkers.count {
                locationMarkers[index].markerHighlighted = true
                locationMarkers[index].backgroundColor = .systemRed
            }
        }
    }
    
    private func updateMarkerPositions() {
        // Update position of all markers based on current zoom and rotation
        let scale = scrollView.zoomScale
        
        for (index, marker) in locationMarkers.enumerated() {
            let location = navigationManager.locations[index]
            
            // Calculate rotated position if needed
            if currentRotationIndex != 0 {
                let angle = rotationAngles[currentRotationIndex]
                let centerX = scrollView.contentSize.width / 2
                let centerY = scrollView.contentSize.height / 2
                
                // Calculate position relative to center
                let relativeX = location.coordinate.x - centerX
                let relativeY = location.coordinate.y - centerY
                
                // Rotate point
                let rotatedX = relativeX * cos(angle) - relativeY * sin(angle)
                let rotatedY = relativeX * sin(angle) + relativeY * cos(angle)
                
                // Convert back to absolute position
                let newX = rotatedX + centerX
                let newY = rotatedY + centerY
                
                marker.updatePosition(at: CGPoint(x: newX, y: newY), scale: scale)
            } else {
                marker.updatePosition(at: location.coordinate, scale: scale)
            }
        }
    }
    
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image after zooming
        centerImage()
        
        // Update marker positions
        updateMarkerPositions()
        
        // Redraw path if needed
        if let pathSegments = navigationManager.findPath() {
            drawPath(pathSegments)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
       
        if let pathSegments = navigationManager.findPath() {
            drawPath(pathSegments)
        }
    }
    
    private func centerImage() {
       
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
