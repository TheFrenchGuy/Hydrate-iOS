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
    
    @Published var notificationTime: Int32 {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    
    @Published var cupSize: Int32 {
        didSet {
            UserDefaults.standard.set(cupSize, forKey: "cupSize")
        }
    }
    
    @Published var firstDrinkDay: Bool {
        didSet {
            UserDefaults.standard.set(firstDrinkDay, forKey: "firstItemDay")
        }
    }
    
    @Published var startDrinkTime: Date {
        didSet {
            UserDefaults.standard.set(startDrinkTime, forKey: "startDrinkTime")
        }
    }
    
    @Published var drankToday: Int32 {
        didSet {
            UserDefaults.standard.set(drankToday, forKey: "drankToday")
        }
    }
    
    
    
    init() { //Initial the orignial value of the variables at inital startup
        self.weight = UserDefaults.standard.object(forKey: "weight") as? Double ?? 1.0
        self.exerciseweekly = UserDefaults.standard.object(forKey: "exerciseweekly") as? Double ?? 0.0
        self.waterintakedaily = UserDefaults.standard.object(forKey: "waterintakedaily") as? Double ?? 1.0
        self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Int32 ?? 15
        self.cupSize = UserDefaults.standard.object(forKey: "cupSize") as? Int32 ?? 200
        self.firstDrinkDay = UserDefaults.standard.object(forKey: "firstItemDay") as? Bool ?? true
        self.startDrinkTime = UserDefaults.standard.object(forKey: "startDrinkTime") as? Date ?? (Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()))!
        self.drankToday = UserDefaults.standard.object(forKey: "drankToday") as? Int32 ?? 0
    }
}
