//
//  Goal.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import SwiftUI
struct Food: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String?
    var name2: String?
    var name3: String?
    var name4: String?
}

