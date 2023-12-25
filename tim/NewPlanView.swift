import SwiftUI
import Firebase
import FirebaseStorage

struct RemoteImage: View {
    @State private var image: Image?
    
    let storagePath: String
    let labelText = "Bon's Fatburn" // Hardcoded label
    
    
    //search
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    let yourArray = [String]()
    @State private var showCancelButton = false
    
    
    
    
    init(_ storagePath: String) {
        self.storagePath = storagePath
    }
    
    
  
    
    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .frame(width: 75, height: 75) // Adjust the size as needed
                    .clipShape(Circle())
                HStack(spacing: 2.5) {
                    Text(labelText) // Hardcoded text label below the image
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Image(systemName: "checkmark.seal.fill") // Add the checkmark icon
                        .foregroundColor(CustomColor.limeColor) // Adjust the color
                        .imageScale(.small) // Make the icon smaller
                    
                }
            } else {
                ProgressView() .frame(height: 72.5) // Adjust the size as needed
                       .onAppear {
                           downloadImage()
                       }
            }
        }
        
        
        
    }
    
    private func downloadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

struct NewPlanView: View {
    //search
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    let yourArray = [String]()
    @State private var showCancelButton = false
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    @State private var showConfirmationAlert = false
    @State private var showSuccessMessage = false
    
    //types
    @State private var isExpanded = false
    @State private var checkBox1 = false
    @State private var checkBox2 = false
    @State private var checkBox3 = false
    @State private var checkBox4 = false
    
    
    
    
    func addDocumentToFirestore() {
        // Assuming you have Firebase initialized
        let db = Firestore.firestore()

        // Replace "your_collection" with your actual Firestore collection name
        let docRef = db.collection("SelectedPlans").document("users").collection(authEmail).document("lucaplan2")

        // Set data with the "name" field
        let data: [String: Any] = [
            "name": "lucaplan2"
            // Add other fields if needed
        ]

        docRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully!")
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Automatically hide the success message after 2 seconds
                    showSuccessMessage = false
                }
            }
        }
    }

    
    var body: some View {
        VStack {
            Text("Trending Plans")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .padding(.top, 10)
            
            HStack(spacing: 27.5) {
                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png").onTapGesture {
                    showConfirmationAlert = true
                }
                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png")
                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png")
            }
            .padding(.top, 5)
            
            
            Text("Find a Creator's Plan")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .padding(.top, 5)
                .padding(.bottom, 0)
            
           
        
            
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(alignment: .leading) {
                        Toggle("Cutting 🍎", isOn: $checkBox1) .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.cyan)
                        
                        Toggle("Bulking 🍗", isOn: $checkBox2).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.cyan)
                        Toggle("Power Lifting 🏋️‍♀️", isOn: $checkBox3).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.cyan)
                        Toggle("Calisthenics 🤸‍♂️", isOn: $checkBox4).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.cyan)
                    }.padding()
                    
                },
                label: {
                    HStack {
                        Text("Filter By Type")
                            .font(.system(size: 17.5, weight: .bold, design: .rounded))
                        
                    }
                }
            )
            .padding(.leading)
            .padding(.trailing)
            
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        TextField("Search...", text: $searchText, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                            //viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
                            
                        }, onCommit: {
                            print("onCommit")
                        })
                        .foregroundColor(.primary)
                        //                        .onChange(of: searchText) { newValue in
                        //                            self.searchResults = filteredArray
                        //                            //viewModel2.addElement(emailVal: authEmail, userSearch: searchText)
                        //                        }
                        
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        
                        
                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(searchText.isEmpty ? 0 : 1)
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 6, bottom: 8, trailing: 6))
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
                
                
                if searchText != "" {
                    VStack {
                        //                                // Display the elements in the array
                        //                                List(viewModel2.elementsArray, id: \.self) { element in
                        //                                    HStack {
                        //
                        //                                        Text(element)
                        //
                        //                                        Spacer()
                        //
                        //                                        Image(systemName: "plus.circle") .foregroundColor(CustomColor.limeColor) .onTapGesture { newFoodEntryFromFav(favName: element)}
                        //
                        //
                        //                                    }
                        //
                        //                                }
                        
                        
                    }
                    .padding()
                    .frame(maxHeight: 100)
                    .listStyle(PlainListStyle())
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(showCancelButton)
            
            
            
            Spacer()
        }.alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Add Workout Plan"),
                message: Text("Are you sure you add this plan?"),
                primaryButton: .destructive(Text("Cancel")),
                secondaryButton: .default(Text("Confirm")) {
                    addDocumentToFirestore()
                }
            )
        } .overlay(
            SuccessMessageView(message: "Workout plan added successfully!", isVisible: $showSuccessMessage)
        )
        
    }
}

struct NewPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlanView()
    }
}



struct SuccessMessageView: View {
    let message: String
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack {
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5))
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
