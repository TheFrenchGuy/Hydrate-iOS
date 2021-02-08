//
//  PastDataView.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 03/02/2021.
//

import SwiftUI
import CoreData


class PastDataHour: ObservableObject {
    var midnight: Int = 0
    var oneam: Int = 0
    var twoam: Int = 0
    var threeam: Int = 0
    var fouram: Int = 0
    var fiveam: Int = 0
    var sixam: Int = 0
    var sevenam: Int = 0
    var eightam: Int = 0
    var nineam: Int = 0
    var tenam: Int = 0
    var elevenam: Int = 0
    var twelveam: Int = 0
    var onepm: Int = 0
    var twopm: Int = 0
    var threepm: Int = 0
    var fourpm: Int = 0
    var fivepm: Int = 0
    var sixpm: Int = 0
    var sevenpm: Int = 0
    var eightpm: Int = 0
    var ninepm: Int = 0
    var tenpm: Int = 0
    var elevenpm: Int = 0
    
}


struct PastDataView: View {
    @ObservedObject var pastDataHour = PastDataHour()
    @State var totalDayDrank: [Int] = []
    @State var totalHourDrank: [Int] = []
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var userSettings = UserSettings()
    @FetchRequest(fetchRequest: HydrationData.fetchAllItems()) var hydrationData: FetchedResults<HydrationData> //Fetches the coredate product stacks
    @FetchRequest(fetchRequest: HydrationDailyData.fetchAllItems()) var hydrationDailyData: FetchedResults<HydrationDailyData> //Fetches the coredate product stacks
    @State var date: Date = (Calendar.current.date(bySettingHour: 0, minute: 0, second: 0 , of: Date())!)
    @State var testArray: [Int] = []
    @State var iteration: Int = 1
    var body: some View {
        
        VStack {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            
            Text("\(date)")
            List() {
                ForEach(hydrationData) { hydration in
                    let dateIn = hydration.dateIntake
                    let timediff = Int(dateIn.timeIntervalSince(date))
                    if timediff <= 86400 && timediff >= 0 {
                        HStack {
                            Text("\(hydration.amountDrank)")
                            Text("\(hydration.dateIntake)")
                            Text("\(timediff)")
                        }
                    }
                    
                }.onDelete { indexSet  in
                    for index in indexSet {
                        viewContext.delete(hydrationData[index])
                        delete(hydrationData[index])
                        
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                .onChange(of: testArray) { rawValue in
                    self.GraphArray()
//                    print("Total array for day \(totalDayDrank.reduce(0, +))")
//                    print("Total per hour \(testArray)")
//                   print("count \(iteration)")
                }
                .onAppear() {
                    self.getHourDrank() //Will crash when being placed inside the foreeach loop

                     self.GraphArray()
                     print("Total array for day Appear \(totalDayDrank.reduce(0, +))")
                     print("Total per hour \(testArray)")
                    print("count \(iteration)")
                }
                
                
                
            }
            .onChange(of: date) { rawValue in
                //self.iteration = 0
                self.testArray.removeAll()
                self.getHourDrank() //Will crash when being placed inside the foreeach loop
//
//                self.GraphArray()
                 print("Total array for day Change\(totalDayDrank.reduce(0, +))")
                 print("Total per hour \(testArray)")
                print("count \(iteration)")
            }
            ScrollView(.horizontal) {
                HStack {
                
                    ForEach(testArray, id: \.self) {
                        data in
                        
                        BarView(value: CGFloat(data), cornerRadius: CGFloat(10))
                    }
                }
            }
            
            
                List(){
                    Text("Daily record")
                    ForEach(hydrationDailyData) { hydration in
                    HStack {
                        Text("\(hydration.amountDrank)")
                        Text("\(hydration.forDate!)")
                    }
                }
            }
        }
    }
    
    func delete(_ i:HydrationData) {
//        let timediff = Int(Date().timeIntervalSince(self.userSettings.startDrinkTime))
        let timediff = Int(self.userSettings.startDrinkTime.timeIntervalSince(i.dateIntake))
        print(timediff)
        if timediff <= 86400 {
            self.userSettings.drankToday -= Int32(i.amountDrank)
            UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
            NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                print("Redirecting to Reload View")
            
        } else {
            print("Nothing to delete since been more than a day")
        }
        
    }
    
    
    func getHourDrank() {
       // let persistenceController = PersistenceController.shared
        
        var viewContext: NSManagedObjectContext { PersistenceController.shared.container.viewContext } //remove error from '+entityForName: nil is not a legal NSManagedObjectContext parameter searching for entity name
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "HydrationData")
        
        do {
            let result = try viewContext.fetch(req)
            self.totalDayDrank.removeAll()
            self.testArray.removeAll()
            self.totalHourDrank.removeAll()
            //self.iteration += 1
            self.pastDataHour.midnight = 0 //Need to reset all the stored value in pastDataHour into 0 each time it is being run ///Could do into an other function that could be incoroporated inside it to be cleaner
            self.pastDataHour.oneam = 0
            self.pastDataHour.twoam = 0
            self.pastDataHour.threeam = 0
            self.pastDataHour.fouram = 0
            self.pastDataHour.fiveam = 0
            self.pastDataHour.sixam = 0
            self.pastDataHour.sevenam = 0
            self.pastDataHour.eightam = 0
            self.pastDataHour.nineam = 0
            self.pastDataHour.tenam = 0
            self.pastDataHour.elevenam = 0
            self.pastDataHour.twelveam = 0
            
            
            self.pastDataHour.onepm = 0
            self.pastDataHour.twopm = 0
            self.pastDataHour.threepm = 0
            self.pastDataHour.fourpm = 0
            self.pastDataHour.fivepm = 0
            self.pastDataHour.sixpm = 0
            self.pastDataHour.sevenpm = 0
            self.pastDataHour.eightpm = 0
            self.pastDataHour.ninepm = 0
            self.pastDataHour.tenpm = 0
            self.pastDataHour.elevenpm = 0
            
            for i in result as! [NSManagedObject] {
               // let id = i.value(forKey: "id") as! UUID
                let dateIntake = i.value(forKey: "dateIntake") as! Date
                //let dailyAmountDrank = i.value(forKey: "dailyAmountDrank") as! Int64
               // let beverage = i.value(forKey: "beverage") as! String
                let amountDrank = i.value(forKey: "amountDrank") as! Int64
                
                let timediff = Int(dateIntake.timeIntervalSince(self.date))
                if timediff < 86400 && timediff >= 0 {
                    self.totalDayDrank.append(Int(amountDrank))
                    print("Drank for today  \(totalDayDrank)")
                    
                    if timediff >= 0 && timediff < 3600 {
                       print("Drank at 0am")
                        let hour = Int(amountDrank)
                        print("let hour \(hour)")
                        self.pastDataHour.midnight += hour
                        print(self.pastDataHour.midnight)
                        
                    }
                    
                    else if timediff >= 3600 && timediff < 7200 {
                        print("Drank at 1am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.oneam += hour
                       print(self.pastDataHour.oneam)
                         
                    }
                    
                    else if timediff >= 7200 && timediff < 10800 {
                        print("Drank at 2am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.twoam += hour
                       print(self.pastDataHour.twoam)
                        
                    }
                    
                    else if timediff >= 10800 && timediff < 14400{
                        print("Drank at 3am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.threeam += hour
                       print(self.pastDataHour.threeam)
                         
                    }
                    
                    else if timediff >= 14400 && timediff < 18000 {
                        print("Drank at 4am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.fouram += hour
                       print(self.pastDataHour.fouram)
                         
                    }
                    
                    else if timediff >= 18000 && timediff < 21600 {
                        print("Drank at 5am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.fiveam += hour
                       print(self.pastDataHour.fiveam)
                         
                    }
                    
                    else if timediff >= 21600 && timediff < 25200 {
                        print("Drank at 6am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.sixam += hour
                       print(self.pastDataHour.sixam)
                        
                    }
                    
                    else if timediff >= 25200 && timediff < 28800 {
                        print("Drank at 7am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.sevenam += hour
                       print(self.pastDataHour.sevenam)
                        
                    }
                    
                    else if timediff >= 28800 && timediff < 32400 {
                        print("Drank at 8am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.eightam += hour
                       print(self.pastDataHour.eightam)
                        
                    }
                    
                    else if timediff >= 32400 && timediff < 36000 {
                        print("Drank at 9am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                        self.pastDataHour.nineam += hour
                       print(self.pastDataHour.nineam)
                        
                    }
                    
                    else if timediff >= 36000 && timediff < 39600 {
                        print("Drank at 10am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.tenam += hour
                       print(self.pastDataHour.tenam)
                         
                    }
                    
                    else if timediff >= 39600 && timediff < 43200 {
                        print("Drank at 11am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                        self.pastDataHour.elevenam += hour
                       print(self.pastDataHour.elevenam)
                        
                    }
                    
                    
                    else if timediff >= 43200 && timediff < 46800 {
                        print("Drank at 12am")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                        self.pastDataHour.twelveam += hour
                       print(self.pastDataHour.twelveam)
                        
                    }
                    
                    else if timediff >= 46800 && timediff < 50400 {
                        print("Drank at 1pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.onepm += hour
                       print(self.pastDataHour.onepm)
                            
                    }
                    
                    else if timediff >= 50400 && timediff < 54000 {
                        print("Drank at 2pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                        self.pastDataHour.twopm += hour
                       print(self.pastDataHour.twopm)
                         
                    }
                    
                    else if timediff >= 54000 && timediff < 57600 {
                        print("Drank at 3pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.threepm += hour
                       print(self.pastDataHour.threepm)
                         
                    }
                    
                    else if timediff >= 57600 && timediff < 61200 {
                        print("Drank at 4pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.fourpm += hour
                       print(self.pastDataHour.fourpm)
                         
                    }
                    
                    else if timediff >= 61200 && timediff < 64800 {
                        print("Drank at 5pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                        self.pastDataHour.fivepm += hour
                       print(self.pastDataHour.fivepm)
                         
                    }
                    
                    else if timediff >= 64800 && timediff < 68400 {
                        print("Drank at 6pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.sixpm += hour
                       print(self.pastDataHour.sixpm)
                        
                    }
                    
                    else if timediff >= 68400 && timediff < 72000 {
                        print("Drank at 7pm")
                         
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.sevenpm += hour
                       print(self.pastDataHour.sevenpm)
                        
                    }
                    
                    
                    else if timediff >= 72000 && timediff < 75600 {
                        print("Drank at 8pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.eightpm += hour
                       print(self.pastDataHour.eightpm)
                        
                    }
                    
                    else if timediff >= 75600 && timediff < 79200 {
                        print("Drank at 9pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.ninepm += hour
                       print(self.pastDataHour.ninepm)
                       
                    }
                    
                    else if timediff >= 79200 && timediff < 82800 {
                        print("Drank at 10pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.tenpm += hour
                       print(self.pastDataHour.tenpm)
                        
                    }
                    
                    else if timediff >= 82800 && timediff < 86400 {
                        print("Drank at 11pm")
                        let hour = Int(amountDrank)
                           print("let hour \(hour)")
                           self.pastDataHour.elevenpm += hour
                       print(self.pastDataHour.elevenpm)
                        
                         
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                   
                    
                }
                 self.GraphArray() //Is getting run x times and so is being multiplied.
            }
        } catch {
           print(error.localizedDescription)
        }
        
    }
    
    func GraphArray() {
        
        self.testArray.removeAll()
       // self.iteration += 1
        self.testArray.append(pastDataHour.midnight / self.iteration)
        self.testArray.append(pastDataHour.oneam / self.iteration)
        self.testArray.append(pastDataHour.twoam / self.iteration)
        self.testArray.append(pastDataHour.threeam / self.iteration)
        self.testArray.append(pastDataHour.fouram / self.iteration)
        self.testArray.append(pastDataHour.fiveam / self.iteration)
        self.testArray.append(pastDataHour.sixam / self.iteration)
        self.testArray.append(pastDataHour.sevenam / self.iteration)
        self.testArray.append(pastDataHour.eightam / self.iteration)
        self.testArray.append(pastDataHour.nineam / self.iteration)
        self.testArray.append(pastDataHour.tenam / self.iteration)
        self.testArray.append(pastDataHour.elevenam / self.iteration)
        self.testArray.append(pastDataHour.twelveam / self.iteration)
        
        self.testArray.append(pastDataHour.onepm / self.iteration)
        self.testArray.append(pastDataHour.twopm / self.iteration)
        self.testArray.append(pastDataHour.threepm / self.iteration)
        self.testArray.append(pastDataHour.fourpm / self.iteration)
        self.testArray.append(pastDataHour.fivepm / self.iteration)
        self.testArray.append(pastDataHour.sixpm / self.iteration)
        self.testArray.append(pastDataHour.sevenpm / self.iteration)
        self.testArray.append(pastDataHour.eightpm / self.iteration)
        self.testArray.append(pastDataHour.ninepm / self.iteration)
        self.testArray.append(pastDataHour.tenpm / self.iteration)
        self.testArray.append(pastDataHour.elevenpm / self.iteration)
    }
    

}

func sumArray(array_nums: [Int]) -> Int {
    var sum = 0
    var ans = true
    for x in 0..<array_nums.count
    {
        if array_nums[x] != 11 && ans == true {
            sum += array_nums[x]
            ans = true
        
        }
        else
        {
        ans = false
        }
       
    }
    
    return sum
}

struct PastDataView_Previews: PreviewProvider {
    static var previews: some View {
        PastDataView()
    }
}


struct BarView: View{

    var value: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        VStack {

            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 10, height: 200).foregroundColor(.black)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 10, height: value * 0.1).foregroundColor(.green)
                
            }.padding(.bottom, 8)
        }
        
    }
}
