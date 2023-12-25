import SwiftUI
import Firebase
import FirebaseFirestore

class CurrentPlansViewModel: ObservableObject {
    @Published var currentPlans: [CurrentPlans] = []

    private var db = Firestore.firestore()

    func fetchUserDocumentData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("No current user email")
            return
        }

        db.collection("SelectedPlans")
            .document("users")
            .collection(currentUserEmail)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }

                // Ensure "Create New Plan" is the first element in the array
                self.currentPlans = [CurrentPlans(display: "Create New Plan", unique: "test", creator: "test", fav: "test")]

                // Separate plans with fav "yes" and "no"
                var favYesPlans: [CurrentPlans] = []
                var favNoPlans: [CurrentPlans] = []

                for document in documents {
                    let data = document.data()
                    let display = data["display"] as? String ?? ""
                    let unique = data["unique"] as? String ?? ""
                    let creator = data["creator"] as? String ?? ""
                    let fav = data["fav"] as? String ?? ""

                    let plan = CurrentPlans(display: display, unique: unique, creator: creator, fav: fav)

                    if fav == "yes" {
                        favYesPlans.append(plan)
                    } else {
                        favNoPlans.append(plan)
                    }
                }

                // Concatenate the arrays, putting fav "yes" plans at index 1
                self.currentPlans += favYesPlans + favNoPlans
            }
    }
}

