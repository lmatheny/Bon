//
//  InfoCalDiff.swift
//  tim
//
//  Created by Luke Matheny on 12/27/23.
//

import SwiftUI

struct InfoCalDiff: View {
    var body: some View {
        Text("BMR ± calorie difference = GOAL") .font(.system(size: 20)).bold().padding(.top).frame(minWidth: 0, maxWidth: .infinity, alignment: .center).foregroundColor(CustomColor.limeColor)
        
        
        VStack(alignment: .leading, spacing: 0) {
            Text("BMR:")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(CustomColor.limeColor)
                .padding(.top, 10)
            Text("The amount of calories your body naturally burns throughout the day")
                .font(.system(size: 17.5))
                .bold()
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.trailing)
        
        VStack(alignment: .leading, spacing: 0) {
            Text("When Cutting:")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(CustomColor.limeColor)
                .padding(.top, 10)
            Text("A difference goal of 300 means users with a BMR of 2000 should consume 1700 calories a day")
                .font(.system(size: 17.5))
                .bold()
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.trailing)
        
        
        VStack(alignment: .leading, spacing: 0) {
            Text("When Bulking:")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(CustomColor.limeColor)
                .padding(.top, 10)
            Text("A difference goal of 300 means users with a BMR of 2000 should consume 2300 calories a day")
                .font(.system(size: 17.5))
                .bold()
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.trailing)
        
        
        
        
        Text("BONUS TIP").font(.system(size: 20)).bold().padding(2)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center).foregroundColor(.blue)
        
        Text("There are 3500 calories in a pound. So a daily 500 calorie deficit equals one pound of weight loss per week").font(.system(size: 17.5)).padding(.trailing).padding(.leading).frame(minWidth: 0, maxWidth: .infinity, alignment: .center).bold()
        
        Spacer()
    }

}

struct InfoCalDiff_Previews: PreviewProvider {
    static var previews: some View {
        InfoCalDiff()
    }
}
