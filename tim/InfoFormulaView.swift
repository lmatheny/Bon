//
//  InfoFormulaView.swift
//  tim
//
//  Created by Luke Matheny on 7/16/23.
//

import SwiftUI

struct InfoFormulaView: View {
    var body: some View {
        VStack {
          
            Text("BMR + EXCERISE - DEFICIT = GOAL") .font(.system(size: 20)).bold().padding(.top).frame(minWidth: 0, maxWidth: .infinity, alignment: .center).foregroundColor(CustomColor.limeColor)
            
            
            
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
                Text("Excercise calories:")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(CustomColor.limeColor)
                    .padding(.top, 10)
                Text("The additional amount of calories you burn during your daily workout")
                    .font(.system(size: 17.5))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.trailing)
            
           
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Desired deficit:")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(CustomColor.limeColor)
                    .padding(.top, 10)
                Text("The amount of calories you want to be below your total daily calories burned")
                    .font(.system(size: 17.5))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.trailing)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Calories goal:")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(CustomColor.limeColor)
                    .padding(.top, 10)
                Text("Eating an amount equal to total calories burned minus your deficit goal leads to a daily weight loss of the chosen calorie deficit!")
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
}

struct InfoFormulaView_Previews: PreviewProvider {
    static var previews: some View {
        InfoFormulaView()
    }
}
