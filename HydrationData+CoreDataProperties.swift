//
//  HydrationData+CoreDataProperties.swift
//  Hydrate
//
//  Created by Noe De La Croix on 01/02/2021.
//
//

import Foundation
import CoreData


extension HydrationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HydrationData> {
        return NSFetchRequest<HydrationData>(entityName: "HydrationData")
    }

    @NSManaged public var amountDrank: Int64
    @NSManaged public var beverage: String
    @NSManaged public var dailyAmountDrank: Int64
    @NSManaged public var dateIntake: Date
    @NSManaged public var id: UUID
    
    
    var beverageType: Beverage {
        set {
            beverage = newValue.rawValue
        }
        get {
            Beverage(rawValue: beverage) ?? .water
        }
    }

}

extension HydrationData : Identifiable {
    public static func fetchAllItems() ->NSFetchRequest<HydrationData> //Requered to fetch all of the item from memory
    {
        let request:NSFetchRequest<HydrationData> = NSFetchRequest<HydrationData>(entityName: "HydrationData") //Defines what to request and what is the name of the entiyy also defined in the xcdatamodelID
        request.shouldRefreshRefetchedObjects = true
        
        let sortDescriptor = NSSortDescriptor(key: "dateIntake", ascending: false) //In what way the data is sorted

        request.sortDescriptors = [sortDescriptor]
        return request //Returns the request so that it can be processed
    }
}


enum Beverage: String {
    case water = "Water"
    case coffee = "Coffee"
    case tea = "Tea"
    case milk = "Milk"
    case beer = "Beer"
    case other = "Other"
}
