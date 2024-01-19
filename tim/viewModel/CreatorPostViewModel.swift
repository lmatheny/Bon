//
//  PostCreatorViewModel.swift
//  tim
//
//  Created by Luke Matheny on 1/18/24.
//

import Foundation
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
class CreatorPostViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    
    @Published var posts = [CreatorPost]()
    private var db = Firestore.firestore()
    
    
    func getAllData(planName: String) {
        
        
        db.collection("CreatorPosts").document("users").collection(planName).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.posts = documents.map { (queryDocumentSnapshot) -> CreatorPost in
                let data = queryDocumentSnapshot.data()
                let caption = data["caption"] as? String ?? ""
                let date = data["date"] as? String ?? ""
                let likes = data["likes"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let postID = data["postID"] as? String ?? ""
                
                return CreatorPost(caption: caption, date: date, likes: likes, location: location, theID: postID)
            }
        }
    }
    
    
    
}

