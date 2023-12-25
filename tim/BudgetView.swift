//
//  BudgetView.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import SwiftUI

struct BudgetView: View {
    
    @State public var currentWeek = ""
    @State public var currentWeekInt = 200
    
    @State public var currentRem = ""
    @State public var currentRemInt = 200
    
    var body: some View {
        VStack {
            
            
            
            HStack {
                Text("Remaining Funds: $\(currentRemInt)").bold() .font(.system(size: 25))
                
//                Button(action: {
//                  
//                }, label: {Label("", systemImage: "pencil.circle")
//                        .foregroundColor(CustomColor.limeColor).bold()
//                })
            } .frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.leading)
            
            HStack {
                Text("Weekly Budget: $\(currentWeekInt) ").bold() .font(.system(size: 25))
                
                Button(action: {
                  
                }, label: {Label("", systemImage: "pencil.circle")
                        .foregroundColor(CustomColor.limeColor).bold()
                })
            } .frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.leading)
            
//            NavigationLink(destination:  CBView()) {
//                Text("Calculate weekly budget").foregroundColor(.blue)
//                    .font(.system(size: 15))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading)
//            }.frame(maxWidth: .infinity, maxHeight: 7.5, alignment: .leading)
            
            
            
            
            
            HStack {
                Text("View History").bold() .font(.system(size: 22.5))
                
                Button(action: {
                  
                }, label: {Label("", systemImage: "calendar.badge.clock")
                        .foregroundColor(.black).bold()
                })
            } .frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.leading)
            
            
            
            
            
            Spacer()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
    }
}
