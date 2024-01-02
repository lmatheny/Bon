import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct LiftView: View {
    
    
    
    
    let auth = Auth.auth()
    let storage = Storage.storage()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    private var db = Firestore.firestore()
    @ObservedObject private var viewModel = ExerciseViewModel()
    @ObservedObject private var currentPlansViewModel = CurrentPlansViewModel()
    @State public var emailStr = ""
    @State public var typeFromBD = ""
    @State public var updatedExercise = ""


    @State private var isDeleteAlertPresented = false
    @State private var currentDay: Int = 0 // Default to Monday (0-based index)

    let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    func updateCurrentDay() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: Date())
        currentDay = (components.weekday! + 5) % 7 // Adjust for 0-based index and start from Monday
    }
    

    
    func setInitialSelectedPlan() {
        if currentPlansViewModel.currentPlans.count > 1 {
            //selectedPlan = currentPlansViewModel.currentPlans[1].display
            
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
                    
                    // Print the value of the "display" field
                    if let displayValue = document.get("display") as? String {
                        print("Display value: \(displayValue)")
                        selectedPlan = displayValue
                    } else {
                        print("Display field not found or not a string.")
                    }
                }
            
        } else {
            selectedPlan = "No Plans Added"
        }
    }


    func fetchUserDocumentIDs() {
        currentPlansViewModel.fetchUserDocumentData()
        // The rest of your code remains unchanged
    }
    
    
    func checkForNewWeek() {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday, .hour, .minute], from: Date())

            // Check if it's Monday and the time is 12:00 AM
            if components.weekday == 2 && components.hour == 0 && components.minute == 0 {
                // Run your method here
                startNewWeek()
            }
        }

        func startNewWeek() {
            // Your code to be executed at the start of a new week
            print("It's the start of a new week!")
        }
    
    
    

    func deleteDocument(theName: String) {
        let authEmail = Auth.auth().currentUser?.email ?? ""
        
        db.collection("SelectedPlans").document("users").collection(authEmail).document(theName).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted!")
                // Optionally, you can refresh your data or perform other actions after deletion

                currentPlansViewModel.fetchUserDocumentData()
            }
        }
    }

    @State public var selectedPlan: String = "" // Set default to "Plan 1"
    @State public var favName: String = ""
    @State public var selectedSplit: String = "temp" // Set default to "Plan 1"
    let planOptions = ["Create New Plan"] + []
    @State private var documentIDs: [String] = []
    @State private var isExpanded = false
    @State private var isCreatingNewPlan = false
    
    
    @State public var favSplit: String = "" // Set default to "Plan 1"

    func getDayType(for dayIndex: Int) {
        print(selectedSplit)
        let adjustedDayIndex = (dayIndex + 7) % 7 // Adjusted index calculation
        let selectedDay = dayNames[adjustedDayIndex]

        let documentRef = db.collection("AllPlans")
            .document(selectedSplit)
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
            let test = data?["type"] as? String ?? ""
            print(test)
            typeFromBD = data?["type"] as? String ?? ""
            
        }
    }

    @State private var selectedExercise: Exercise? = nil
    
    func printDocumentIDForFavorite() {
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
            selectedSplit = document.documentID
        }
    }

    
    
    
    struct CoolHStackView: View {
        @Binding var currentDay: Int
        let dayNames: [String]
        @ObservedObject var viewModel: ExerciseViewModel
        let authEmail: String
        let onTapGesture: () -> Void

        var body: some View {
            HStack(spacing: 5) {
                ForEach(0..<7) { index in
                    ZStack {
                        Circle()
                            .frame(width: 32.5, height: 32.5)
                            .foregroundColor(index == currentDay ? CustomColor.limeColor : Color.white)
                            .overlay(Circle().stroke(CustomColor.limeColor, lineWidth: 2))
                            .onTapGesture {
                                currentDay = index
                                onTapGesture() // Call the onTapGesture closure
                                
                                
                                //viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedPlan: "YourSelectedPlanName")
                            }

                        Text(String(dayNames[index].prefix(1)))
                            .font(.system(size: 15, weight: index == currentDay ? .bold : .regular))
                            .foregroundColor(index == currentDay ? .white : CustomColor.limeColor)
                    }

                    if index < 6 {
                        Line()
                    }
                }
            }
            .alignmentGuide(.leading) { d in d[.leading] }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                CoolHStackView(currentDay: $currentDay, dayNames: dayNames, viewModel: viewModel, authEmail: authEmail) {
                    self.getDayType(for: currentDay)
                }
                .padding(.top)
                .padding(.bottom)

                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: {
                        VStack(alignment: .leading) {
                            ForEach(currentPlansViewModel.currentPlans, id: \.unique) { plan in
                                Button(action: {
                                    if plan.display == "Create New Plan" {
                                       // isCreatingNewPlan = true
                                        
                                        
                                    } else {
                                        selectedSplit = plan.unique
                                        selectedPlan = plan.display
                                        getDayType(for: currentDay)
                                        print("here")
                                        isExpanded.toggle()
                                    }
                                }) {
                                    HStack() {
                                        if plan.display != "Create New Plan" {
                                         
                                                  NavigationLink(
                                                    destination: PlanInfoView(unique: plan.unique)
                                                   
                                                ) {
                                                    Image(systemName: "info.circle")
                                                        .foregroundColor(.black)
                                                }
                                            
                                        }

                                        if plan.display == "Create New Plan" {
                                            NavigationLink(destination: CreatePlanView()) {
                                                Text("Create New Plan").font(.system(size: 20, weight: .bold, design: .rounded))
                                                    .foregroundColor(CustomColor.limeColor)
                                            }
                                        } else {
                                            Text(plan.display)
                                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                                                    .foregroundColor(plan.display == "Create New Plan" ? CustomColor.limeColor : (selectedPlan == plan.display ? .cyan : .black))
                                                                    .multilineTextAlignment(plan.display == "Create New Plan" ? .center : .leading)

                                        }
                                        
                                        
                                        if plan.display == "Create New Plan" {
                                                                   NavigationLink(
                                                                       destination: CreatePlanView()
                                                                      
                                                                   ) {
                                                                       Image(systemName: "plus.circle")
                                                                           .foregroundColor(CustomColor.limeColor)
                                                                           .bold()
                                                                   }
                                                             
                                                               }
                                        
                                        
                                    

                                        Spacer()
                                        
                                        if plan.fav == "yes" {
                                            Image(systemName: "heart.circle.fill")
                                                .foregroundColor(CustomColor.limeColor)
                                        }


                                        if plan.display != "Create New Plan" {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red).onTapGesture {
//                                                    if let plan = currentPlansViewModel.currentPlans.first(where: { $0.display == selectedPlan }) {
//                                                        deleteDocument(theName: plan.unique)
                                                    isDeleteAlertPresented = true
//                                                    }
                                                }.alert(isPresented: $isDeleteAlertPresented) {
                                                    Alert(
                                                        title: Text("Confirm Deletion"),
                                                        message: Text("Are you sure you want to delete this plan?"),
                                                        primaryButton: .destructive(Text("Delete")) {
                                                          
                                                            if let plan = currentPlansViewModel.currentPlans.first(where: { $0.display == selectedPlan }) {
                                                                deleteDocument(theName: plan.unique)
                                                            }
                                                            
                                                            isDeleteAlertPresented = false
                                                        },
                                                        secondaryButton: .cancel() {
                                                            isDeleteAlertPresented = false
                                                        }
                                                    )
                                                }
                                        }

                                      
                                    }

                                }
                           
                            }
                            .padding(.top)
                        }
                  
                    },
                    label: {
                        HStack {
                            Text("\(selectedPlan)")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .multilineTextAlignment(selectedPlan == "Create New Plan" ? .center : .leading)
                            
                            if !selectedPlan.isEmpty {
                                if selectedSplit == favName {
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundColor(CustomColor.limeColor)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                )
                .padding(.leading)
                .padding(.trailing)



                List {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today: \(typeFromBD)")
                            .font(.system(size: 23, weight: .bold))
                            .padding(.bottom)
                            .multilineTextAlignment(.leading)


                        ForEach(viewModel.exercises, id: \.name) { exercise in
                            HStack {
                                Image(systemName: exercise.name5 == "no" ? "square" : "checkmark.square.fill")
                                    .foregroundColor(exercise.name5 == "no" ? Color.primary : CustomColor.limeColor)
                                    .onTapGesture {
                                        // Handle swapping the box here
                                        viewModel.swapBox(theID: String(exercise.name6), theCurrent: exercise.name5 ?? "", day: dayNames[currentDay], selectedSplit: selectedSplit)
                                    }

                                Text(exercise.name ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)


                                Spacer()

                                Button(action: {
                                    // Set the selectedExercise property to launch LiftInfoView
                                    selectedExercise = exercise
                                }) {
                                    Image(systemName: "list.clipboard.fill")
                                        .foregroundColor(.cyan)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .sheet(item: $selectedExercise) { exercise in
                NavigationView {
                    LiftInfoView(
                        exerciseName: exercise.name ?? "",
                        reps: exercise.name2 ?? "",
                        sets: exercise.name4 ?? "",
                        weight: exercise.name7 ?? "",
                        notes: exercise.name8 ?? "",
                        recReps: exercise.name9 ?? "",
                        recSets: exercise.name10 ?? "",
                        plan:  exercise.plan ?? "",
                        theID: exercise.name6
                       
                        
                    )
                    .navigationBarItems(trailing: Button("Close") {
                        selectedExercise = nil
                    })
                }
            }
            .onAppear {
                updateCurrentDay()
                printDocumentIDForFavorite()
                currentPlansViewModel.fetchUserDocumentData()  // Make sure this is called

                // Wait for a short duration to allow the data to be fetched
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    setInitialSelectedPlan()
                    getDayType(for: currentDay)
                    viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)


                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }
            .onChange(of: currentDay) { _ in
                // Add a delay here as well
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    //setInitialSelectedPlan()
                    getDayType(for: currentDay)
                    viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)

                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }
            .onChange(of: selectedPlan) { _ in
                // Add a delay here as well
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    //setInitialSelectedPlan()
                    getDayType(for: currentDay)
                    viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)

                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }
                  
        }
    }
}



struct Line: View {
    var body: some View {
        Rectangle()
            .fill(CustomColor.limeColor)
            .frame(width: 10, height: 2)
    }
}

struct LiftView_Previews: PreviewProvider {
    static var previews: some View {
        LiftView()
    }
}

