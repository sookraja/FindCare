//
//  MyMapViewController.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-26.
//

import UIKit

class MyMapViewController: UIViewController, UIScrollViewDelegate, LocationMarkerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapImageView: UIImageView!
    
    var currentRotationIndex: Int = 0
    let rotationAngles: [CGFloat] = [0, CGFloat.pi/2, CGFloat.pi, 3 * CGFloat.pi/2]
    
    let navigationManager = NavigationManager()
    var locationMarkers: [LocationMarkerView] = []
    var pathLayer: CAShapeLayer?
    
    var navigationButton: UIButton!
    var navigationPanel: UIView!
    var startLocationButton: UIButton!
    var destLocationButton: UIButton!
    var navigateButton: UIButton!
    var clearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupNavigationUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        centerImage()
        
        if locationMarkers.isEmpty {
            setupLocationMarkers()
        }
        
        updateMarkerPositions()
        
        navigationButton.frame = CGRect(
            x: view.bounds.width - 60,
            y: view.safeAreaInsets.top + 20,
            width: 44,
            height: 44
        )
        
        navigationPanel.frame = CGRect(
            x: 0,
            y: view.bounds.height,
            width: view.bounds.width,
            height: 200
        )
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 4.0
        
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.clipsToBounds = true
        
        DispatchQueue.main.async {
            self.scrollView.zoomScale = 1.0
            self.centerImage()
        }
    }
    
    func setupLocationMarkers() {
        locationMarkers.forEach { $0.removeFromSuperview() }
        locationMarkers.removeAll()
        
        for (index, location) in navigationManager.locations.enumerated() {
            let marker = LocationMarkerView(location: location)
            marker.delegate = self
            marker.tag = index
            scrollView.addSubview(marker)
            locationMarkers.append(marker)
            
            marker.updatePosition(at: location.coordinate, scale: scrollView.zoomScale)
        }
        
        locationMarkers.forEach { marker in
            scrollView.bringSubviewToFront(marker)
        }
    }
    
    func setupNavigationUI() {
        navigationButton = UIButton(type: .system)
        navigationButton.frame = CGRect(x: view.bounds.width - 60, y: view.safeAreaInsets.top + 20, width: 44, height: 44)
        navigationButton.backgroundColor = .systemBlue
        navigationButton.layer.cornerRadius = 22
        navigationButton.tintColor = .white
        navigationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .touchUpInside)
        view.addSubview(navigationButton)
        
        navigationPanel = UIView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 200))
        navigationPanel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        navigationPanel.layer.cornerRadius = 20
        navigationPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navigationPanel.layer.shadowColor = UIColor.black.cgColor
        navigationPanel.layer.shadowOpacity = 0.3
        navigationPanel.layer.shadowOffset = CGSize(width: 0, height: -3)
        navigationPanel.layer.shadowRadius = 5
        view.addSubview(navigationPanel)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 15, width: navigationPanel.bounds.width - 40, height: 30))
        titleLabel.text = "Navigation"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        navigationPanel.addSubview(titleLabel)
        
        startLocationButton = UIButton(type: .system)
        startLocationButton.frame = CGRect(x: 20, y: 55, width: navigationPanel.bounds.width - 40, height: 40)
        startLocationButton.setTitle("Select Start Location", for: .normal)
        startLocationButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        startLocationButton.layer.cornerRadius = 8
        startLocationButton.addTarget(self, action: #selector(startLocationButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(startLocationButton)
        
        destLocationButton = UIButton(type: .system)
        destLocationButton.frame = CGRect(x: 20, y: 105, width: navigationPanel.bounds.width - 40, height: 40)
        destLocationButton.setTitle("Select Destination", for: .normal)
        destLocationButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        destLocationButton.layer.cornerRadius = 8
        destLocationButton.addTarget(self, action: #selector(destLocationButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(destLocationButton)
        
        navigateButton = UIButton(type: .system)
        navigateButton.frame = CGRect(x: 20, y: 155, width: (navigationPanel.bounds.width - 50) / 2, height: 40)
        navigateButton.setTitle("Navigate", for: .normal)
        navigateButton.backgroundColor = .systemBlue
        navigateButton.setTitleColor(.white, for: .normal)
        navigateButton.layer.cornerRadius = 8
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(navigateButton)
        
        clearButton = UIButton(type: .system)
        clearButton.frame = CGRect(x: navigationPanel.bounds.width/2 + 5, y: 155, width: (navigationPanel.bounds.width - 50) / 2, height: 40)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        navigationPanel.addSubview(clearButton)
    }
    
    @IBAction func zoomInButtonTapped(_ sender: UIButton) {
        let currentScale = scrollView.zoomScale
        let newScale = min(currentScale * 1.5, scrollView.maximumZoomScale)
        scrollView.setZoomScale(newScale, animated: true)
    }
    
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
        let currentScale = scrollView.zoomScale
        let newScale = max(currentScale / 1.5, scrollView.minimumZoomScale)
        scrollView.setZoomScale(newScale, animated: true)
    }
    
    @IBAction func rotateClockwiseButtonTapped(_ sender: UIButton) {
        currentRotationIndex = (currentRotationIndex + 1) % rotationAngles.count
        let angle = rotationAngles[currentRotationIndex]
        
        UIView.animate(withDuration: 0.3) {
            self.mapImageView.transform = CGAffineTransform(rotationAngle: angle)
        } completion: { _ in
            self.updateMarkerPositions()
            
            if let pathSegments = self.navigationManager.findPath() {
                self.drawPath(pathSegments)
            }
        }
    }
    
    @IBAction func rotateCounterclockwiseButtonTapped(_ sender: UIButton) {
        currentRotationIndex = (currentRotationIndex - 1 + rotationAngles.count) % rotationAngles.count
        let angle = rotationAngles[currentRotationIndex]
        
        UIView.animate(withDuration: 0.3) {
            self.mapImageView.transform = CGAffineTransform(rotationAngle: angle)
        } completion: { _ in
            self.updateMarkerPositions()
            
            if let pathSegments = self.navigationManager.findPath() {
                self.drawPath(pathSegments)
            }
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        currentRotationIndex = 0
        
        scrollView.zoomScale = 1.0
        mapImageView.transform = .identity
        
        centerImage()
        
        updateMarkerPositions()
    }
    
    func locationMarkerTapped(_ location: Location) {
        showLocationOptions(location)
    }
    
    func showLocationOptions(_ location: Location) {
        let alert = UIAlertController(title: location.name, message: "Room: \(location.roomNumber)", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Set as Start", style: .default) { [weak self] _ in
            self?.navigationManager.setStartLocation(location)
            self?.startLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
            self?.updateMarkerAppearances()
            
            if self?.navigationPanel.frame.origin.y ?? 0 >= self?.view.bounds.height ?? 0 {
                self?.navigationButtonTapped()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Set as Destination", style: .default) { [weak self] _ in
            self?.navigationManager.setDestinationLocation(location)
            self?.destLocationButton.setTitle("\(location.name) (\(location.roomNumber))", for: .normal)
            self?.updateMarkerAppearances()
            
            if self?.navigationPanel.frame.origin.y ?? 0 >= self?.view.bounds.height ?? 0 {
                self?.navigationButtonTapped()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc func navigationButtonTapped() {
       
        UIView.animate(withDuration: 0.3) {
            if self.navigationPanel.frame.origin.y >= self.view.bounds.height {
                self.navigationPanel.frame.origin.y = self.view.bounds.height - 200
            } else {
                self.navigationPanel.frame.origin.y = self.view.bounds.height
            }
        }
    }
    
    @objc func startLocationButtonTapped() {
        showLocationSelectionAlert(forStart: true)
    }
    
    @objc func destLocationButtonTapped() {
        showLocationSelectionAlert(forStart: false)
    }
    
    func showLocationSelectionAlert(forStart: Bool) {
        let title = forStart ? "Select Start Location" : "Select Destination"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
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
        
        present(alert, animated: true)
    }
    
    @objc func navigateButtonTapped() {
        guard navigationManager.selectedStartLocation != nil && navigationManager.selectedDestLocation != nil else {
            let alert = UIAlertController(title: "Navigation Error", message: "Please select both start and destination locations", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let pathSegments = navigationManager.findPath() else { return }
        
        drawPath(pathSegments)
    }
    
    @objc func clearButtonTapped() {
        navigationManager.clearNavigation()
        
        startLocationButton.setTitle("Select Start Location", for: .normal)
        destLocationButton.setTitle("Select Destination", for: .normal)
        
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        
        updateMarkerAppearances()
    }
    
    func drawPath(_ pathSegments: [NavigationManager.PathSegment]) {
        pathLayer?.removeFromSuperlayer()
        
        let path = UIBezierPath()
        
        if let firstSegment = pathSegments.first {
            path.move(to: CGPoint(x: firstSegment.from.x * scrollView.zoomScale,
                                 y: firstSegment.from.y * scrollView.zoomScale))
        }
        
        for segment in pathSegments {
            path.addLine(to: CGPoint(x: segment.to.x * scrollView.zoomScale,
                                    y: segment.to.y * scrollView.zoomScale))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [10, 5]
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.5
        shapeLayer.add(animation, forKey: "drawPathAnimation")
        
        scrollView.layer.addSublayer(shapeLayer)
        pathLayer = shapeLayer
    }
    
    func updateMarkerAppearances() {
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
    
    func updateMarkerPositions() {
        let scale = scrollView.zoomScale
        
        for (index, marker) in locationMarkers.enumerated() {
            let location = navigationManager.locations[index]
            
            if currentRotationIndex != 0 {
                let angle = rotationAngles[currentRotationIndex]
                let centerX = scrollView.contentSize.width / 2
                let centerY = scrollView.contentSize.height / 2
                
                let relativeX = location.coordinate.x - centerX
                let relativeY = location.coordinate.y - centerY
                
                let rotatedX = relativeX * cos(angle) - relativeY * sin(angle)
                let rotatedY = relativeX * sin(angle) + relativeY * cos(angle)
                
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
        centerImage()
        
        updateMarkerPositions()
        
        if let pathSegments = navigationManager.findPath() {
            drawPath(pathSegments)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if let pathSegments = navigationManager.findPath() {
            drawPath(pathSegments)
        }
    }
    
    func centerImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
