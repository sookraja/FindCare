//
//  ViewController.swift
//  FindCare
//
//  Created by Annette Sookraj on 2025-03-08.
//

import UIKit
import Foundation
import FirebaseFirestore

struct DBStaff : Codable {
    let staffId: Int
    let firstName: String
    let lastName: String
    let phoneNUmber: String
    let role: String
    let email: String
    
}

struct DBDepartment : Codable {
    let departmentId: String
    let name: String
    let description: String?
    let staff: [DBStaff]
}

class ViewController: UIViewController {

    private let departmentCollection = Firestore.firestore().collection("Departments")
    
    private func departmentDocument(departmentId: String) -> DocumentReference{
        departmentCollection.document(departmentId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

