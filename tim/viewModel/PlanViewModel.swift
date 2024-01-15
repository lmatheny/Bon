//
//  PlanViewModel.swift
//  tim
//
//  Created by Luke Matheny on 12/31/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import FirebaseCore
import FirebaseAuth
class PlanViewdModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    @State public var emailStr = ""
    
    @Published var plans = [Plan]()
    private var db = Firestore.firestore()
    
    
    func getAllFavData(email: String) {
        
        
        db.collection("AllPlans").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.plans = documents.map { (queryDocumentSnapshot) -> Plan in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
               
                
                return Plan(name: name)
            }
        }
    }
    
}
