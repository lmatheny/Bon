//
//  CurrentPlans.swift
//  tim
//
//  Created by Luke Matheny on 12/22/23.
//

import Foundation
import SwiftUI

struct CurrentPlans: Identifiable {
    let display: String
    let unique: String
    var creator: String
    var fav: String
    
    var id: String { unique }
}
