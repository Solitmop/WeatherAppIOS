//
//  WeatherAppIOSApp.swift
//  WeatherAppIOS
//
//  Created by Sergey on 24.09.2026.
//

import SwiftUI

@main
struct WeatherAppIOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
