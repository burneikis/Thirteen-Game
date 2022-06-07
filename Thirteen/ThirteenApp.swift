//
//  ThirteenApp.swift
//  Thirteen
//
//  Created by Alexander Burneikis on 7/6/2022.
//

import SwiftUI

@main
struct ThirteenApp: App {
    init() {
            UserDefaults.standard.register(defaults: [
                "highScore": 0
            ])
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
