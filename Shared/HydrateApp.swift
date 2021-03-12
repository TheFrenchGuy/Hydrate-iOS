//
//  HydrateApp.swift
//  Shared
//
//  Created by Noe De La Croix on 27/01/2021.
//

import SwiftUI
import CoreData
import Foundation
@main
struct HydrateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SpalshView().environment(\.managedObjectContext, persistenceController.container.viewContext) //SO that it show the Splash loading animation
        }
    }
}

extension Color { //Few more needed colors to follow scheme
    public static let lightblue:Color = Color(hexString: "#179ce9") //Color(red: 23.0 / 255, green: 156.0 / 255, blue: 233.0 / 255)
    public static let lightred = Color(red: 237.0 / 255, green: 63.0 / 255, blue: 62.0 / 255)
    public static let Blu:Color = Color(hexString: "#227aff")
    
    public static let barbipink:Color = Color(hexString: "#ff29a0")
    public static let reddish:Color = Color(hexString: "#ff2828")
}


extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
