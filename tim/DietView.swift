//
//  DietView.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import SwiftUI

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage



struct Item {
    let uuid = UUID()
    let value: String
}

struct DietView: View {
    let auth = Auth.auth()
    let storage = Storage.storage()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
   // let storage = Storage.storage()
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    @State public var emailStr = ""
    
 
    
    @State public var remaining = ""
    @State public var currentGoal = ""
    @State public var currentGoalInt = 0
    @State public var trimming = ""
    @State public var liveCount = 0
    @State public var liveStreak = 0
    @State public var liveEmoji = ""
    @State public var liveCountStr = ""
    @State public var searchingDocStr = ""
    @State public var highestID = 0
    @State public var tempTotal = 0
    @State public var tempHuge = 0
    @State public var tempRow = 0
    @State public var remainingCals = 0
    @State public var tempFoodCals = 0
    @State public var highestStringID = ""
    @State private var presentAlert = false
    @State private var presentAlertAdd = false
    @State private var presentAlertEdit = false
    @State private var presentAlertNew = false
    @State private var newFood: String = ""
    @State private var newCals: String = ""
    @State private var editFood: String = ""
    @State private var editCals: String = ""
    @State private var favStr: String = "star"
  
    var favArray: [String] = []
    @State private var tempFavStr: String = ""
    @State private var editStr: String = ""
    private var db = Firestore.firestore()
    
    @ObservedObject private var viewModel = GoalViewModel()
    @ObservedObject private var viewModelTest = TodoViewModel()
    @ObservedObject private var viewModelFav = FavFoodModel()
    @ObservedObject var viewModel2 = ArrayAdditionViewModel()
    //search
    @State private var searchText = ""
        @State private var searchResults: [String] = []
        let yourArray = [String]()
        @State private var showCancelButton = false

    var dataArray = ["Apple", "Banana", "Orange", "Pear"]
    @State public var favCals = ""
    
        var filteredArray: [String] {
            if searchText.isEmpty {
                return dataArray
            } else {
                return dataArray.filter { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
  
    

    @State private var items = [Item]()

    func getGoalz(){
        emailStr = authEmail ?? ""
        
        let docRef = db.collection("calorieGoal").document(emailStr)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                currentGoal = lastName
                currentGoalInt = Int(currentGoal) ?? 0
                getLaunchEaten()
                getStreakLaunch()
                //editStr = String(lastName)
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
              
            }
        }
        
    }
    
    
    func getStreakLaunch() {
        emailStr = authEmail ?? ""
        
        let docRef = db.collection("DefStreak").document(emailStr)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                liveStreak = Int(lastName) ?? 0
                
  
                if(liveStreak < 1) {
                    liveEmoji = ""
                } else if (liveStreak > 0 && liveStreak < 7) {
                        liveEmoji = "🔥"
                    } else if (liveStreak > 6 && liveStreak <= 13 ){
                        liveEmoji = "😎"
                    } else {
                        liveEmoji = "🥵"
                    }
              
                //editStr = String(lastName)
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
              
            }
        }
        
    }
    
    func getGoalzAfterLuanch(){
        emailStr = authEmail ?? ""
        let docRef = db.collection("calorieGoal").document(emailStr)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                currentGoal = lastName
                currentGoalInt = Int(currentGoal) ?? 0
                //the difference
                updateTally(val: currentGoal)
                //editStr = String(lastName)
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
              
            }
        }
        

    }
    
    func getLaunchEaten() {
        emailStr = authEmail ?? ""
        let docRef2 = db.collection("liveCountEaten").document(emailStr)

        docRef2.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                tempHuge = Int(lastName) ?? 0
                
                if(tempHuge == 0) {
                    liveCount = Int(currentGoal) ?? 0
                } else {
                    
                    liveCount =  Int(lastName) ?? 0
                }
                
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
              
            }
        }
    }
    
    func getCaloriesLeft(){
        emailStr = authEmail ?? ""
        let docRef = db.collection("calorieGoal").document(emailStr)
        

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                remaining = lastName
                
                
                
                
            } else {
                print("Document does not exist")
              
            }
        }

    }
    
    func editCount() {
        emailStr = authEmail ?? ""
        
        db
                  .collection("calorieGoal")
                  .document(emailStr)
                  .updateData(
                    [
                      "goal" : editStr,
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                
                  else {
                    print("succesfully updated")
                  }
                }
        getGoalzAfterLuanch()
        updateTally(val: editStr)
        
    }
    
    
    func updateTally(val : String) {
        emailStr = authEmail ?? ""
        
        //update total eaten
        remainingCals = (Int(currentGoal) ?? 0) - liveCount
        liveCount = (Int(val) ?? 0)  - remainingCals
        liveCountStr = String(liveCount)
        
        db
                  .collection("liveCountEaten")
                  .document(emailStr)
                  .updateData(
                    [
                      "theTotal" : liveCountStr
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                
                  else {
                    print("succesfully updateddd")
                    newCals = ""
                    newFood = ""
                    
                    
                  }
                }
        
    }
    
    
    func newFoodEntryFromFav(favName: String) {
       
        emailStr = authEmail ?? ""
        highestStringID = String(highestID + 1)
        
        
        
        let documentRef =   db.collection("FavFoods").document("users").collection(emailStr).document(favName)

           documentRef.getDocument { (document, error) in
               if let error = error {
                   print("Error fetching document: \(error)")
                   return
               }

               guard let document = document, document.exists else {
                   print("Document does not exist")
                   return
               }

               // Access the document data
                   let data = document.data()
                   favCals =  data?["calories"] as? String ?? ""
                   print(favCals)
               
               db.collection("DailyFoods").document("users").collection(emailStr).document(highestStringID).setData([
                       "calories": favCals,
                       "name": favName,
                       "foodID":  highestStringID,
                       "favStatus":  "star.fill"
                   ]) { err in
                       if let err = err {
                           print("Error adding document: \(err)")
                       } else {
                           print("Document added")
                       }
                   }
              
               //update total eaten
               tempFoodCals = Int(favCals) ?? 0
               liveCount = liveCount  - tempFoodCals
               liveCountStr = String(liveCount)

               db
                         .collection("liveCountEaten")
                         .document(emailStr)
                         .updateData(
                           [
                             "theTotal" : liveCountStr

                           ]
                         ) { (error) in
                         if error != nil{
                           print("Error")
                         }

                         else {
                           print("succesfully updateddd")

                         }
                       }
               updateHighestFav()
           }
        
      

      
        
    }
    
    
    func newFoodEntry() {
        emailStr = authEmail ?? ""
        
        highestStringID = String(highestID)
        
        let documentRef =  db.collection("FavFoods").document("users").collection(emailStr).document(newFood)
                
                documentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("Document RX Bar exists in the Firestore collection.")
                        
                        db.collection("DailyFoods").document("users").collection(emailStr).document(highestStringID).setData([
                                "calories": newCals,
                                "name": newFood,
                                "foodID":  highestStringID,
                                "favStatus":  "star.fill"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added")
                                }
                            }
                        
                    } else {
                        print("Document RX Bar does not exist in the Firestore collection.")
                        db.collection("DailyFoods").document("users").collection(emailStr).document(highestStringID).setData([
                                "calories": newCals,
                                "name": newFood,
                                "foodID":  highestStringID,
                                "favStatus":  "star"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added")
                                }
                            }
                    }
                }
        
        db.collection("DailyFoods").document("users").collection(emailStr).document(highestStringID).setData([
                "calories": newCals,
                "name": newFood,
                "foodID":  highestStringID,
                "favStatus":  "star"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
        
        //update total eaten
        tempFoodCals = Int(newCals) ?? 0
        liveCount = liveCount  - tempFoodCals
        liveCountStr = String(liveCount)
        
        db
                  .collection("liveCountEaten")
                  .document(emailStr)
                  .updateData(
                    [
                      "theTotal" : liveCountStr
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                
                  else {
                    print("succesfully updateddd")
                    newCals = ""
                    newFood = ""
                    
                    
                  }
                }
            
        
    }
    
    func deleteFoodEntry(theCals: String, theID: String) {
        db.collection("DailyFoods").document("users").collection(emailStr).document(theID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                
                addCalsBackToTally(val: theCals)
                
             
            }
        }
    }
    
    
    func FavSwap(theName: String, theCals: String, theID: String, favStatus: String) {
        
        emailStr = authEmail ?? ""
        
        
        //add to fav doc
        if(favStatus == "star") {
            //add to fav doc
                db.collection("FavFoods").document("users").collection(emailStr).document(theName).setData([
                    "calories": theCals,
                    "name": theName,
                    "favStatus": "star.fill"
                    
                ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                    
                }
            }
            viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
            
            //update current records
            var index = 0
            //tring(index)
            while (index <= highestID + 1) {
                        let documentRef =  db.collection("DailyFoods").document("users").collection(emailStr).document(String(index))
                        let temp = "" + String(index)
                        
                        documentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                            
                                print("Document Index exists in the Firestore collection.")
                                let data = document.data()
                                let nameOfFood = data?["name"] as? String ?? ""
                                     
                                
                                if(nameOfFood == theName) {
                                    db.collection("DailyFoods").document("users").collection(emailStr).document(temp)
                                              .updateData(
                                                [
                                                  "favStatus" : "star.fill",
                                                  
                                                ]
                                              ) { (error) in
                                              if error != nil{
                                                print("Error")
                                              }
                                              else {
                                                print("succesfully updated")
                                                
                                              }
                                            }
                                }
                                
                                
                                
//                                if(document.get("name") as! String == theName){
//
//                                    db.collection("DailyFoods").document("users").collection(emailStr).document(String(index))
//                                        .updateData(
//                                            [
//                                                "favStatus" : "star.fill"
//
//                                            ]
//                                        ) { (error) in
//                                            if error != nil{
//                                                print("Error")
//                                            }
//                                            else {
//                                                print("succesfully updated to all")
//
//                                            }
//                                        }
//                                }
                                
                                
                                
                            } else {
                                print("Document Index does not exist in the Firestore collection.")
                            }
                        }
                index = index + 1
            }
            
        } else {
            //opposite
            //add to fav doc
            db.collection("FavFoods").document("users").collection(emailStr).document(theName).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            
                         
                        }
                    }
            
            
            viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
            //update current records
            var index = 0
            //tring(index)
            while (index <= highestID + 1) {
                        let documentRef =  db.collection("DailyFoods").document("users").collection(emailStr).document(String(index))
                        let temp = "" + String(index)
                        
                        documentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                            
                                print("Document Index exists in the Firestore collection.")
                                let data = document.data()
                                let nameOfFood = data?["name"] as? String ?? ""
                                     
                                
                                if(nameOfFood == theName) {
                                    db.collection("DailyFoods").document("users").collection(emailStr).document(temp)
                                              .updateData(
                                                [
                                                  "favStatus" : "star",
                                                  
                                                ]
                                              ) { (error) in
                                              if error != nil{
                                                print("Error")
                                              }
                                              else {
                                                print("succesfully updated")
                                                
                                              }
                                            }
                                }
                                
                                
                                
//                                if(document.get("name") as! String == theName){
//
//                                    db.collection("DailyFoods").document("users").collection(emailStr).document(String(index))
//                                        .updateData(
//                                            [
//                                                "favStatus" : "star.fill"
//
//                                            ]
//                                        ) { (error) in
//                                            if error != nil{
//                                                print("Error")
//                                            }
//                                            else {
//                                                print("succesfully updated to all")
//
//                                            }
//                                        }
//                                }
                                
                                
                                
                            } else {
                                print("Document Index does not exist in the Firestore collection.")
                            }
                        }
                index = index + 1
            }
        }
    }
    
    func updateHighestFav() {
        emailStr = authEmail ?? ""
        
        highestID = highestID + 1
           
                    //update database
                    db
                              .collection("highestID")
                              .document(emailStr)
                              .updateData(
                                [
                                  "theID" : String(highestID),
                                  
                                ]
                              ) { (error) in
                              if error != nil{
                                print("Error")
                              }
                              else {
                                print("succesfully updated")
                                
                              }
                            }
    }
    
    
    func updateAnEntry() {
        //TODO
    }
    
    func addCalsBackToTally(val: String) {
        emailStr = authEmail ?? ""
        
        
        liveCount = (Int(val) ?? 0)  + liveCount
        liveCountStr = String(liveCount)
        
        db
                  .collection("liveCountEaten")
                  .document(emailStr)
                  .updateData(
                    [
                      "theTotal" : liveCountStr
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                
                  else {
                    print("succesfully updateddd")
                    newCals = ""
                    newFood = ""
                    
                    
                  }
                }
    }
    
    func updateCount(val: String) {
        liveCount = liveCount - (Int(val) ?? 0)
        
    }
    
    
    func updateHighest() {
        emailStr = authEmail ?? ""
        
        highestID = highestID + 1
           
                    //update database
                    db
                              .collection("highestID")
                              .document(emailStr)
                              .updateData(
                                [
                                  "theID" : String(highestID),
                                  
                                ]
                              ) { (error) in
                              if error != nil{
                                print("Error")
                              }
                              else {
                                print("succesfully updated")
                                
                              }
                            }
                    
            newFoodEntry()
    }
    
    func setHighestOG() {
        emailStr = authEmail ?? ""
        let docRef = db.collection("highestID").document(emailStr)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                let temp = Int(lastName) ?? 0
                highestID = temp
                }
             else {
                print("Document does not exist")
              
            }
        }
    }
    
    func deleteOGDocs() {
        emailStr = authEmail ?? ""
        
        
//        delete the first doc
        db.collection("DailyFoods").document("users").collection(emailStr).document("test").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
//
//
//
//        delete the first doc
        db.collection("FavFoods").document("users").collection(emailStr).document("test").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }

    }
    
    
    func updateStreak() {
        
        if(liveCount >= 0) {
            liveStreak = liveStreak + 1
            
            if(liveStreak) < 7 {
                liveEmoji = "🔥"
            } else if (liveStreak > 6 && liveStreak <= 13 ){
                liveEmoji = "😎"
            } else {
                liveEmoji = "🥵"
            }
            
    
            emailStr = authEmail ?? ""
            //update database
            db
                      .collection("DefStreak")
                      .document(emailStr)
                      .updateData(
                        [
                          "theStreak" : String(liveStreak),
                          
                        ]
                      ) { (error) in
                      if error != nil{
                        print("Error")
                      }
                      else {
                        print("succesfully updateddd")
                        
                      }
                    }
        } else {
            liveStreak = 0
            liveEmoji = ""
            
            
            //update database
            db
                      .collection("DefStreak")
                      .document(emailStr)
                      .updateData(
                        [
                          "theStreak" : String(liveStreak),
                          
                        ]
                      ) { (error) in
                      if error != nil{
                        print("Error")
                      }
                      else {
                        print("succesfully updated")
                        
                      }
                    }
        }
        refreshView()
    }
    
    func refreshView() {
    
        var index = 0
       
        
        while (index <= highestID + 1) {
          
                    
            db.collection("DailyFoods").document("users").collection(emailStr).document(String(index)).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            
                         
                        }
                    }

            index = index + 1
        }
        emailStr = authEmail ?? ""
        //update highest id
        db
                  .collection("highestID")
                  .document(emailStr)
                  .updateData(
                    [
                      "theID" : String(0),
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                  else {
                    print("succesfully updated")
                    
                  }
                }
        
        //update live count
        liveCount = currentGoalInt
        
        db
                  .collection("liveCountEaten")
                  .document(emailStr)
                  .updateData(
                    [
                      "theTotal" : liveCount
                      
                    ]
                  ) { (error) in
                  if error != nil{
                    print("Error")
                  }
                
                  else {
                    print("succesfully updateddd")
                    newCals = ""
                    newFood = ""
                    
                    
                  }
                }
        
    }
    
//    mutating func favDataToArray() {
//        //update current records
//        var index = 0
//        while (index <= highestID + 1) {
//                    let documentRef =  db.collection("FavFoods").document("users").collection(emailStr).document(String(index))
//                    let temp = "" + String(index)
//
//                    documentRef.getDocument { (document, error) in
//                        if let document = document, document.exists {
//
//                            print("Document Index exists in the Firestore collection.")
//                            let data = document.data()
//                            let nameOfFood = data?["name"] as? String ?? ""
//                            tempFavStr = nameOfFood
//
//                            let someString = "You can also pass a string variable, like this!"
//                            dataArray += ["yo", "hi"]
//
//                        } else {
//                            print("Document Index does not exist in the Firestore collection.")
//                        }
//                    }
//            index = index + 1
//        }
//        print(yourArray)
//    }
    

    var body: some View {
       
        ZStack {
            
            VStack() {
                Text("Calories Remaining: \(liveCount)")
                    .font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: 5, alignment: .leading)
                    .bold().padding().padding(.top)
                HStack {
                    Text("Calorie Goal: \(currentGoalInt)")
                        .font(.title3)
                        .bold()
                    
                    
                    
                    Button(action: {
                        presentAlert = true
                    }, label: {Label("", systemImage: "pencil.circle")
                            .foregroundColor(CustomColor.limeColor).bold()
                    }).alert("Edit Calorie Goal", isPresented: $presentAlert, actions: {
                        TextField("Example: 2000", text: $editStr)
                        
                        
                        
                        Button("Save", action: {editCount()})
                        Button("Cancel", role: .cancel, action: {})
                    })
                    
                } .frame(maxWidth: .infinity, maxHeight: 1, alignment: .leading).padding()
                
                
                
                
                Text("Streak: \(liveStreak) \(liveEmoji)")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading).onAppear() {
                        getStreakLaunch()
                    }
                
                
                
                NavigationLink(destination:  CalcView()) {
                    Text("Calculate calories needed for deficit").foregroundColor(.blue)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                }.frame(maxWidth: .infinity, maxHeight: 7.5, alignment: .leading)
                
                
                
                
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            TextField("Quick add from favorites", text: $searchText, onEditingChanged: { isEditing in
                                self.showCancelButton = true
                                viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
                                
                            }, onCommit: {
                                print("onCommit")
                            })
                            .foregroundColor(.primary)
                            .onChange(of: searchText) { newValue in
                                self.searchResults = filteredArray
                                viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
                            }
                            
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            
                            
                            
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .opacity(searchText.isEmpty ? 0 : 1)
                            }
                        }
                        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                        .foregroundColor(.secondary)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10.0)
                        
                        if showCancelButton {
                            Button("Cancel") {
                                self.searchText = ""
                                self.showCancelButton = false
                            }
                            .foregroundColor(Color(.systemBlue))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if searchText != "" {
                        VStack {
                                    // Display the elements in the array
                                    List(viewModel2.elementsArray, id: \.self) { element in
                                        HStack {
                                           
                                            Text(element)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "plus.circle") .foregroundColor(CustomColor.limeColor) .onTapGesture {

                                                newFoodEntryFromFav(favName: element)
                                                searchText = ""
                                            }
                                            
                                            
                                        }
                                        
                                    }

                                    
                                }
                                .padding()
                        .frame(maxHeight: 100)
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                    }
                }
                .navigationBarHidden(showCancelButton)
                
            

           
                List(viewModel.foods) { foods in
                    
                    
                    
                        
                        HStack {
                            
                            
                            Text("\(foods.name ?? ""),")
                                .font(.system(size: 16))
                                .multilineTextAlignment(.leading)

                            
                            
                            Text("Calories: \(foods.name2 ?? "")")
                                .font(.system(size: 16))
                                .onAppear()
                                .multilineTextAlignment(.leading)


                            
                            Spacer()
                            
                            Image(systemName:"\(foods.name4 ?? "")").foregroundColor(.yellow).onTapGesture {
                                FavSwap(theName: foods.name ?? "", theCals: foods.name2 ?? "", theID: foods.name3 ?? "", favStatus: foods.name4 ?? "")}

                            Image(systemName: "trash") .foregroundColor(.red) .onTapGesture {deleteFoodEntry(theCals:String(foods.name2 ?? ""), theID: String(foods.name3 ?? "")) }
                           

                        }.frame(  height: 40)
                        
                    
                        
                    
                }
                .alert("Add food to today's log", isPresented: $presentAlertAdd, actions: {
                    TextField("Name", text: $newFood)
                    //TextField("Calories", text: $newCals)
                    
                    TextField("Calories", text: Binding(
                        get: { newCals },
                        set: { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            self.newCals = filtered
                           
                        }
                    ))
                   
               
                    Button("Save", action: {updateHighest()})
                    Button("Cancel", role: .cancel, action: {})
                })
                .onAppear() {
                    emailStr = authEmail ?? ""
                    self.viewModel.getAllData(email: emailStr)
                    setHighestOG()
                    getGoalz()
                    deleteOGDocs()
                    viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
                  
                    
                   
                }
                
            
            
        }
            
            
      

            
            VStack {
                
                Spacer()
                
                
                HStack {
                    Spacer()
                    Button(action: {
                        presentAlertAdd = true
                        
                    }) {
                            Image(systemName: "plus")
                        }.frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .background(Color.blue)
                        .clipShape(Circle()).background(Color.blue)
                        .cornerRadius(38.5)
                        
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    
                    
                    Button(action: {
                        presentAlertNew = true
                       
                        }) {
                            Image(systemName: "calendar.badge.plus")
                        }.alert(isPresented: $presentAlertNew) {
                            Alert(
                                title: Text("Start New Day"),
                                message: Text("Are you sure you want to start a fresh day?"),
                                primaryButton: .destructive(Text("Confirm")) {
                                  
                                 
                                    updateStreak()
                                    presentAlertNew = false
                                },
                                secondaryButton: .cancel() {
                                    presentAlertNew = false
                                }
                            )
                        }
                        
                        
                        
//
//                        .alert("Start New Day?", isPresented: $presentAlertNew, actions: {
//                            message: Text("Are you sure you want to delete this plan?"),
//
//                            Button("Confirm", action: {updateStreak()})
//                            Button("Cancel", role: .cancel, action: {})
//                        })
                        
                        
                        .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .background(Color.blue)
                        .clipShape(Circle()).background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                }
            }
        }.onAppear() {
            
            //getLaunchEaten()
        }
    }
}



struct DietView_Previews: PreviewProvider {
    static var previews: some View {
        DietView()
    }
}




class ArrayAdditionViewModel: ObservableObject {
    // The array to store elements
    @State public var big = ""
    @State public var small = ""
    @Published var elementsArray: [String] = []
    @ObservedObject private var viewModelFavADD = FavFoodModel()
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    private var db = Firestore.firestore()
    
    func capitalizeFirstLetter(_ input: String) -> String {
        guard let firstChar = input.first else {
            return input // Return the original string if it's empty
        }
        return firstChar.uppercased() + input.dropFirst()
    }
    
    // Function to add elements to the array
    func addElement(emailVal: String, userSearch: String) {
        // = authEmail ?? ""
       elementsArray.removeAll()
        
        db.collection("FavFoods").document("users").collection(emailVal).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found.")
                    return
                }
                
                for document in documents {
                    let documentData = document.data()
                    // Handle the document data here as needed
                    print("Document ID: \(document.documentID)")
                    print("Document Data: \(documentData)")
                    
                
                    var newElement = "" + document.documentID
                    newElement = newElement.lowercased()
                    var typed = userSearch.lowercased()
                  
                    
                    if ((newElement.contains(typed)) || (userSearch == "")) {
                      
                        self.elementsArray.append(document.documentID)
                    }
                }
            }
        }
    }
    
}
