//
//  timApp.swift
//  tim
//
//  Created by Luke Matheny on 7/3/23.
//

import SwiftUI
import Firebase


@main
struct timApp: App {
 
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
  
    
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}
