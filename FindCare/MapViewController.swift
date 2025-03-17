import UIKit
import SwiftUI

class MapViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var hostingController: UIHostingController<IndoorMapView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ MapViewController is running!")  // This MUST appear in the console
        
        // Create and present SwiftUI View inside UIKit
        let indoorMapView = IndoorMapView()
        hostingController = UIHostingController(rootView: indoorMapView)
        
        // Add hostingController's view as a child view controller
        addChild(hostingController)
        
        // Create a UIScrollView for zooming
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self  // Set delegate for zooming functionality
        view.addSubview(scrollView)
        
        // Add hostingController's view inside the scrollView
        scrollView.addSubview(hostingController.view)
        
        // Set constraints to make the scrollView cover the full screen
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set hostingController view's frame to fit the scrollView
        hostingController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        hostingController.didMove(toParent: self)
        
        // Enable zooming functionality
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
    }
}

extension MapViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // Return the hostingController's view to enable zooming
        return hostingController.view
    }
}






