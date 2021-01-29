//
//  UserSettingsModel.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 29/01/2021.
//

import Foundation
import Combine

class UserSettings: ObservableObject { //Class used to store user settings
    @Published var weight: Double {
        didSet {
            UserDefaults.standard.set(weight, forKey: "weight")
        }
    }
    
    @Published var exerciseweekly: Double {
        didSet {
            UserDefaults.standard.set(exerciseweekly, forKey: "exerciseweekly")
        }
    }
    
    @Published var waterintakedaily: Double {
        didSet {
            UserDefaults.standard.set(waterintakedaily, forKey: "waterintakedaily")
        }
    }
    
    init() {
        self.weight = UserDefaults.standard.object(forKey: "weight") as? Double ?? 1.0
        self.exerciseweekly = UserDefaults.standard.object(forKey: "exerciseweekly") as? Double ?? 0.0
        self.waterintakedaily = UserDefaults.standard.object(forKey: "waterintakedaily") as? Double ?? 1.0
    }
}
