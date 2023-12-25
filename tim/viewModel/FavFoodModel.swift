//
//  FavFoodModel.swift
//  tim
//
//  Created by Luke Matheny on 7/19/23.
//


import Foundation
import FirebaseFirestore
import SwiftUI
import FirebaseCore
import FirebaseAuth
class FavFoodModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    
    @Published var favs = [aFav]()
    private var db = Firestore.firestore()
    
    
    func getAllFavData(email: String) {
       
        
        db.collection("FavFoods").document("users").collection(email).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.favs = documents.map { (queryDocumentSnapshot) -> aFav in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let name2 = data["calories"] as? String ?? ""
                let name4 = data["favStatus"] as? String ?? ""
                
                return aFav(name: name, name2: name2,  name4: name4)
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



