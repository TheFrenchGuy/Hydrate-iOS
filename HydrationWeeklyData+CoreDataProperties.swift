//
//  HydrationWeeklyData+CoreDataProperties.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 02/02/2021.
//
//

import Foundation
import CoreData


extension HydrationWeeklyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HydrationWeeklyData> {
        return NSFetchRequest<HydrationWeeklyData>(entityName: "HydrationWeeklyData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var dailyamountdrank: Int64

}

extension HydrationWeeklyData : Identifiable {
    public static func fetchAllItems() ->NSFetchRequest<HydrationWeeklyData> //Requered to fetch all of the item from memory
    {
        let request:NSFetchRequest<HydrationWeeklyData> = NSFetchRequest<HydrationWeeklyData>(entityName: "HydrationWeeklyData") //Defines what to request and what is the name of the entiyy also defined in the xcdatamodelID
        request.shouldRefreshRefetchedObjects = true
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) //In what way the data is sorted

        request.sortDescriptors = [sortDescriptor]
        return request //Returns the request so that it can be processed
    }
}
