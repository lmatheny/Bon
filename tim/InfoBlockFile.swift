//
//  PlanInfoView.swift
//  tim
//
//  Created by Luke Matheny on 12/22/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseAuth

struct BlockInfoFile: View {
    let unique: String
    let verified: String
    @State private var name: String = ""
    @State private var showE1 = false
    @State private var showE2 = false
    @State private var showE3 = false
    
    
    @State private var showConfirmationAlert = false
    @State private var navigateToLiftView = false
    @State private var showSuccessMessage = false
 
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    
    @State private var isChecked = true
    @State public var favName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    @State private var planCreator: String = ""
    
    @State private var isSheetPresented2 = false
    
    func canEdit() {
        // Assuming you have a Firestore collection named "yourCollection" and a document with a specific documentID
        let db = Firestore.firestore()
        let docRef = db.collection("AllPlans").document(unique)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let creator = document["creator"] as? String {
                    self.planCreator = creator
                }

            } else {
                print("Document does not exist")
            }
        }
    }
    
    func addPlanToCollection() {
            let db = Firestore.firestore()
            
            // Reference to the subcollection
            let subcollectionRef = db.collection("SelectedPlans").document("users").collection(authEmail)
            
            // Query to retrieve documents where 'fav' is equal to 'yes'
            let query = subcollectionRef.whereField("fav", isEqualTo: "yes")
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    // No document with 'fav' equal to 'yes' found
                    print("No document with 'fav' equal to 'yes' found in subcollection for \(authEmail)")
                    return
                }
                
                // Print the document ID
                print("Document ID with 'fav' equal to 'yes' in subcollection for \(authEmail): \(document.documentID)")
                favName = document.documentID
                
                db.collection("SelectedPlans").document("users").collection(authEmail).document(favName)
                    .updateData(
                        [
                            "fav" : "no",
                            
                        ]
                    ) { (error) in
                        if error != nil{
                            print("Error")
                        }
                        else {
                            print("succesfully removed " + favName)
                            
                        }
                    }
            }
            
            
            // Reference to the document you want to query for values
            let sourceDocRef = db.collection("AllPlans").document(unique)
            
            // Assuming you want to get the 'value1' and 'value2' fields from the source document
            sourceDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Extract the values from the source document
                    let value1 = document.get("creator") as? String ?? ""
                    let value2 = document.get("description") as? Int ?? 0
                    let value3 = document.get("name") as? String ?? ""
                    let value4 = document.get("verified") as? Int ?? 0
                    
                    // Create data for the new document
                    let data: [String: Any] = [
                        "creator": value1,
                        "unique": unique,
                        "description": value2,
                        "display": value3,
                        "verified": value4,
                        "fav": "yes"]
                    
                    // Reference to the destination document
                    let destDocRef = db.collection("SelectedPlans").document("users").collection(authEmail).document(unique)
                    
                    // Set data to the destination document
                    destDocRef.setData(data) { error in
                        if let error = error {
                            print("Error adding document: \(error.localizedDescription)")
                        } else {
                            print("Document added successfully!")
                            showSuccessMessage = true
                        }
                    }
                            

                    
                } else {
                    print("Source document does not exist")
                }
            }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        //        Text("Plan Info for \(unique)")
        //            .padding()\
            VStack {
                ScrollView {
                    RemoteImage4("gs://tfinal-a07fc.appspot.com/planPics/\(unique).jpg")
                    
            
                    
                    HStack {
                        Spacer()
                        
                        Text(name).font(.system(size: 22.5, weight: .bold))
                        
                        if verified.lowercased() == "yes" {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(CustomColor.limeColor)
                            
                        }
                        Spacer()
                    }
                    Text("@" + unique).font(.system(size: 17.5, design: .rounded))
                    
                    
                    
                    
                    DisclosureGroup("Workout Split", isExpanded: $showE1) {
                        EView4(documentID: unique)
                    }
                    .padding()
                    .foregroundColor(.black)
                    .font(.system(size: 20, design: .rounded))
                    .background(RoundedRectangle(cornerRadius: 5).fill(.white))
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    DisclosureGroup("Dietary Strategy", isExpanded: $showE2) {
                        EView5(documentID: unique)
                    }
                    .padding()
                    .foregroundColor(.black)
                    .font(.system(size: 20, design: .rounded))
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    DisclosureGroup("Additional Information", isExpanded: $showE3) {
                        EView6(documentID: unique)
                    }
                    .padding()
                    .foregroundColor(.black)
                    .font(.system(size: 20, design: .rounded))
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    
                    
                    
                    Button(action: {
                        //findUserBMR()
                        showConfirmationAlert = true
                    }) {
                        
                        
                        Text("Set To Current Plan")
                            .fontWeight(.semibold)
                            .font(.system(size: 17.5)).padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(CustomColor.limeColor)
                            .cornerRadius(25)
                            .padding(.leading)
                            .padding(.trailing)
                    }  .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Add Workout Plan"),
                            message: Text("Are you sure you want to add this plan?"),
                            primaryButton: .cancel(Text("Cancel")),
                            secondaryButton: .default(Text("Confirm")) {
                                addPlanToCollection()
                                
                                
                            }
                        )
                    }
                    
                    if(planCreator == authEmail) {
                          HStack {
                              Spacer()
                              Text("Edit Plan").foregroundColor(.blue).font(.system(size: 17.5))
                              Image(systemName: "pencil.circle")
                                  .foregroundColor(.blue)
                              Spacer()
                              
                          }.onTapGesture {
                              isSheetPresented2.toggle()
                          }
                          .sheet(isPresented: $isSheetPresented2) {
                              NavigationView {
                                  ScrollView {
                                      VStack {
                                         
                                          //Text(unique)
                                          Spacer()
                                          Text("Coming Soon").bold()
                                          Spacer()
                                      }.navigationBarItems(trailing: Button("Close") {
                                          isSheetPresented2.toggle()
                                      })
                                  }
                              }
                          }.padding(.top)
                    }
                    
                    
                    Spacer()
                    
                }.padding(.leading, 2).padding(.trailing,2)
                    .background(CustomColor.lgColor)
                    .overlay(
                        SuccessMessageView(message: "Workout plan added successfully!", isVisible: $showSuccessMessage)
                    )
            }
            .onAppear {
                fetchNameFromFirestore()
                canEdit()
            }
        }
 func fetchNameFromFirestore() {
        let db = Firestore.firestore()
        let collectionReference = db.collection("AllPlans")
        let documentReference = collectionReference.document(unique)

        documentReference.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                if let document = document, document.exists {
                    if let name = document.get("name") as? String {
                        self.name = name
                    } else {
                        print("Document doesn't contain a 'name' field or it's not a String.")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct BlockInfoFile_Previews: PreviewProvider {
    static var previews: some View {
        PlanInfoView(unique: "TestUnique", verified: "no")
    }
}


struct RemoteImage4: View {
    @State private var image: Image?
    let storagePath: String
    let labelText = "Bon's Fatburn" // Hardcoded label

    init(_ storagePath: String) {
        self.storagePath = storagePath
    }

    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .frame(width: 165, height: 165) // Adjust the size as needed
                    .clipShape(Circle())
             
            } else {
                ProgressView().frame(height: 100) // Adjust the size as needed
                    .onAppear {
                        downloadImage()
                    }
            }
        }
    }

    private func downloadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)

        storageRef.getData(maxSize: 1 * 10024 * 10024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                self.image = Image("def")
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}


struct EView4: View {
    
    let documentID: String
    @State var dayType: String = ""
    

    @State public var currentDay: Int = 0 // Default to Monday (0-based index)
    @StateObject var exerciseViewModel = ExerciseViewModel()
    let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    let auth = Auth.auth()
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    public var db = Firestore.firestore()
    

    public func updateCurrentDay() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: Date())
        currentDay = (components.weekday! + 5) % 7 // Adjust for 0-based index and start from Monday
    }
    
    public func getDayType(for dayIndex: Int) {
       // print(selectedSplit)
        let adjustedDayIndex = (dayIndex + 7) % 7 // Adjusted index calculation
        let selectedDay = dayNames[adjustedDayIndex]

        let documentRef = db.collection("AllPlans")
            .document(documentID)
            .collection("Split")
            .document(selectedDay)

        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }

            guard let document = document, document.exists else {
                print("Document does not exisst")
             
                return
            }

            let data = document.data()
            dayType = data?["type"] as? String ?? ""
            
        }
    }
    
    var body: some View {
      
            ScrollView {
                VStack {
                CoolHStackView3(currentDay: $currentDay, dayNames: dayNames, viewModel: exerciseViewModel, authEmail: authEmail) {
                    self.getDayType(for: currentDay)
                }.padding()
                
                NavigationView {
                    if exerciseViewModel.exercises.isEmpty {
                        Text("No exercises added for this day.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            VStack(alignment: .leading) {
                                if (dayType != "") {
                                    Text("Workout Type: \(dayType)")
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.bottom, 6)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                ForEach(Array(exerciseViewModel.exercises.enumerated()), id: \.element.id) { index, exercise in
                                    HStack {
                                        Text("\(index + 1). \(exercise.name ?? "")")
                                            .multilineTextAlignment(.leading)
                                            .font(.system(size: 17.5))
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .onAppear {
                            exerciseViewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: documentID)
                        }
                    }
                }.frame(maxHeight: 275)
            }.onAppear {
                getDayType(for: currentDay)
                exerciseViewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: documentID)
                
            }.onChange(of: currentDay) { _ in
                // Add a delay here as well
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    getDayType(for: currentDay)
                    exerciseViewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: documentID)

                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        //checkForNewWeek()
                    }
                }
            }
        }
    }
    
}

struct EView5: View {
    let documentID: String
    
    @State private var selectedType: String = ""
    @State private var theCals: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
              
                VStack {
            
                    HStack {
                        Text("Diet Type")
                            .font(.system(size: 17.5))
                            .foregroundColor(.black)
                            .bold() // Making the label bold
                     Spacer()
                    }.padding(.bottom,2.5)
                        
                    HStack {
                        if(selectedType != "") {
                            Text("\(selectedType)")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Spacer()
                        } else {
                            Text("-")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                    }
                        
                       
                  
                }.padding(.bottom, 5)
                .padding(.top, 5)
                
                VStack {
                    HStack {
                        Text("Calorie difference from BMR")
                            .font(.system(size: 17.5))
                            .foregroundColor(.black)
                            .bold() // Making the label bold
                        
                        NavigationLink(destination: InfoCalDiff()) {
                            Image(systemName: "questionmark.circle") .foregroundColor(.gray)
                        }
                        Spacer() // Add a spacer to push the text to the leading edge
                    }.padding(.bottom,2.5)
                    
                    HStack {
                        if(theCals != "") {
                            Text("\(theCals) calories")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            
                            Spacer()
                        } else {
                            Text("-")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                }
                }
            }
            Spacer()
        }
  
        .onAppear {
            fetchDataFromFirestore()
        }
    }
    private func fetchDataFromFirestore() {
        // Assuming you have a Firestore collection named "yourCollection" and a document with a specific documentID
        let db = Firestore.firestore()
        let docRef = db.collection("AllPlans").document(documentID).collection("Diet").document("details")

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let selectedCategory = document["dietaryStrategy"] as? String {
                    self.selectedType = selectedCategory
                }

                if let planDescription = document["calories"] as? String {
                    self.theCals = planDescription
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

struct EView6: View {
    @State private var selectedCategory: String = ""
    @State private var planDescription: String = ""
    
    let documentID: String

    var body: some View {
        VStack {
            ScrollView {
              
                VStack {
            
                    HStack {
                        Text("Selected Category")
                            .font(.system(size: 17.5))
                            .foregroundColor(.black)
                            .bold() // Making the label bold
                     Spacer()
                    }.padding(.bottom,2.5)
                        
                    HStack {
                        if(selectedCategory != "") {
                            Text("\(selectedCategory)")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Spacer()
                        } else {
                            Text("-")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                        
                       
                  
                }.padding(.bottom, 5)
                .padding(.top, 5)
                
                VStack {
                    HStack {
                        Text("Plan Description")
                            .font(.system(size: 17.5))
                            .foregroundColor(.black)
                            .bold() // Making the label bold
                     Spacer()
                    }.padding(.bottom,2.5)
                    
                    HStack {
                        if(planDescription != "") {
                            Text("\(planDescription)")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        } else {
                            Text("-")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            fetchDataFromFirestore()
        }
    }

    private func fetchDataFromFirestore() {
        // Assuming you have a Firestore collection named "yourCollection" and a document with a specific documentID
        let db = Firestore.firestore()
        let docRef = db.collection("AllPlans").document(documentID).collection("Overview").document("details")

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let selectedCategory = document["selectedCategory"] as? String {
                    self.selectedCategory = selectedCategory
                }

                if let planDescription = document["planDescription"] as? String {
                    self.planDescription = planDescription
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}