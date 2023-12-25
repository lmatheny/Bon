import SwiftUI

struct Exercise: Codable, Identifiable {
    var name: String?
    var name2: String?
    var name4: String?
    var name5: String?
    var name6: String
    var name7: String?
    var name8: String?
    var name9: String?
    var name10: String?
    var plan: String?
 
    
    var id: String {
        return name6
    }
}

