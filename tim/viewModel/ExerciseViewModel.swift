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
class ExerciseViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    
    @Published var exercises = [Exercise]()
    @Published var typeFromBD: String = "test"
    @Published var selectedExercise: Exercise? = nil
    private var db = Firestore.firestore()
    
    


    func swapBox(theID: String, theCurrent: String, day: String, selectedSplit: String) {
            let newValue = theCurrent == "yes" ? "no" : "yes"

            let documentRef = db.collection("AllPlans")
                .document(selectedSplit)
                .collection("Split")
                .document(day)
                .collection("theWorkout")
                .document(theID)

            documentRef.setData(["completed": newValue], merge: true) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document updated")
                }
            }
        }
    
    
    func getAllData(email: String, day: String, selectedSplit: String) {
        
        if(selectedSplit == "") {
            print("here")
        }
        
        db.collection("AllPlans")
            .document(selectedSplit)
            .collection("Split")
            .document(day)
            .collection("theWorkout")
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.exercises = documents.map { (queryDocumentSnapshot) -> Exercise in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let name2 = data["reps"] as? String ?? ""
                    let name4 = data["sets"] as? String ?? ""
                    let name5 = data["completed"] as? String ?? ""
                    let name6 = data["id"] as? String ?? ""
                    let name7 = data["weight"] as? String ?? ""
                    let name8 = data["notes"] as? String ?? ""
                    let name9 = data["recReps"] as? String ?? ""
                    let name10 = data["recSets"] as? String ?? ""
                    let planName = "lucaPlan1"
                    return Exercise(name: name, name2: name2, name4: name4, name5: name5, name6: name6, name7: name7, name8: name8, name9: name9, name10: name10, plan: planName)
                }
            }
    }
    
    
    func selectExercise(_ exercise: Exercise) {
          selectedExercise = exercise
      }

      func clearSelectedExercise() {
          selectedExercise = nil
      }
        
}




