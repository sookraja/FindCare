//
//  ViewController.swift
//  FindCare
//
//  Created by Annette Sookraj on 2025-03-08.
//

import UIKit
import Firebase
import FirebaseFirestore

struct DBDepartment : Codable {
    let departmentId: String
    let name: String?
    let description: String?
    let staff: [DBStaff]?
    
    enum CodingKeys: String, CodingKey {
            case departmentId = "id" // Maps "id" to departmentId
            case name = "name"      // Maps "name" to name
            case description                   // No mapping needed if field name matches
            case staff                         // No mapping needed if field name matches
        }
}

class ViewController: UIViewController {
    
    @IBOutlet var departmentLabel: UILabel!
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private let db = Firestore.firestore()

    private let departmentCollection = Firestore.firestore().collection("Departments")
    
    private func departmentDocument(departmentId: String) -> DocumentReference{
        departmentCollection.document(departmentId)
    }
    
    func getDepartment(departmentId: String) async throws -> DBDepartment {
        let document = try await departmentDocument(departmentId: departmentId).getDocument()
        return try document.data(as: DBDepartment.self, decoder: decoder)
    }
    
    func fetchDepartment(departmentId: String) {
        // Validate departmentId
        guard !departmentId.isEmpty else {
            DispatchQueue.main.async {
                self.departmentLabel.text = "Invalid department ID"
            }
            return
        }
        
        // Show loading state
        DispatchQueue.main.async {
            self.departmentLabel.text = "Loading..."
        }
        
        db.collection("departments").document(departmentId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching department: \(error)")
                DispatchQueue.main.async {
                    self.departmentLabel.text = "Error fetching department"
                }
                return
            }
            
            if let document = document, document.exists {
                do {
                    let department = try document.data(as: DBDepartment.self)
                    DispatchQueue.main.async {
                        self.departmentLabel.text = department.name ?? "Unknown Department"
                    }
                } catch {
                    print("Error decoding department: \(error)")
                    DispatchQueue.main.async {
                        self.departmentLabel.text = "Error decoding department"
                    }
                }
            } else {
                print("No such document")
                DispatchQueue.main.async {
                    self.departmentLabel.text = "Department not found"
                }
            }
        }
    }
    
    func testFirestoreConnection() {
        db.collection("departments").document("LWk9SF7uf7Smp0eyBv3w").getDocument { (document, error) in
            if let error = error {
                print("❌ Firestore Error: \(error)")
            } else {
                print("✅ Firestore is connected!")
            }
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //try await getDepartment(departmentId: "1")
        testFirestoreConnection()
        fetchDepartment(departmentId: "LWk9SF7uf7Smp0eyBv3w")
    }


}

