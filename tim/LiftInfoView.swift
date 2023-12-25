import SwiftUI
import FirebaseFirestore

struct LiftInfoView: View {
    let exerciseName: String // Add a property to hold the exercise name
    @State private var reps: String
    @State private var sets: String
    @State private var weight: String
    @State private var notes: String
    @State private var recReps: String
    @State private var recSets: String
    @State private var plan: String
    @State private var theID: String
    @State private var showingAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // Function to reset reps and sets to creator's recommendations
    func resetToRecommendations() {
        reps = recReps
        sets = recSets
        weight = "0" // Set weight to 0
      

        // Save changes to Firestore
        saveChanges()
    }

    // Function to save changes to Firestore
    func saveChanges() {
        // Update Firestore document with the new values

        let db = Firestore.firestore()

        // Get the current day of the week
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // "EEEE" gives the full day name, e.g., "Monday"
        let currentDay = dateFormatter.string(from: currentDate)

        let docRef = db.collection("AllPlans")
            .document(plan)
            .collection("Split")
            .document(currentDay) // Use the current day of the week
            .collection("theWorkout")
            .document(theID)

        docRef.updateData([
            "reps": reps,
            "sets": sets,
            "weight": weight,
            "notes": notes,
            // Add other fields as needed
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                showToast(message: "Error updating document")
            } else {
                print("Document successfully updated")
                showToast(message: "Changes saved successfully!")
            }
        }
    }


      private func showToast(message: String) {
          toastMessage = message
          showToast.toggle()

          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              showToast.toggle()
          }
      }

    
    init(exerciseName: String, reps: String, sets: String, weight: String, notes: String, recReps: String, recSets: String, plan: String, theID: String) {
        self.exerciseName = exerciseName
        self._reps = State(initialValue: reps)
        self._sets = State(initialValue: sets)
        self._weight = State(initialValue: weight)
        self._notes = State(initialValue: notes)
        self._recReps = State(initialValue: recReps)
        self._recSets = State(initialValue: recSets)
        self._plan = State(initialValue: plan)
        self._theID = State(initialValue: theID)
        
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
           
            
            HStack {
                Text("\(exerciseName)")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.cyan) // Adjust color as needed

                Spacer()

                // Button to reset reps and sets
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Reset")
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 8).fill(CustomColor.limeColor))
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("WARNING"),
                        message: Text("Are you sure you want to return back to creator recommendations?"),
                        primaryButton: .default(Text("Cancel")),
                        secondaryButton: .destructive(Text("Confirm"), action: resetToRecommendations)
                    )
                }


            }

            HStack {
                Text("Reps:")
                    .frame(width: 60, alignment: .leading)
                    .foregroundColor(Color.black)

                TextField("Enter Reps", text: $reps)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            HStack {
                Text("Sets:")
                    .frame(width: 60, alignment: .leading)
                    .foregroundColor(Color.black)

                TextField("Enter Sets", text: $sets)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            HStack {
                Text("Weight:")
                    .frame(width: 60, alignment: .leading)
                    .foregroundColor(Color.black)

                TextField("Enter Weight", text: $weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            HStack {
                Text("Notes:")
                    .frame(width: 60, alignment: .leading)
                    .font(.headline)
                    .foregroundColor(Color.cyan) // Adjust color as needed
                    .bold()

                Spacer() // Add spacer to align TextEditor with the other Text elements

                // Use TextEditor for multiline input
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding([.top, .bottom, .trailing])
            }
            
            // HStack to center the "Save" button
            HStack {
                Spacer()

                // Button to save changes
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 90) // Increase horizontal padding to make the button wider
                        .padding(.vertical, 15)    // Increase vertical padding to make the button taller
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.cyan)) // Adjust color as needed
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(.top, 5) // Add top padding to separate the button from the TextEditor
                
                Spacer()
            }


            // Add more details and content related to the exercise here
            
            if showToast {
                HStack {
                    Spacer()
                    ToastView(message: toastMessage)
                    Spacer()
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // Background color for the entire view
        .cornerRadius(16)
        .alignmentGuide(.top) { $0[.bottom] }
    }
}

struct LiftInfoView_Previews: PreviewProvider {
    static var previews: some View {
        LiftInfoView(exerciseName: "Sample Exercise", reps: "8", sets: "4", weight: "150", notes: "", recReps: "1", recSets: "1", plan: "plan", theID: "0")
            .preferredColorScheme(.light) // Adjust color scheme for preview
    }
}



struct ToastView: View {
    var message: String

    var body: some View {
        
            Text(message)
                .foregroundColor(.black)
                .background(Color.clear)
                .cornerRadius(8) // Optional: add corner radius
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
         
        }
    
}
