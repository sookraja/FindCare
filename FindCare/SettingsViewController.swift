//
//  SettingsViewController.swift
//  FindCare
//
//  Created by Edgar Ponce on 2025-03-26.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
        if let sourceVC = unwindSegue.source as? HelpScreenViewController {
        }
    }

}
