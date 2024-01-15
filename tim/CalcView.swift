//
//  CalcView.swift
//  tim
//
//  Created by Luke Matheny on 7/14/23.
//

import SwiftUI
import SwiftUI
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct CalcView: View {
    @State private var selection = "Male"
    let genders = ["Male", "Female"]
    @State private var userHeightFt: String = ""
    @State private var userHeightIn: String = ""
    @State private var userWeightLB: String = ""
    @State private var userAge: String = ""
    @State public var userWorkout = 500
    @State private var userWorkoutStr: String = "400"
    @State public var theConstantMale = 88.362
    @State public var theConstantFemale = 447.593
    @State public var theWeight = 0.0
    @State public var theHeight = 0.0
    @State public var trimming = ""
    @State public var theWeightConverted = 0.0
    @State public var theAge = 0.0
    @State public var theBMR = 0.0
    @State public var theBMRInt = 0
    @State public var theBMRStr = ""
    @State public var theDef = 0
    @State private var userDefStr: String = "300"
    @State public var resultTitle = ""
    @State public var workoutTitle = ""
    @State public var resultFinalGoal = ""
    @State private var isShowingToast = false
    @State public var resultFinalGoalInt = 0
    @State private var showAlert = false
    @State private var showIt = false
    @Environment(\.presentationMode) var presentationMode
    private var db = Firestore.firestore()
    @State public var pastGoal = 0
    @State public var pastRem = 0
    @State public var newRem = 0
    @State public var goalDif = 0
    @State public var newRemStr = ""
    @State public var ogGoal = 0
    
    let auth = Auth.auth()
    let authEmail = Auth.auth().currentUser?.email
    @State public var emailStr = ""
    
    
    func updateGoalForDef() {
        resultFinalGoalInt =  theBMRInt + (Int(userWorkoutStr) ?? 0 ) -  (Int(userDefStr) ?? 0)
        resultFinalGoal = String(resultFinalGoalInt)
    }
    
    func getPastGoalOG () {
        emailStr = authEmail ?? ""
        
        //get past goal
        let docRef2 = db.collection("calorieGoal").document(emailStr)
        
        docRef2.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                ogGoal = Int(lastName) ?? 0
                print("last goalfresh \(ogGoal)")
               
                
                
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    
//    func getPastGoal () {
//        //get past goal
//        let docRef2 = db.collection("calorieGoal").document("bon")
//
//        docRef2.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//                trimming = dataDescription
//                trimming.removeLast()
//                let lastName = trimming.components(separatedBy: " ")[1]
//                pastGoal = Int(lastName) ?? 0
//                print("last goalfresh \(pastGoal)")
//                goalDif = resultFinalGoalInt - pastGoal
//
//
//                //liveCount = (Int(currentGoal) ?? 0) + liveCount
//            } else {
//                print("Document does not exist")
//            }
//        }
//
//        //getPastRem()
//    }
    
    
    func getPastRemOG () {
        //get past goal
        emailStr = authEmail ?? ""
        
        let docRef2 = db.collection("liveCountEaten").document(emailStr)
        
        docRef2.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                trimming = dataDescription
                trimming.removeLast()
                let lastName = trimming.components(separatedBy: " ")[1]
                pastRem = Int(lastName) ?? 0
                
                
                //liveCount = (Int(currentGoal) ?? 0) + liveCount
            } else {
                print("Document does not exist")
            }
        }
 
    }
    
    func updateRem() {
        emailStr = authEmail ?? ""
        
        //update rem
         goalDif = resultFinalGoalInt - ogGoal
        
         newRem = pastRem + goalDif
         newRemStr = String(newRem)
         
         db
             .collection("liveCountEaten")
             .document(emailStr)
             .updateData(
                 [
                     "theTotal" : newRemStr,
                     
                 ]
             ) { (error) in
                 if error != nil{
                     print("Error")
                 }
                 
                 else {
                     print("succesfully updated rem")
                     
                     
                 }
                 
             }
        updateDefGoal()
    }
    
    func updateDefGoal() {
        emailStr = authEmail ?? ""
      
    
        //update goal
        db
            .collection("calorieGoal")
            .document(emailStr)
            .updateData(
                [
                    "goal" : resultFinalGoal,
                    
                ]
            ) { (error) in
                if error != nil{
                    print("Error")
                }
                
                else {
                    print("succesfully updated")
                    
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
    }
    
    func findUserBMR() {
        
        //BMR = 66.5 + (13.75 × weight in kg) + (5.003 × height in cm) - (6.75 × age)
        //weight conversion
        theWeightConverted = (Double(userWeightLB) ?? 0.0) / (2.205)
        
        if(selection == "Male") {
            //the weight
            theWeight = (13.397 * theWeightConverted)
            
            //the height
            
            //feet
            theHeight = (Double(userHeightFt) ?? 0.0) * 12
            
            //inches
            theHeight = theHeight + (Double(userHeightIn) ?? 0.0)
            
            //converted to cm
            theHeight = theHeight * 2.54
            
            theHeight = (4.799 * theHeight)
            
            //the age
            theAge = (Double(userAge) ?? 0.0) * 5.677
            
            
            //adding it together
            theBMR = theConstantMale + theWeight + theHeight - theAge
            theBMRInt = Int(theBMR)
            
            theDef = theBMRInt - 300
            
            updateGoalForDef()
            
            resultTitle = "Your BMR is: " + (String(theBMRInt)) + " calories"
            
            userWorkoutStr  = "500"
            
            
            updateGoalForDef()
            

            
            workoutTitle = "Calories burned during daily workout: "
            
            userWorkout = Int(userWorkoutStr) ?? 0
            
            showIt = true
            
            
            
            print(theBMRInt)
            
            
            
            
        } else if(selection == "Female") {
            //the weight
            theWeight = (9.247 * theWeightConverted)
            
            //the height
            
            //feet
            theHeight = (Double(userHeightFt) ?? 0.0) * 12
            
            //inches
            theHeight = theHeight + (Double(userHeightIn) ?? 0.0)
            
            //converted to cm
            theHeight = theHeight * 2.54
            
            theHeight = (3.098 * theHeight)
            
            //the age
            theAge = (Double(userAge) ?? 0.0) * 4.330
            
            
            //adding it together
            theBMR = theConstantFemale + theWeight + theHeight - theAge
            
            theBMRInt = Int(theBMR)
            
            theDef = theBMRInt - 300
            
            updateGoalForDef()
            
            resultTitle = "Your BMR is: " + (String(theBMRInt)) + " calories"
            
            userWorkoutStr  = "500"
            
            
            updateGoalForDef()
            

            
            workoutTitle = "Calories burned during daily workout: "
            
            userWorkout = Int(userWorkoutStr) ?? 0
            
            showIt = true
            
            
            
            print(theBMRInt)
       
            
        }
        
        
    }
    
    var body: some View {
        ZStack {
            CustomColor.lgColor.ignoresSafeArea() // 1
            VStack {
                HStack {
                    Text("BMR Calculator").font(.title).bold()
                    
                    
                    
                }.onAppear() {
                    getPastGoalOG()
                    getPastRemOG()
                }
                
                VStack {
        
                    
                    Picker("", selection: $selection) {
                        ForEach(genders, id: \.self) {
                            Text($0).font(.title2)
                        }
                    }
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(Color.blue, lineWidth: 3)
                    ).onChange(of: selection) { newValue in
                        // Perform any actions or updates when selection changes
                        findUserBMR()
                    }
                    
                }
                .padding(.bottom)
            
        
                
                
                TextField("Height (Feet)", text: Binding(
                    get: { userHeightFt },
                    set: { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        self.userHeightFt = filtered
                        if showIt {
                            findUserBMR()
                        }
                    }
                ))
                .textFieldStyle(MyTextFieldStyle())
                .padding(.bottom)

                TextField("Height (Inches)", text: Binding(
                    get: { userHeightIn },
                    set: { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        self.userHeightIn = filtered
                        if showIt {
                            findUserBMR()
                        }
                    }
                ))
                .textFieldStyle(MyTextFieldStyle())
                .padding(.bottom)

                TextField("Weight (Pounds)", text: Binding(
                    get: { userWeightLB },
                    set: { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        self.userWeightLB = filtered
                        if showIt {
                            findUserBMR()
                        }
                    }
                ))
                .textFieldStyle(MyTextFieldStyle())
                .padding(.bottom)
                
                
                //4
                TextField("Age", text: Binding(
                    get: { userAge },
                    set: { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        self.userAge = filtered
                        if showIt {
                            findUserBMR()
                        }
                    }
                ))
                .textFieldStyle(MyTextFieldStyle())
                .padding(.bottom)
                
                
                
                Button(action: {
                    //findUserBMR()
                    
                    if(userHeightFt == "" || userHeightIn == ""
                       || userWeightLB == "" || userAge == "") {
                        showAlert = true
                        
                    } else {
                        findUserBMR()
                    }
                }) {
                    
                    
                    Text("Calculate")
                        .fontWeight(.semibold)
                        .font(.title3).padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(CustomColor.limeColor)
                        .cornerRadius(25)
                }
                
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Missing Values Detected"),
                              message: Text("Make sure to fill out all fields"),
                              dismissButton: .cancel(Text("Dismiss"), action: {
                                    // do something when dismissed
                                }))
                     }
                
                if showIt {
                    
                    VStack {
                        HStack {
                            Text(resultTitle).font(.title2)
                            
                            NavigationLink(destination: InfoFormulaView()) {
                                Image(systemName: "questionmark.circle") .foregroundColor(.gray)
                            }
                            Spacer()
                            
                        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        
                        
                        HStack {
                            Text("Calories burned in daily workout:")
                                .font(.subheadline) .lineLimit(1)
                            
                            
                            Spacer()
                            
                            TextField("", text: Binding(
                                get: { userWorkoutStr },
                                set: { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    self.userWorkoutStr = filtered
                                    updateGoalForDef()
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 90)
                            .truncationMode(.tail)
                            
                        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Desired Deficit (300 recommended):").font(.subheadline) .lineLimit(1)
                            
                            Spacer()
                            
                            
                            TextField("", text: Binding(
                                get: { userDefStr },
                                set: { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    self.userDefStr = filtered
                                    updateGoalForDef()
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 90)
                            .truncationMode(.tail)
                            
                        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Text("Calorie Goal: \(theBMRInt) + \(userWorkoutStr) - \(userDefStr) = \(resultFinalGoal)").font(.subheadline).bold().frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        
                        Button(action: {
                            
                            updateRem()
                            
                            
                        }
                        ) {
                            
                            Text("Save daily calorie goal of: \(resultFinalGoal)")
                                .fontWeight(.semibold)
                                .font(.subheadline).padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(40)
                        }.padding(.bottom)
                            .padding(.trailing)
                            .padding(.leading)
                        
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                
                
                Spacer()
              
            }.padding()
            
           
        }
        
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView()
    }
}


struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.cyan, lineWidth: 3)
                
        )
    }
}
