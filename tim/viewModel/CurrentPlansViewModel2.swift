//
//  CurrentPlansViewModel2.swift
//  tim
//
//  Created by Luke Matheny on 1/16/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore

class CurrentPlansViewModel2: ObservableObject {
    @Published var currentPlans: [CurrentPlans] = []
    let auth = Auth.auth()
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")

    private var db = Firestore.firestore()

    func fetchUserDocumentData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("No current user email")
            return
        }

        
        db.collection("SelectedPlans")
            .document("users")
            .collection(currentUserEmail)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }

                // Ensure "Create New Plan" is the first element in the array
                //self.currentPlans = [CurrentPlans(display: "Create New Plan", unique: "test", creator: "test", fav: "test")]

                for document in documents {
                    let data = document.data()
                    let display = data["display"] as? String ?? ""
                    let unique = data["unique"] as? String ?? ""
                    let creator = data["creator"] as? String ?? ""
                    let fav = data["fav"] as? String ?? ""

                    //print("here: \(display), \(unique), \(creator), \(fav)")
                    
                    let plan = CurrentPlans(display: display, unique: unique, creator: creator, fav: fav)
                    self.currentPlans.append(plan)
                }

                // Print plans for debugging
                print("Current Plans: \(self.currentPlans)")
            }
    }

}

