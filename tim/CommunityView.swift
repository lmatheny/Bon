import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ImageLoader: ObservableObject {
    @Published var image: Image?
    
    func downloadImage(storagePath: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                self.image = Image("defBanner")
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

//
//struct PlanBanner: View {
//    @State private var image: Image?
//    @Binding var bannerStoragePath: String
//
//    var body: some View {
//        VStack {
//            if let image = image {
//                image
//                    .resizable()
//                    .frame(height: 72.5) // Adjust the size as needed
//            } else {
//                ProgressView()
//                    .frame(height: 72.5) // Adjust the size as needed
//                    .onAppear {
//                        downloadImage()
//                    }
//            }
//        }
//    }
//
//    private func downloadImage() {
//        let storage = Storage.storage()
//        let storageRef = storage.reference(forURL: bannerStoragePath)
//
//        storageRef.getData(maxSize: 1 * 10024 * 10024) { data, error in
//            if let error = error {
//                print("Error downloading image: \(error.localizedDescription)")
//                self.image = Image("defBanner")
//            } else if let data = data, let uiImage = UIImage(data: data) {
//                self.image = Image(uiImage: uiImage)
//            }
//        }
//    }
//}
//




struct CommunityView: View {
    @StateObject private var imageLoader = ImageLoader()
    @State private var bannerStoragePath = "lucaPlan1"

    
    let auth = Auth.auth()
    let storage = Storage.storage()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    private var db = Firestore.firestore()
    @ObservedObject private var viewModel = ExerciseViewModel()
    @ObservedObject var currentPlansViewModel = CurrentPlansViewModel2()
    @State public var emailStr = ""
    @State public var v1 = ""
    @State public var v2 = ""
    @State public var tempU = ""
    @State public var tempU2 = ""
    @State public var typeFromBD = ""
    @State public var updatedExercise = ""
    @State private var planCreator: String = ""



    @State private var isDeleteAlertPresented = false
    @State private var currentDay: Int = 0 // Default to Monday (0-based index)

    let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    func updateCurrentDay() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: Date())
        currentDay = (components.weekday! + 5) % 7 // Adjust for 0-based index and start from Monday
    }
    
    func canEdit() {
        // Assuming you have a Firestore collection named "yourCollection" and a document with a specific documentID
        let db = Firestore.firestore()
        let docRef = db.collection("AllPlans").document(selectedSplit)

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
    
    func updateBanner() {
        bannerName = selectedSplit
    }
    
    private func downloadImage() {
           let storage = Storage.storage()
           let storageRef = storage.reference(forURL: "gs://tfinal-a07fc.appspot.com/banners/\(bannerStoragePath).jpg")

           storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
               if let error = error {
                   print("Error downloading image: \(error.localizedDescription)")
               } else if let data = data, let _ = UIImage(data: data) {
                   // You may update any necessary state or UI here
               }
           }
       }
    
    func setInitialSelectedPlan() {
        
        if currentPlansViewModel.currentPlans.count >= 1 {
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
                        v1 = self.currentPlansViewModel.currentPlans.last?.display ?? ""
                        v2 = self.currentPlansViewModel.currentPlans.last?.unique ?? ""
                       selectedPlan = v1
                       selectedSplit = v2
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

                while currentPlansViewModel.currentPlans.count > 0 {
                    currentPlansViewModel.currentPlans.removeFirst()
                }

                currentPlansViewModel.fetchUserDocumentData()
            }
        }
    }

    @State public var selectedPlan: String = "" // Set default to "Plan 1"
    @State public var favName: String = ""
    @State public var selectedSplit: String = "" // Set default to "Plan 1"
    @State public var bannerName: String = "" // Set default to "Plan 1"
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

    
    
    //old
    @State private var selectedTab = 0
    
    

    var body: some View {
        NavigationView {
            VStack {
                
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
                                        isExpanded.toggle()
                                    }
                                }) {
                                    HStack() {
                                        if plan.display != "Create New Plan" {
                                            
                                            NavigationLink(
                                                destination: BlockInfoFile(unique: plan.unique, verified: "no")
                                                
                                            ) {
                                                Image(systemName: "info.square")
                                                    .foregroundColor(.black)
                                            }
                                            
                                        }
                                        
                                        if plan.display == "Create New Plan" {
                                            //                                        NavigationLink(destination: CreatePlanView()) {
                                            //                                            Text("Create New Plan").font(.system(size: 20, weight: .bold, design: .rounded))
                                            //                                                .foregroundColor(CustomColor.limeColor)
                                            //                                        }
                                        } else {
                                            Text(plan.display)
                                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                                .foregroundColor(plan.display == "Create New Plan" ? CustomColor.limeColor : (selectedPlan == plan.display ? .cyan : .black))
                                                .multilineTextAlignment(plan.display == "Create New Plan" ? .center : .leading)
                                            
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
                                                    //deleteDocument(theName: plan.unique)
                                                    tempU = plan.unique
                                                    tempU2 = plan.display
                                                    isDeleteAlertPresented = true
                                                    //                                                    }
                                                }.alert(isPresented: $isDeleteAlertPresented) {
                                                    Alert(
                                                        title: Text("Confirm Deletion"),
                                                        message: Text("Are you sure you want to remove this plan?"),
                                                        primaryButton: .destructive(Text("Delete")) {
                                                            
                                                            
                                                            
                                                            if(selectedPlan == tempU2) {
                                                                print("inside")
                                                                
                                                                if(self.currentPlansViewModel.currentPlans.count == 1) {
                                                                    v1 = self.currentPlansViewModel.currentPlans.last?.display ?? ""
                                                                    v2 = self.currentPlansViewModel.currentPlans.last?.unique ?? ""
                                                                    
                                                                    
                                                                    selectedPlan = v1
                                                                    selectedSplit = v2
                                                                } else {
                                                                    print("here my boi")
                                                                    selectedPlan = "No Plans Added"
                                                                }
                                                            }
                                                            
                                                            print("outside")
                                                            //print("here now:" + plan.unique)
                                                            deleteDocument(theName: tempU)
                                                            
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
                
                if(planCreator == authEmail) {
                    
                    VStack {
                               // Your other UI elements here
                               
                               imageLoader.image?
                                   .resizable()
                                   .frame(height: 75) // Adjust the size as needed
                               
                           }
                           .onAppear {
                               // Initial image download
                               imageLoader.downloadImage(storagePath: "gs://tfinal-a07fc.appspot.com/banners/\(selectedSplit).jpg")
                           }
                    
                    VStack {
                        
                        Divider() // Add a separator at the top
                        
                        HStack() {
                            
                            
                            Text("Creator")
                                .font(selectedTab == 0 ? .title3.bold() : .subheadline)
                                .foregroundColor(selectedTab == 0 ? CustomColor.limeColor : .black)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 0
                                    }
                                }
                                .padding(.leading)
                            
                            Spacer()
                            
                            Text("Community")
                                .font(selectedTab == 1 ? .title3.bold() : .subheadline)
                                .foregroundColor(selectedTab == 1 ? CustomColor.limeColor : .black)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                }
                                .padding(.trailing)
                            
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity) // Center the HStack horizontally
                        
                        Divider() // Add a separator at the bottom
                        
                        VStack {
                            
                            if selectedTab == 0 {
                                
                                VStack {
                                    
                                    HStack {
                                        NavigationLink(
                                            destination: CreatorSettingsView(unique: selectedSplit)
                                            
                                        ) {
                                            Image(systemName: "gear")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5)).padding(.trailing)
                                        }
                                        
                                        NavigationLink(
                                            destination: CreatorNotifView(unique: selectedSplit)
                                            
                                        ) {
                                            
                                            Image(systemName: "bell.fill")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5))
                                        }
                                        
                                        NavigationLink(
                                            destination: CreatorPostView(unique: selectedSplit)
                                            
                                        ) {
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5))
                                        }
                                    }.padding(.leading).padding(.trailing)
                                }
                                
                                ScrollView {
                                    Text("content")
                                }
                            } else {
                                
                                VStack {
                                    
                                    HStack {
                                        
                                        
                                        
                                        Image(systemName: "slider.horizontal.3")
                                            .foregroundColor(.black)
                                            .font(.system(size: 22.5)).padding(.top, 2)
                                        
                                        
                                        
                                        
                                        Spacer()
                                        
                                    }.padding(.leading).padding(.trailing)
                                    
                                    
                                    ScrollView {
                                        Text("content")
                                    }
                                }
                            }
                        }
                        
                        Spacer() // Push the tabs to the top
                    }
                } else {
//                    planBanner("gs://tfinal-a07fc.appspot.com/banners/\(bannerName).jpg").onAppear {
//                        print("yo")
//                    }
//
                    
                    
                    VStack {
                        
                        Divider() // Add a separator at the top
                        
                        HStack() {
                            
                            
                            Text("Creator")
                                .font(selectedTab == 0 ? .title3.bold() : .subheadline)
                                .foregroundColor(selectedTab == 0 ? CustomColor.limeColor : .black)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 0
                                    }
                                }
                                .padding(.leading)
                            
                            Spacer()
                            
                            Text("Community")
                                .font(selectedTab == 1 ? .title3.bold() : .subheadline)
                                .foregroundColor(selectedTab == 1 ? CustomColor.limeColor : .black)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                }
                                .padding(.trailing)
                            
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity) // Center the HStack horizontally
                        
                        Divider() // Add a separator at the bottom
                        
                        VStack {
                            
                            if selectedTab == 0 {
                                
                                VStack {
                                    
                                    HStack {
                                        NavigationLink(
                                            destination: CreatorSettingsView(unique: selectedSplit)
                                            
                                        ) {
                                            Image(systemName: "gear")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5)).padding(.trailing)
                                        }
                                        
                                        NavigationLink(
                                            destination: CreatorNotifView(unique: selectedSplit)
                                            
                                        ) {
                                            
                                            Image(systemName: "bell.fill")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5))
                                        }
                                        
                                        NavigationLink(
                                            destination: CreatorPostView(unique: selectedSplit)
                                            
                                        ) {
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 22.5))
                                        }
                                    }.padding(.leading).padding(.trailing)
                                }
                                
                                ScrollView {
                                    Text("content")
                                }
                            } else {
                                
                                VStack {
                                    
                                    HStack {
                                        
                                        
                                        
                                        Image(systemName: "slider.horizontal.3")
                                            .foregroundColor(.black)
                                            .font(.system(size: 22.5)).padding(.top, 2)
                                        
                                        
                                        
                                        
                                        Spacer()
                                        
                                    }.padding(.leading).padding(.trailing)
                                    
                                    
                                    ScrollView {
                                        Text("content")
                                    }
                                }
                            }
                        }
                        
                        Spacer() // Push the tabs to the top
                    }
                }
            }.onAppear {
                
                while currentPlansViewModel.currentPlans.count > 0 {
                    currentPlansViewModel.currentPlans.removeFirst()
                }
                
                currentPlansViewModel.fetchUserDocumentData()  // Make sure this is called
                
                
                
                
                //updateCurrentDay()
                printDocumentIDForFavorite()
                
                
                // Wait for a short duration to allow the data to be fetched
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    getDayType(for: currentDay)
                    //viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)
                    setInitialSelectedPlan()
                    updateBanner()
                    
                    
                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }.onChange(of: selectedPlan) { _ in
                // Add a delay here as well
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    //setInitialSelectedPlan()
                    //getDayType(for: currentDay)
                    updateBanner()
                    //viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)
                    
                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }.onChange(of: selectedSplit) { _ in
                // Add a delay here as well
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    //setInitialSelectedPlan()
                    //getDayType(for: currentDay)
                    canEdit()
                    updateBanner()
                    imageLoader.downloadImage(storagePath: "gs://tfinal-a07fc.appspot.com/banners/\(selectedSplit).jpg")
                    //viewModel.getAllData(email: authEmail, day: dayNames[currentDay], selectedSplit: selectedSplit)
                    
                    // Schedule a timer to check for the start of a new week every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                        checkForNewWeek()
                    }
                }
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}


struct SpinnerView: View {
  var body: some View {
    ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: CustomColor.limeColor))
      .scaleEffect(3.0, anchor: .center) // Makes the spinner larger
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          // Simulates a delay in content loading
          // Perform transition to the next view here
        }
      }
  }
}

