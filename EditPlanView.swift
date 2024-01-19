//
//  EditPlanView.swift
//  tim
//
//  Created by Luke Matheny on 1/16/24.
//

import SwiftUI

struct EditPlanView: View {
    let unique: String
    let verified: String
    
    var body: some View {
        Text(unique)
    }
}

struct EditPlanView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlanView(unique: "TestUnique", verified: "no")
    }
}
