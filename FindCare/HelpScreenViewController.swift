//
//  HelpScreenViewController.swift
//  FindCare
//
//  Created by Annette Sookraj on 2025-03-27.
//

import UIKit

class HelpScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func unwindToHelp(_ unwindSegue: UIStoryboardSegue) {
        if let sourceVC = unwindSegue.source as? MapViewController {
        }
    }
}
