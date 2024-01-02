//
//  ContentView.swift
//  fmf
//
//  Created by Luke Matheny on 6/27/23.
//
import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore
class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    
    @Published var signedIn = false;
    
    var isSignedIn: Bool {
       
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in guard result != nil, error == nil
            else {
            //print("hello lukee")
            return
        }
            
            DispatchQueue.main.async {
                //succes
                //print("hello luke")
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        
        auth.createUser(withEmail: email, password: password) {[weak self] result, error in guard result != nil, error == nil else {
            
            return
        }
            
            DispatchQueue.main.async {
                //succes
                self?.signedIn = true
            }
        }
    }
    
    func signOut() {
        try? auth.signOut()
        
        self.signedIn = false;
    }
}
    
    struct ContentView: View {
        @EnvironmentObject var viewModel: AppViewModel
        //@State private var selectedTab : Tab = .clipboard
       
        init() {
            UITabBar.appearance().backgroundColor = UIColor.white
            UIToolbar.appearance().backgroundColor = UIColor.black
         }
        
        
        
        var body: some View {
            
            NavigationView {
                if viewModel.signedIn {
                    VStack {
                        TabView {
                            LiftView()
                                .tabItem {
                                    Label("", systemImage: "dumbbell")
                                }

                            CommunityView()
                                .tabItem {
                                    Label("", systemImage: "person.3.fill")
                                }

                            NewPlanView()
                                .tabItem {
                                    Label("", systemImage: "plus.magnifyingglass")
                                }

                            DietView()
                                .tabItem {
                                    Label("", systemImage: "fork.knife")
                                }

                           AccountView()
                                .tabItem {
                                    Label("", systemImage: "figure.wave")
                                }
                        }
                        
                        .toolbar {
                            HStack {
                                Image("banner")
                                    .resizable()
                                                  .frame(width: 100, height: 30)
                                                  .position(x: 0, y: 20) // Adjust the x position as needed

                                Spacer()

                                Button(action: {
                                    // Your action here
                                }, label: {
                                    Label("", systemImage: "bell.fill")
                                        .foregroundColor(CustomColor.stoneColor)
                                })

                                Button(action: {
                                    // Your action here
                                }, label: {
                                    Label("", systemImage: "person.fill")
                                        .foregroundColor(CustomColor.stoneColor)
                                })
                            }
                        }
                        
                        .accentColor(CustomColor.limeColor)



                    }



                

                } else {
                    SignInView()
                }
            }
            
            .onAppear {
                viewModel.signedIn = viewModel.isSignedIn
            }
        }
    }

struct CustomColor {
    static let limeColor = Color("lime")
    static let stoneColor = Color("stone")
    static let lgColor = Color("lg")
    
}
    
    
    struct SignInView: View {
        @State var email = ""
        @State var password = ""
        @EnvironmentObject var viewModel: AppViewModel
        var body: some View {
            VStack {
                Image("alogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                VStack {
                    TextField("Email Address", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    SecureField("Password", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding().background(Color(.secondarySystemBackground))
                    
                    
                    Button(action: {
                        guard !email.isEmpty, !password.isEmpty else {
                            return
                        }
                        
                        viewModel.signIn(email: email, password: password
                                         
                        )}, label: { Text("Sign In").foregroundColor(Color.white).frame(width: 200, height: 50)
                                
                            
                        })
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .padding(.top)
                        
                    
                    NavigationLink("Create Account", destination: SignUpView())
                        .padding()
                }
                .padding()
                
                
                Spacer()
            }
            .navigationTitle("Sign In")
            
        }
    }
struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    @State private var emailStr: String = ""
    private var db = Firestore.firestore()
    let authEmail = Auth.auth().currentUser?.email
    
    @EnvironmentObject var viewModel: AppViewModel
    
    func createDoc() {
        //create highest ID doc
        db.collection("highestID").document(email).setData([
            "theID": "0",
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //add account to users
        db.collection("Users").document(email).setData([
            "Valid": "yes",
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //create streak doc
        db.collection("DefStreak").document(email).setData([
            "theStreak": "0",
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //create calorie goal doc
        db.collection("calorieGoal").document(email).setData([
            "goal": "2000",
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
       
        //create live count doc
        db.collection("liveCountEaten").document(email).setData([
            "theTotal": "2000",
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //create daily food doc
        db.collection("DailyFoods").document("users").collection(email).document("test").setData([
            "calories": "0",
            "name": "Test"
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //delete the first doc
//        db.collection("DailyFoods").document("users").collection(email).document("test").delete() { err in
//            if let err = err {
//                print("Error removing document: \(err)")
//            } else {
//                print("Document successfully removed!")
//            }
//        }
//
        
        //create daily food doc
        db.collection("FavFoods").document("users").collection(email).document("test").setData([
            "calories": "0",
            "name": "Test"
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        
        //delete the first doc
//        db.collection("FavFoods").document("users").collection(email).document("test").delete() { err in
//            if let err = err {
//                print("Error removing document: \(err)")
//            } else {
//                print("Document successfully removed!")
//            }
//        }


        
    }
    
    var body: some View {
        VStack {
            Image("alogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            VStack {
                TextField("Email Address", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                SecureField("Password", text: $password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding().background(Color(.secondarySystemBackground))
                
                
                
                Button(action: {
                    createDoc()
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    viewModel.signUp(email: email, password: password
                                     
                    )}, label: { Text("Create Account").foregroundColor(Color.white).frame(width: 200, height: 50)
                            .cornerRadius(40)
                            .background(Color.black)
                        
                    })
            }
            .padding()
            
            
            Spacer()
        }
        .navigationTitle("Create Account")
        
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }


