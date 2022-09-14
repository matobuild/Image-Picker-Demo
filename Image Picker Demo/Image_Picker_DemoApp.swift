//
//  Image_Picker_DemoApp.swift
//  Image Picker Demo
//
//  Created by kittawat phuangsombat on 2022/9/13.
//

import SwiftUI
import Firebase

@main
struct Image_Picker_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        FirebaseApp.configure()
    }
}
