//
//  HydrateApp.swift
//  Shared
//
//  Created by Noe De La Croix on 27/01/2021.
//

import SwiftUI
import CoreData
@main
struct HydrateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension Color { //Few more needed colors to follow scheme
    static let lightblue = Color(red: 23.0 / 255, green: 156.0 / 255, blue: 233.0 / 255)
    static let lightred = Color(red: 237.0 / 255, green: 63.0 / 255, blue: 62.0 / 255)
}
