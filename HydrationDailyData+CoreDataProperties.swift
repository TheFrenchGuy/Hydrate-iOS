//
//  HydrationDailyData+CoreDataProperties.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 02/02/2021.
//
//

import Foundation
import CoreData


extension HydrationDailyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HydrationDailyData> {
        return NSFetchRequest<HydrationDailyData>(entityName: "HydrationDailyData")
    }

    @NSManaged public var amountDrank: Int64
    @NSManaged public var forDate: Date?
    @NSManaged public var id: UUID?

}

extension HydrationDailyData : Identifiable {
    public static func fetchAllItems() ->NSFetchRequest<HydrationDailyData> //Requered to fetch all of the item from memory
    {
        let request:NSFetchRequest<HydrationDailyData> = NSFetchRequest<HydrationDailyData>(entityName: "HydrationDailyData") //Defines what to request and what is the name of the entiyy also defined in the xcdatamodelID
        request.shouldRefreshRefetchedObjects = true
        
        let sortDescriptor = NSSortDescriptor(key: "forDate", ascending: false) //In what way the data is sorted

        request.sortDescriptors = [sortDescriptor]
        return request //Returns the request so that it can be processed
    }
}
