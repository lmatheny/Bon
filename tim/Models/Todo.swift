//
//  Todo.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import SwiftUI
struct Todo: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String?
    var name2: String?
}
