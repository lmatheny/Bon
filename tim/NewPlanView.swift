import SwiftUI
import Firebase
import FirebaseStorage

struct RemoteImage: View {
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
                ProgressView().frame(height: 72.5) // Adjust the size as needed
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
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    @State private var showConfirmationAlert = false
    @State private var searchText = ""
    @State private var showCancelButton = false
    private var db = Firestore.firestore()
   
    
    @State private var isInfoPlanPresented = false
    @State private var selectedElement: String?  // Make sure to initialize it appropriately


    @ObservedObject var viewModel2 = ArrayAdditionViewModel2()

    func addDocumentToFirestore() {
        // Assuming you have Firebase initialized
        let db = Firestore.firestore()
        let docRef = db.collection("SelectedPlans").document("users").collection(authEmail).document("lucaplan2")
        let data: [String: Any] = [
            "name": "lucaplan2"
            // Add other fields if needed
        ]
        docRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully!")
            }
        }
    }

    
   // @State private var showText = true
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if searchText == "" {
                        Text("Featured Plans")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding(.top, 10)
                        
                        HStack(spacing: 27.5) {
                            
                            NavigationLink(destination: InfoPlan(element0: "lucaPlan1")) {
                                
                                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png")
                            }
                            
                            NavigationLink(destination: InfoPlan(element0: "lucaPlan1")) {
                                
                                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png")
                            }
                            
                            NavigationLink(destination: InfoPlan(element0: "lucaPlan1")) {
                                
                                RemoteImage("gs://tfinal-a07fc.appspot.com/luke.png")
                            }
                           
                        }
                        .padding(.top, 5)
                        
                        Text("Find a Creator's Plan")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding(.top, 5)
                    }
                    
                    
                    
                    
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
                    }.padding(.top, 2.5)
                        .padding(.horizontal)
                    
                }
                
                if searchText != "" {
                    
                    
                    NavigationView {
                        VStack{
                            List(viewModel2.elementsArray, id: \.0) { element in
                                NavigationLink(destination: InfoPlan(element0: element.0)) {
                                    VStack {
                                        HStack {
                                            Text(element.0)
                                            
                                            if element.1.lowercased() == "yes" {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(CustomColor.limeColor)
                                                    .imageScale(.small)
                                            } else if element.1.lowercased() != "no" {
                                                Text(element.1)
                                            }
                                            
                                            Spacer()
                                        }
                                        Text(element.2)
                                    }
                                }
                            }.alert(isPresented: $showConfirmationAlert) {
                                Alert(
                                    title: Text("Add Workout Plan"),
                                    message: Text("Are you sure you want to add this plan?"),
                                    primaryButton: .cancel(Text("Cancel")),
                                    secondaryButton: .default(Text("Confirm")) {
                                        addDocumentToFirestore()
                                    }
                                )}
                            .listStyle(PlainListStyle())
                            .padding(.horizontal)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct NewPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlanView()
    }
}

class ArrayAdditionViewModel2: ObservableObject {
    @Published var elementsArray: [(String, String, String)] = []

    func addElement(emailVal: String, userSearch: String) {
        elementsArray.removeAll()

        let db = Firestore.firestore()
        db.collection("AllPlans").getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found.")
                    return
                }

                for document in documents {
                    let documentData = document.data()
                    let documentID = document.documentID
                    let ver = documentData["verified"] as? String ?? ""
                    let display = documentData["name"] as? String ?? ""
                    let newElement = (documentID, ver, display)

                    if newElement.0.lowercased().contains(userSearch.lowercased()) || userSearch.isEmpty {
                        self.elementsArray.append(newElement)
                    }
                }
            }
        }
    }
}

struct InfoPlan: View {
    @State private var showConfirmationAlert = false
    @State private var navigateToLiftView = false
    @State private var showSuccessMessage = false
    var element0: String
    let authEmail = "" + (Auth.auth().currentUser?.email ?? "")
    

    func addPlanToCollection(planName: String) {
        // Assuming you have Firebase initialized
        let db = Firestore.firestore()
        
        // Reference to the document you want to query for values
        let sourceDocRef = db.collection("AllPlans").document(planName)
        
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
                    "description": value2,
                    "display": value3,
                    "verified": value4,
                    "fav": "no"
                    
    
                    // Add other fields if needed
                ]
                
                // Reference to the destination document
                let destDocRef = db.collection("SelectedPlans").document("users").collection(authEmail).document(planName)
                
                // Set data to the destination document
                destDocRef.setData(data) { error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("Document added successfully!")
                    }
                }
            } else {
                print("Source document does not exist")
            }
        }
    }


    
    var body: some View {
            VStack {
                // Use the passed value in this view
                Text("Info for: \(element0)")

                Spacer()

                Button(action: {
                    // Action to add plan
                    showConfirmationAlert = true
                }) {
                    Text("Add Plan")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Plan Details")
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Add Workout Plan"),
                    message: Text("Are you sure you want to add this plan?"),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .default(Text("Confirm")) {
                        addPlanToCollection(planName: element0)
                        showSuccessMessage = true
                        
                    }
                )
            }
            .overlay(
                SuccessMessageView(message: "Workout plan added successfully!", isVisible: $showSuccessMessage)
            )
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
                    //.animation(.easeInOut(duration: 0.5))

            }
            .padding()
            .transition(.slide)
            .onAppear {
                // Schedule a timer to hide the success message after 2 seconds
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    isVisible = false
                }
            }
        }
    }
}

