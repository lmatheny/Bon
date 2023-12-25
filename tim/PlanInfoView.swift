//
//  PlanInfoView.swift
//  tim
//
//  Created by Luke Matheny on 12/22/23.
//

import SwiftUI

struct PlanInfoView: View {
    let unique: String
    
    var body: some View {
        Text("Plan Info for \(unique)")
            .padding()
    }
}

struct PlanInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PlanInfoView(unique: "TestUnique")
    }
}

