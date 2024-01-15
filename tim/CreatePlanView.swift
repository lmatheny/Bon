import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage


struct CreatePlanView: View {
    
 

    var body: some View {
        VStack {
            // Step content
            // Step content
            StepContentView()
            Spacer()
            // Show the success message view
          
            
        }
        
    }
   
    
    struct StepContentView: View {
        @State private var isConfirmationAlertPresented = false
        @State private var showSuccessMessage = false
        @State private var picChosen = false
        @Environment(\.presentationMode) var presentationMode
        let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
       
        
        @State private var currentStep = 1
        @State private var enteredTextName = ""
        @State private var enteredTextAt = ""
        @State private var enteredTextDesc = ""
        @State private var enteredTextMonday = ""
        @State private var privacySelection = "Private"
        let Categories = [
            ("Cutting", "🍎"),
            ("Bulking", "🍗"),
            ("Power Lifting", "🏋️‍♂️"),
            ("Calisthenics", "🤸"),
            ("Hybrid", "🦾"),
            ("Endurance", "🏃"),
            ("Yoga", "🧘"),
            ("Flexibility", "🤸"),
            ("Swimming", "🏊‍♂️"),
            ("None", "❌")
        ]
        @State private var mondayWorkouts: [String] = []
        @State private var tuesdayWorkouts: [String] = []
        @State private var wednesdayWorkouts: [String] = []
        @State private var thursdayWorkouts: [String] = []
        @State private var fridayWorkouts: [String] = []
        @State private var saturdayWorkouts: [String] = []
        @State private var sundayWorkouts: [String] = []
        @State private var workoutTitles: [String] = ["", "", "", "", "", "", ""]
        @State private var enteredTextWorkout = ""
        @State private var enteredTextSets = ""
        @State private var enteredTextReps = ""
        @State private var isAddingWorkoutAlertPresented = false
        
       
        @State private var selectedDietaryStrategy = "Cutting" // Default selection
        @State private var enteredCalories = ""
        @State private var isPlanExpanded = false
         @State private var isWorkoutExpanded = false
         @State private var isDietaryStrategyExpanded = false
        // Add these helper functions to the StepContentView
        func workoutsForDay() -> [String] {
            switch selectedDayIndex {
            case 0: return mondayWorkouts
            case 1: return tuesdayWorkouts
            case 2: return wednesdayWorkouts
            case 3: return thursdayWorkouts
            case 4: return fridayWorkouts
            case 5: return saturdayWorkouts
            case 6: return sundayWorkouts
            default: return []
            }
        }
        func addWorkout() {
            guard !enteredTextWorkout.isEmpty else {
                // Display an alert or perform any other error handling for an empty workout name
                return
            }
            // Combine the entered workout details
            let workoutDetails = "\(enteredTextWorkout), Sets: \(enteredTextSets), Reps: \(enteredTextReps)"
            // Append the workout details to the appropriate array for the selected day
            switch selectedDayIndex {
            case 0: mondayWorkouts.append(workoutDetails)
            case 1: tuesdayWorkouts.append(workoutDetails)
            case 2: wednesdayWorkouts.append(workoutDetails)
            case 3: thursdayWorkouts.append(workoutDetails)
            case 4: fridayWorkouts.append(workoutDetails)
            case 5: saturdayWorkouts.append(workoutDetails)
            case 6: sundayWorkouts.append(workoutDetails)
            default: break
            }
            // Clear the entered text fields
            enteredTextWorkout = ""
            enteredTextSets = ""
            enteredTextReps = ""
            
            // Dismiss the alert
            isAddingWorkoutAlertPresented = false
        }
        
        
        func deleteWorkout(at offsets: IndexSet) {
            switch selectedDayIndex {
            case 0: mondayWorkouts.remove(atOffsets: offsets)
            case 1: tuesdayWorkouts.remove(atOffsets: offsets)
            case 2: wednesdayWorkouts.remove(atOffsets: offsets)
            case 3: thursdayWorkouts.remove(atOffsets: offsets)
            case 4: fridayWorkouts.remove(atOffsets: offsets)
            case 5: saturdayWorkouts.remove(atOffsets: offsets)
            case 6: sundayWorkouts.remove(atOffsets: offsets)
            default: break
            }
        }
        
        
        @State private var showError = false
        @State private var errorMessage = ""
        @State private var tempCals = ""
        
        @State private var selectedImage: UIImage?
        @State private var isImagePickerPresented: Bool = false
        
        
        // Function to handle plan creation logic
        // Function to handle plan creation logic
        func addPlan() {
            // Check and set enteredCalories to "0" if it is empty
//            if enteredCalories.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                enteredCalories = "0"
//            }

            // Ensure that plan ID and plan name are not blank
            guard !enteredTextAt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                // Display an error view with a message for a blank Plan ID
                errorMessage = "Plan ID cannot be blank"
                currentStep = 1
                enteredCalories = ""
                enteredTextAt = ""
                showError = true
                return
            }

            guard !enteredTextName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                // Display an error view with a message for a blank Plan Name
                errorMessage = "Plan Name cannot be blank"
                currentStep = 1
                enteredCalories = ""
                enteredTextName = ""
                showError = true
                return
            }

            // Query Firestore to check if the plan ID is unique
            let db = Firestore.firestore()
            let plansCollection = db.collection("AllPlans")

            plansCollection.document(enteredTextAt).getDocument { (document, error) in
                if let error = error {
                    // Handle the error, e.g., show an error view
                    errorMessage = "An error occurred while checking the plan ID. Please try again."
                    showError = true
                    print("Error getting document: \(error)")
                } else {
                    // Safely unwrap the DocumentSnapshot
                    if let document = document, document.exists {
                        // Display an error view with a message for a non-unique Plan ID
                        currentStep = 1
                        enteredCalories = ""
                        enteredTextAt = ""
                        errorMessage = "Please choose a different Plan ID"
                        showError = true
                    } else {
                        // Document doesn't exist, create the plan
                        plansCollection.document(enteredTextAt).setData([
                            "verified": "no",
                            "creator": authEmail,
                            "description": enteredTextDesc,
                            "name": enteredTextName,
                            "unique": enteredTextAt
                        ])
                        { error in
                        //plansCollection.document(enteredTextAt).setData([:]) { error in
                            if error != nil {
                                // Handle the error, e.g., show an error view
                                errorMessage = "An error occurred while creating the plan. Please try again."
                                showError = true
                            } else {
                                // Create subcollections and documents
                                createDietCollection(for: plansCollection.document(enteredTextAt))
                                createOverviewCollection(for: plansCollection.document(enteredTextAt))
                                createSplitCollection(for: plansCollection.document(enteredTextAt))

                                // After the plan and subcollections are successfully created, show the success message
                                showSuccessMessage = true

                                // Example: Simulate a delay before navigating back
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    // Dismiss the view after the plan is added
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        func uploadImageToFirebaseStorage(selectedImage: UIImage) {
            // Get a reference to the root storage directory
            let storageRef = Storage.storage().reference()

            // Specify the folder path (e.g., "images/")
            let folderPath = "planPics/"

            // Use a fixed name for the image within the folder (e.g., "test.jpg")
            let imageName = "\(folderPath)\(enteredTextAt).jpg"
            let imageRef = storageRef.child(imageName)

            // Convert the UIImage to Data
            if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                // Upload the data to Firebase Storage
                let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                    } else {
                        // Image uploaded successfully
                        print("Image uploaded to Firebase Storage")

                        // You can also get the download URL if needed
                        imageRef.downloadURL { (url, error) in
                            if let downloadURL = url {
                                print("Download URL: \(downloadURL)")
                                // Now you can use the download URL as needed (e.g., store it in your database)
                            } else if let error = error {
                                print("Error getting download URL: \(error.localizedDescription)")
                            }
                        }
                    }
                }

                // You can use the uploadTask to observe the progress or perform additional actions if needed
                // uploadTask.observe(.progress) { snapshot in
                //     let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                //     print("Upload progress: \(percentComplete)%")
                // }

                // Uncomment the above lines if you want to observe the upload progress
            }
        }




        func createDietCollection(for planDocument: DocumentReference) {
            let dietCollection = planDocument.collection("Diet")
            
            dietCollection.document("details").setData([
                "calories": enteredCalories,
                "dietaryStrategy": selectedDietaryStrategy
            ]) { error in
                if let error = error {
                    // Handle the error for the "Diet" subcollection
                    print("Error adding document to Diet subcollection: \(error)")
                }
            }
        }

        func createOverviewCollection(for planDocument: DocumentReference) {
            let overviewCollection = planDocument.collection("Overview")
            
            overviewCollection.document("details").setData([
                "planName": enteredTextName,
                "planID": enteredTextAt,
                "planDescription": enteredTextDesc,
                "privacySelection": privacySelection,
                "selectedCategory": selectedCategory,
                "creator": authEmail,
                "verified": "no"
            ]) { error in
                if let error = error {
                    // Handle the error for the "Overview" subcollection
                    print("Error adding document to Overview subcollection: \(error)")
                }
            }
        }
        
        func createSplitCollection(for planDocument: DocumentReference) {
            // Create the Split collection with documents for each day
            for (index, day) in daysOfWeek.enumerated() {
                let dayDocument = planDocument.collection("Split").document(day)
                dayDocument.setData(["type": workoutTitles[index]]) { error in
                    if let error = error {
                        errorMessage = "An error occurred while creating the Split collection. Please try again."
                        showError = true
                        print("Error adding document to Split collection: \(error)")
                    } else {
                        let workoutCollection = dayDocument.collection("theWorkout")
                        let workoutArray = getWorkoutArrayForDay(day)

                        // Add each workout to the "theWorkout" collection with a unique name
                        for (workoutIndex, workout) in workoutArray.enumerated() {
                            // Split the workout details into name, sets, and reps
                            let components = workout.components(separatedBy: ", Sets: ")
                            let name = components[0]
                            let setsReps = components[1].components(separatedBy: ", Reps: ")
                            let sets = setsReps[0]
                            let reps = setsReps[1]

                            let workoutDocument = workoutCollection.document("\(workoutIndex)")
                            workoutDocument.setData([
                                "completed": "no",
                                "id": "\(workoutIndex)",
                                "name": name,
                                "notes": "",
                                "recSets": sets,
                                "recReps": reps,
                                "sets": sets,
                                "reps": reps,
                                "weight": "0"
                            ]) { workoutError in
                                if let workoutError = workoutError {
                                    errorMessage = "An error occurred while creating a workout document. Please try again."
                                    showError = true
                                    print("Error adding workout document: \(workoutError)")
                                } else {
                                    print("Successfully created workout document \(workoutIndex) for \(day)")
                                }
                            }
                        }
                    }
                }
            }
        }



        // Function to get the workout array for a specific day
        func getWorkoutArrayForDay(_ day: String) -> [String] {
            switch day {
            case "Monday": return mondayWorkouts
            case "Tuesday": return tuesdayWorkouts
            case "Wednesday": return wednesdayWorkouts
            case "Thursday": return thursdayWorkouts
            case "Friday": return fridayWorkouts
            case "Saturday": return saturdayWorkouts
            case "Sunday": return sundayWorkouts
            default: return []
            }
        }
        
        @State private var isSheetPresented = false
        @State private var selectedCategory = "None"
        
        // Array of day names
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        // Use a state variable to track the selected day
        @State private var selectedDayIndex = 0
        var body: some View {
          
            VStack {
                switch currentStep {
                case 1:
                    // Text fields for plan details
                    
                    VStack {
                    Text("Plan Overview")
                        .font(.system(size: 37.5, weight: .bold, design: .rounded))
                        .bold()
                    
                    
              
                        // Add plan thumbnail pic
                        Button(action: {
                           
                            isImagePickerPresented.toggle()
                          
                        }) {
                            ZStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill() // Use scaledToFill to maintain aspect ratio and fill the frame
                                        .frame(width: 175, height: 175) // Adjust the size as needed
                                        .clipped() // Ensure the image doesn't exceed the frame boundaries
                                  
                                   
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 175, height: 175) // Adjust the size as needed
                                        .overlay(
                                            Image(systemName: "plus")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                        )
                                }
                            }

                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePickerView(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
                    
                        }
                      
                        Text(selectedImage == nil ? "Add a cover picture" : "Change cover picture").foregroundColor(.gray)
                    
                    
                    TextField("Enter a plan title", text: $enteredTextName)
                        .textFieldStyle(MyTextFieldStyle())
                        .padding(.top,2.5)
                        .padding(.bottom,15)
                        .padding(.leading, 2.5)
                        .padding(.trailing, 2.5)

                    
                        
                        
                    TextField("Create a unique plan ID", text: $enteredTextAt)
                        .textFieldStyle(MyTextFieldStyle())
                        .padding(.leading, 2.5)
                        .padding(.trailing, 2.5)
                        .disableAutocorrection(true) // Disable autocorrection
                    
                    
                    
                    Spacer()
                    
                    
                   
                        HStack {
                            // Previous button
                            Button(action: {
                                if currentStep > 1 {
                                    currentStep -= 1
                                }
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(CustomColor.limeColor)
                                    .cornerRadius(8)
                            }
                            .padding()
                            Spacer()
                            // Button symbol
                            let buttonSymbol = currentStep == 4 ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                            // Next button
                            Button(action: {
                                if currentStep < 4 {
                                    currentStep += 1
                                } else {
                                    // Show the confirmation alert only on the fourth step
                                    isConfirmationAlertPresented = true
                                }
                            }) {
                                Image(systemName: buttonSymbol)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(CustomColor.limeColor)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                }
                case 2:
                    Text("Workout Split")
                        .font(.system(size: 37.5, weight: .bold, design: .rounded))
                        .bold()
                    
                    CreateCoolView(currentDay: $selectedDayIndex, dayNames: daysOfWeek) { index in
                        // Handle tap on a day in Case 2 (you can perform additional actions here)
                        print("Selected day index in Case 2: \(index)")
                    }
                    .padding(.bottom, 10)
                    
                    
                    HStack {
                        Text("What kind of workout is this day?")
                            .padding(.top)
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        Spacer() // Add a spacer to push the text to the leading edge
                        
                    }
                        
                                
                    // Text field for entering workout type (e.g., legs, chest)
                    TextField("Examples: Chest, Legs, Recovery", text: $workoutTitles[selectedDayIndex])
                        .textFieldStyle(MyTextFieldStyle()) // Apply your custom text field style if needed
                    VStack {
                        // Add Workout button as a full-width button
                        Button(action: {
                            isAddingWorkoutAlertPresented = true // Set this flag to show the alert
                        }) {
                            Text("Add an exercise to workout")
                                .frame(maxWidth: .infinity, minHeight: 35)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .background(CustomColor.limeColor)
                                .cornerRadius(15)
                        }
                        .alert("Add an exercise to workout", isPresented: $isAddingWorkoutAlertPresented, actions: {
                            TextField("Exercise Name", text: $enteredTextWorkout).multilineTextAlignment(.leading)
                            TextField("Sets", text: $enteredTextSets).multilineTextAlignment(.leading)
                            TextField("Reps", text: $enteredTextReps).multilineTextAlignment(.leading)
                            Button("Add", action: { addWorkout() })
                            Button("Cancel", role: .cancel, action: { isAddingWorkoutAlertPresented = false })
                        })
                    }.padding(.top, 3)
                    
                    
                    // Add a placeholder if the list is empty
                    if workoutsForDay().isEmpty {
                        Text("No exercises added for \(daysOfWeek[selectedDayIndex]).")
                            .foregroundColor(.gray).padding(.top, 50)
                    }
                    if !workoutsForDay().isEmpty {
                        List {
                            ForEach(workoutsForDay(), id: \.self) { workout in
                                HStack {
                                    Text(workout)
                                    Spacer()
                                    Button(action: {
                                        deleteWorkout(at: IndexSet(integer: workoutsForDay().firstIndex(of: workout)!))
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .onDelete(perform: deleteWorkout) // Enable swipe to delete and edit button for each row
                        }
                    }
                    
                    Spacer()
                    HStack {
                        // Previous button
                        Button(action: {
                            if currentStep > 1 {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(CustomColor.limeColor)
                                .cornerRadius(8)
                        }
                        .padding()
                        Spacer()
                        // Button symbol
                        let buttonSymbol = currentStep == 4 ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                        // Next button
                        Button(action: {
                            if currentStep < 4 {
                                currentStep += 1
                            } else {
                                // Show the confirmation alert only on the fourth step
                                isConfirmationAlertPresented = true
                            }
                        }) {
                            Image(systemName: buttonSymbol)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(CustomColor.limeColor)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                  
                    
                  
                case 3:
            
                        Text("Dietary Strategy")
                            .font(.system(size: 37.5, weight: .bold, design: .rounded))
                            .bold()
                        // Create a Picker with three options: Cutting, Bulking, N/A
                        Picker("Select Strategy", selection: $selectedDietaryStrategy) {
                            Text("Cutting").tag("Cutting")
                            Text("Bulking").tag("Bulking")
                            Text("N/A").tag("N/A")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.leading)
                        .padding(.trailing)
                        HStack {
                            Text("Calorie difference from BMR")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            
                            NavigationLink(destination: InfoCalDiff()) {
                                Image(systemName: "questionmark.circle") .foregroundColor(.gray)
                            }
                            Spacer() // Add a spacer to push the text to the leading edge
                        }.padding(.top)
                        // Use a TextField for entering the amount of calories
                        TextField("Enter Calories", text: $enteredCalories)
                            .keyboardType(.numberPad)
                            .textFieldStyle(MyTextFieldStyle())
                            .onChange(of: selectedDietaryStrategy) { newValue in
                                // Check if selectedDietaryStrategy is "N/A" and set enteredCalories to "0" in that case
                                if newValue == "N/A" {
                                    enteredCalories = "0"
                                } else {
                                    // Reset enteredCalories to "Enter Calories" for other values
                                    enteredCalories = ""
                                }
                            }
                        Text("Recommendations")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        // Suggested calorie values
                        HStack {
                            Button("100") {
                                enteredCalories = "100"
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.cyan)
                            .cornerRadius(25)
                            Button("250") {
                                enteredCalories = "250"
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.cyan)
                            .cornerRadius(25)
                            Button("400") {
                                enteredCalories = "400"
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.cyan)
                            .cornerRadius(25)
                        }
                    
                    Spacer()

                    
                    HStack {
                        // Previous button
                        Button(action: {
                            if currentStep > 1 {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(CustomColor.limeColor)
                                .cornerRadius(8)
                        }
                        .padding()
                        Spacer()
                        // Button symbol
                        let buttonSymbol = currentStep == 4 ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                        // Next button
                        Button(action: {
                            if currentStep < 4 {
                                currentStep += 1
                            } else {
                                // Show the confirmation alert only on the fourth step
                                isConfirmationAlertPresented = true
                            }
                        }) {
                            Image(systemName: buttonSymbol)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(CustomColor.limeColor)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                  
                case 4:
                    Text("Optional Settings")
                        .font(.system(size: 37.5, weight: .bold, design: .rounded))
                        .bold()
                    
                    
//                    TextField("Enter a plan description", text: $enteredTextDesc)
//                        .textFieldStyle(MyTextFieldStyle())
//                        .padding(.bottom,5)
//                        .padding(.leading, 2.5)
//                        .padding(.trailing, 2.5)
                    
                    
                    VStack {
                        HStack {
                            Text("Add a brief plan description")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .bold()
                           
                        }.padding(.top,2)

                        // Use TextEditor for multiline input
                        TextEditor(text: $enteredTextDesc)
                            .frame(height: 100)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                            .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                    }
                            
                    
                    VStack {
                        
                        Text("Privacy Settings")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.black).padding(.top, 5)
                        
                        
                        Picker("Privacy Settings", selection: $privacySelection) {
                            Text("Private").tag("Private")
                            Text("Public").tag("Public")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom)
                        
                        VStack {
                            Button(action: {
                                isSheetPresented.toggle()
                            }) {
                                HStack {
                                    
                                    Text("Add a Plan Category")
                                        .font(.system(size: 25, weight: .bold, design: .rounded)).padding(.bottom, 2.5)
                                    
                                    
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(CustomColor.limeColor).bold()
                                }
                                
                                
                            }
                            Text("Selected Category: \(selectedCategory)").font(.system(size: 15)).onTapGesture {
                                isSheetPresented.toggle()
                            }
                            
                        }
                        
                        
                        .sheet(isPresented: $isSheetPresented) {
                            NavigationView {
                                ScrollView {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                        ForEach(Categories, id: \.0) { category in
                                            Button(action: {
                                                selectedCategory = category.0
                                                isSheetPresented.toggle()
                                            }) {
                                                VStack {
                                                    Text(category.1) // Emoji
                                                        .font(.largeTitle)
                                                    Text(category.0) // Category Name
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(.cyan)
                                                .cornerRadius(10)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding()
                                }
                                .navigationTitle("Select Category").bold()
                                .navigationBarItems(trailing: Button("Cancel") {
                                    isSheetPresented.toggle()
                                })
                            }
                            
                        }
                        Spacer()
                        
                        HStack {
                            // Previous button
                            Button(action: {
                                if currentStep > 1 {
                                    currentStep -= 1
                                }
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(CustomColor.limeColor)
                                    .cornerRadius(8)
                            }
                            .padding()
                            Spacer()
                            // Button symbol
                            let buttonSymbol = currentStep == 4 ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                            // Next button
                            Button(action: {
                                if currentStep < 4 {
                                    currentStep += 1
                                } else {
                                    // Show the confirmation alert only on the fourth step
                                    isConfirmationAlertPresented = true
                                }
                            }) {
                                Image(systemName: buttonSymbol)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(CustomColor.limeColor)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                    
                default:
                    EmptyView()
                }
            }
            .padding()
            
            Spacer()
            
            SuccessPlanView(message: "Plan Created Successfully", isVisible: $showSuccessMessage)
            // In your main view, conditionally display the ErrorPlanView
            if showError {
                ErrorPlanView(errorMessage: errorMessage)
                    .onAppear {
                        // Automatically hide the error message after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showError = false
                        }
                    }
            }
            
            
//            HStack {
//                // Previous button
//                Button(action: {
//                    if currentStep > 1 {
//                        currentStep -= 1
//                    }
//                }) {
//                    Image(systemName: "arrow.left.circle.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(CustomColor.limeColor)
//                        .cornerRadius(8)
//                }
//                .padding()
//                Spacer()
//                // Button symbol
//                let buttonSymbol = currentStep == 3 ? "checkmark.circle.fill" : "arrow.right.circle.fill"
//                // Next button
//                Button(action: {
//                    if currentStep < 3 {
//                        currentStep += 1
//                    } else {
//                        // Show the confirmation alert only on the fourth step
//                        isConfirmationAlertPresented = true
//                    }
//                }) {
//                    Image(systemName: buttonSymbol)
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(CustomColor.limeColor)
//                        .cornerRadius(8)
//                }
//                .padding()
//            }
            // Page indicator
            HStack {
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(1..<5) { step in
                        Circle()
                            .fill(step <= currentStep ? CustomColor.limeColor : Color.gray)
                            .frame(width: 15, height: 15)
                    }
                }
               
                Spacer()
            }
           


            
            
            .alert(isPresented: $isConfirmationAlertPresented) {
                Alert(
                    title: Text("Create Plan"),
                    message: Text("Are you sure you want to create this plan?"),
                    primaryButton: .default(Text("Yes!")) {
                        // Implement logic to navigate back to LiftView
                        addPlan()
                        if let unwrappedImage = selectedImage {
                            uploadImageToFirebaseStorage(selectedImage: unwrappedImage)
                        } else {
                            // Handle the case when selectedImage is nil (optional is not set)
                            print("Error: No image selected.")
                        }

                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
struct CreatePlanView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePlanView()
    }
}
struct SuccessPlanView: View {
    let message: String
    @Binding var isVisible: Bool
    var body: some View {
        if isVisible {
            VStack {
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(CustomColor.limeColor)
                    .cornerRadius(10)
                    .opacity(isVisible ? 1 : 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            // Automatically hide the success message after 2 seconds
                            isVisible = false
                        }
                    }
            }
            .padding()
            .transition(.slide)
        }
    }
}

struct ErrorPlanView: View {
    let errorMessage: String

    var body: some View {
        VStack {
            Text(errorMessage)
                .foregroundColor(.white)
                .padding()
                .background(Color.red) // Set the background color to red
                .cornerRadius(10)
                .opacity(1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // Automatically hide the error message after 2 seconds
                        // You can customize the duration or remove this part if not needed
                    }
                }
        }
        .padding()
        .transition(.slide)
    }
}


struct MultiSelectTags: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    var body: some View {
        VStack {
            Text("Select Tags:")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Button(action: {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }) {
                            Text(tag)
                                .padding()
                                .foregroundColor(selectedTags.contains(tag) ? .white : .blue)
                                .background(selectedTags.contains(tag) ? .blue : .gray)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
}
struct CreateCoolView: View {
    @Binding var currentDay: Int
    let dayNames: [String]
    let onTapGesture: (Int) -> Void
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<7) { index in
                ZStack {
                    Circle()
                        .frame(width: 32.5, height: 32.5)
                        .foregroundColor(index == currentDay ? .cyan : Color.white)
                        .overlay(Circle().stroke(.cyan, lineWidth: 2))
                        .onTapGesture {
                            currentDay = index
                            onTapGesture(index) // Call the onTapGesture closure with the selected index
                        }
                    Text(String(dayNames[index].prefix(1)))
                        .font(.system(size: 15, weight: index == currentDay ? .bold : .regular))
                        .foregroundColor(index == currentDay ? .white : .cyan)
                }
                if index < 6 {
                    LineBlue()
                }
            }
        }
        
    }
}
struct LineBlue: View {
    var body: some View {
        Rectangle()
            .fill(.cyan)
            .frame(width: 10, height: 2)
    }
}




struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType = .photoLibrary
        return imagePickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            parent.isImagePickerPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }
}
