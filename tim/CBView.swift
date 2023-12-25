//
//  CBView.swift
//  tim
//
//  Created by Luke Matheny on 7/30/23.
//

import SwiftUI

struct CBView: View {
    @State private var showIt = false
    @State private var userHeightFt: String = ""

    
    var body: some View {
        
        
        VStack {
            HStack {
                Text("Budget Calculator").font(.title).bold().padding()
                
                
                
            }.onAppear() {
                //getPastGoalOG()
               // getPastRemOG()
            }
            
        
            
            
            
            
            TextField("Monthly Budget", text: Binding(
                get: { userHeightFt },
                set: { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    self.userHeightFt = filtered
                    if showIt {
                       // findUserBMR()
                    }
                }
            ))
            .textFieldStyle(MyTextFieldStyle())
            .padding()
            
            Spacer()
        }
    }
}

struct CBView_Previews: PreviewProvider {
    static var previews: some View {
        CBView()
    }
}


