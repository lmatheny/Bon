//
//  CreatorPost.swift
//  tim
//
//  Created by Luke Matheny on 1/18/24.
//

import Foundation

//
//  Goal.swift
//  tim
//
//  Created by Luke Matheny on 7/4/23.
//

import SwiftUI
struct CreatorPost: Codable, Identifiable {
    var id: String = UUID().uuidString
    var caption: String?
    var date: String?
    var likes: String?
    var location: String?
    var theID: String?

}

