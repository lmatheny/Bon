//
//  GoalViewModel.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//
import Foundation
import FirebaseFirestore
import SwiftUI
import FirebaseCore
import FirebaseAuth
class GoalViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    
    @Published var foods = [Food]()
    private var db = Firestore.firestore()
    
    
    func getAllData(email: String) {
       
        
        db.collection("DailyFoods").document("users").collection(email).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.foods = documents.map { (queryDocumentSnapshot) -> Food in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let name2 = data["calories"] as? String ?? ""
                let name3 = data["foodID"] as? String ?? ""
                let name4 = data["favStatus"] as? String ?? ""
                return Food(name: name, name2: name2, name3: name3, name4: name4)
            }
        }
    }
        
        
        
        
        
//        db.collection("calorieGoal").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            self.currentGoal = documents.map { (queryDocumentSnapshot) -> Goal in
//                let data = queryDocumentSnapshot.data()
//                let goal = data["goal"] as? String ?? ""
//                return Goal(goal: goal)
//            }
//        }
    }



