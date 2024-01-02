//
//  Plan.swift
//  tim
//
//  Created by Luke Matheny on 12/31/23.
//

import SwiftUI
struct Plan: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String?
 
}
