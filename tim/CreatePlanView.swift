import SwiftUI

struct CreatePlanView: View {
    @State private var currentStep = 1
    @State private var isConfirmationAlertPresented = false
    @State private var showSuccessMessage = false
    @Environment(\.presentationMode) var presentationMode
    @State private var enteredTextName = ""  // Intermediate variable
    @State private var enteredTextAt = ""  // Intermediate variable
    @State private var enteredTextDesc = ""  // Intermediate variable
    @State private var enteredTextMonday = ""  // Intermediate variable

    var body: some View {
        VStack {
            // Step content
            // Step content
            StepContentView(step: currentStep, enteredTextName: $enteredTextName, enteredTextAt: $enteredTextAt, enteredTextDesc: $enteredTextDesc, enteredTextMonday: $enteredTextMonday)

            Spacer()

            // Show the success message view
            SuccessPlanView(message: "Plan Created Successfully", isVisible: $showSuccessMessage)

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

            // Page indicator
            HStack(spacing: 10) {
                ForEach(1..<5) { step in
                    Circle()
                        .fill(step <= currentStep ? CustomColor.limeColor : Color.gray)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(.bottom)
        }
        .alert(isPresented: $isConfirmationAlertPresented) {
            Alert(
                title: Text("Create Plan"),
                message: Text("Are you sure you want to proceed?"),
                primaryButton: .default(Text("Yes")) {
                    // Implement logic to navigate back to LiftView
                    addPlan()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Function to handle plan creation logic
    func addPlan() {
        // Perform your plan creation logic here

        // After the plan is successfully created, show the success message
        showSuccessMessage = true

        // Example: Simulate a delay before navigating back
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Dismiss the view after the plan is added
            presentationMode.wrappedValue.dismiss()
        }

        // Access the entered text from the intermediate variable
        let enteredText = self.enteredTextName
        print("Entered Text: \(enteredText)")
    }
}

struct CreatePlanView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePlanView()
    }
}

struct StepContentView: View {
    let step: Int
    @Binding var enteredTextName: String
    @Binding var enteredTextAt: String
    @Binding var enteredTextDesc: String
    @Binding var enteredTextMonday: String
    @State private var isPublic = false
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
        ("Biking", "🚴‍♀️")
    ]


    @State private var isSheetPresented = false
       @State private var selectedCategory: (String, String)?
    
    // Array of day names
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    // Use a state variable to track the selected day
    @State private var selectedDayIndex = 0

    var body: some View {
        VStack {
            switch step {
            case 1:
                // Text fields for plan details
                
                Text("Plan Overview")
                    .font(.system(size: 37.5, weight: .bold, design: .rounded))

                       .bold()
                
                
                TextField("Enter Plan Display Name", text: $enteredTextName)
                    .textFieldStyle(MyTextFieldStyle())
                    .padding(.bottom)

                TextField("Enter Plan Unique @", text: $enteredTextAt)
                    .textFieldStyle(MyTextFieldStyle())
                    .padding(.bottom)
                    .disableAutocorrection(true) // Disable autocorrection

                TextField("Enter Plan Description", text: $enteredTextDesc)
                    .textFieldStyle(MyTextFieldStyle())
                    .padding(.bottom)
                  
                
                
//                Text("Privacy Settings")
//                    .font(.system(size: 27.5, weight: .bold, design: .rounded))
//                    .padding(.bottom, 2.5)
//                    .bold().foregroundColor(CustomColor.limeColor)
//
                
                HStack {
                    Button(action: {
                        // Handle action for the first button
                        if isPublic != false {
                            isPublic.toggle()
                        }
                    }) {
                        Text("Private")
                            .padding()
                            .foregroundColor(.white)
                            .background(isPublic ? Color.gray : Color.cyan)
                            .cornerRadius(4)
                    }

                    Button(action: {
                        // Handle action for the second button
                        if isPublic == false {
                            isPublic.toggle()
                        }
                    }) {
                        Text("Public")
                            .padding()
                            .foregroundColor(.white)
                            .background(isPublic ? Color.cyan : Color.gray)
                            .cornerRadius(4)
                    }
                }

                VStack {
                           Button(action: {
                               isSheetPresented.toggle()
                           }) {
                               HStack {
                               
                                   Text("Add a Plan Category")
                                       .font(.system(size: 25, weight: .bold, design: .rounded))
                                       .padding(.bottom, 2.5)
                                       .bold()
                                   
                                   Image(systemName: "plus")
                                       .foregroundColor(CustomColor.limeColor).bold()
                               }
                               
                                  
                           }

                    Text("Selected Category: \(selectedCategory?.0 ?? "None")") .font(.system(size: 15)) // Set the font size
                               
                       }
                .sheet(isPresented: $isSheetPresented) {
                    NavigationView {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                ForEach(Categories, id: \.0) { category in
                                    Button(action: {
                                        selectedCategory = category
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
                .padding()


                // ...

            case 2:
                Text("Workout Split")
                                    .font(.system(size: 37.5, weight: .bold, design: .rounded))
                                    .bold()

                                CreateCoolView(currentDay: $selectedDayIndex, dayNames: daysOfWeek) { index in
                                    // Handle tap on a day in Case 2 (you can perform additional actions here)
                                    print("Selected day index in Case 2: \(index)")
                                }
                                .padding(.bottom)

                                // Text field for entering workout type
                                TextField("Enter workout type for \(daysOfWeek[selectedDayIndex])", text: $enteredTextMonday)
                                    .textFieldStyle(MyTextFieldStyle()) // Apply your custom text field style if needed
                                    .padding(.bottom)

                                Spacer()


            case 3:
                Text("Dietary Strategy")
                    .font(.system(size: 37.5, weight: .bold, design: .rounded))
           
                       .bold()
                
                
                Spacer()
            case 4:
                Text("Plan Summary")
                    .font(.system(size: 37.5, weight: .bold, design: .rounded))
           
                       .bold()
                
                Spacer()
                
            default:
                EmptyView()
            }
        }
        .padding()
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
        .padding()
    }
}


struct LineBlue: View {
    var body: some View {
        Rectangle()
            .fill(.cyan)
            .frame(width: 10, height: 2)
    }
}
