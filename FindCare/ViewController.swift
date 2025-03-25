//
//  ViewController.swift
//  FindCare
//
//  Created by Annette Sookraj on 2025-03-08.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    // MARK: - Properties
    private var currentRotationIndex: Int = 0
    // Define rotation angles in radians (0°, 90°, 180°, 270°)
    private let rotationAngles: [CGFloat] = [0, CGFloat.pi/2, CGFloat.pi, 3 * CGFloat.pi/2]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
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
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // Reset rotation
        currentRotationIndex = 0
        
        // Reset zoom and rotation
        scrollView.zoomScale = scrollView.minimumZoomScale
        mapImageView.transform = .identity
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image after zooming
        centerImage()
    }
    
    private func centerImage() {
        // Simple centering logic
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
