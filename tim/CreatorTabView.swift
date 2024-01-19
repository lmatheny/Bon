////
////  CreatorTabView.swift
////  tim
////
////  Created by Luke Matheny on 1/16/24.
////
//
//import SwiftUI
//import FirebaseCore
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseStorage
//
//
//struct CreatorTabView: View {
//    let auth = Auth.auth()
//    let unique: String
//    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
//    @State private var planCreator: String = ""
//
//    func canEdit() {
//        // Assuming you have a Firestore collection named "yourCollection" and a document with a specific documentID
//        let db = Firestore.firestore()
//        let docRef = db.collection("AllPlans").document(unique)
//
//        docRef.getDocument { document, error in
//            if let document = document, document.exists {
//                if let creator = document["creator"] as? String {
//                    self.planCreator = creator
//                }
//
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                if(planCreator == authEmail) {
//                      HStack {
//                          Spacer()
//                          Text("Edit Plan").foregroundColor(.blue).font(.system(size: 17.5))
//                          Image(systemName: "pencil.circle")
//                              .foregroundColor(.blue)
//                          Spacer()
//
//                      }
//
//                }
//            }.onAppear {
//                canEdit()
//            }
//        }
//    }
//}
//
//struct CreatorTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreatorTabView(unique: "TestUnique")
//    }
//}
