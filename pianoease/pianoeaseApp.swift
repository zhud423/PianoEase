//
//  pianoeaseApp.swift
//  pianoease
//
//  Created by zhudong on 7/8/26.
//

import SwiftUI
import SwiftData

@main
struct pianoeaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PracticeSessionModel.self, MeasureStatModel.self])
    }
}
