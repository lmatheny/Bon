//
//  TodoViewModel.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import Foundation
import FirebaseFirestore

class TodoViewModel: ObservableObject {

    @Published var todos = [Todo]()

    private var db = Firestore.firestore()

    func getAllData() {
        db.collection("todos").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.todos = documents.map { (queryDocumentSnapshot) -> Todo in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let name2 = "hello"
                return Todo(name: name, name2: name2)
            }
        }
    }

    func addNewData(name: String) {
           do {
               _ = try db.collection("todos").addDocument(data: ["name": name])
               
           }
           catch {
               print(error.localizedDescription)
           }
       }
}
