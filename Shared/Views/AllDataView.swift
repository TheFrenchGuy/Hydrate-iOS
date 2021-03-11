//
//  AllDataView.swift
//  Hydrate
//
//  Created by Noe De La Croix on 11/03/2021.
//

import SwiftUI

struct AllDataView: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @ObservedObject var userSettings = UserSettings()
        @FetchRequest(fetchRequest: HydrationData.fetchAllItems()) var hydrationData: FetchedResults<HydrationData> //Fetches the coredate product stacks
        @State var changeOccured = UserDefaults.standard.value(forKey: "changeOccured") as? Bool ?? false //Wethever the user has adjusted values
        @Binding var howTotalDrank: [Int]
    
        var dateFormatter: DateFormatter { //Used in order to format the date so it is not too long for the screen
            let formatter = DateFormatter()
            formatter.dateStyle = .long //What is the size of the date
            return formatter
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("All of the data collected").font(.title).bold().padding()
            List {
                ForEach(hydrationData) { hydration in
                        HStack {
                            Text("\(hydration.amountDrank)")
                            Text("\(hydration.dateIntake)")
                            Text("\(hydration.beverage)")
                    }
                }
                .onDelete { indexSet  in
                        for index in indexSet {
                            viewContext.delete(hydrationData[index])

                        }
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }

                    }

            }
        }.onAppear(perform: { //Retrieve the stored value
            print("Data loaded") //debug only
            UserDefaults.standard.set(false, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
            NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
            
        })
        
        .onDisappear(perform: {
            UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
            NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
            howMuchDrank(drank: self.howTotalDrank.reduce(0,+))
            print("New Data saved")
        })
    }
    
   
}

//struct AllDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllDataView()
//    }
//}
