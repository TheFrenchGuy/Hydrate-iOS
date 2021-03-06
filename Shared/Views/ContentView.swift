//
//  ContentView.swift
//  Shared
//
//  Created by Noe De La Croix on 27/01/2021.
//

import SwiftUI
import CoreData
import AVFoundation
import Combine


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContexts
    @State var didnotsetup = UserDefaults.standard.value(forKey: "didnotsetup") as? Bool ?? true //Wethever the user is logged in
    @State var changeOccured = UserDefaults.standard.value(forKey: "changeOccured") as? Bool ?? false //Wethever the user has adjusted values
    @State var presentSheet = false
    @State var waterAddSheet = false
    @ObservedObject var userSettings = UserSettings()
    @State var weight = UserSettings().weight
    @State var exerciseweekly = UserSettings().exerciseweekly
    @State var date: Date = (Calendar.current.date(bySettingHour: 0, minute: 0, second: 0 , of: Date())!)
    @State var totalDayDrank: [Int] = []
    
    @State var percentagedrank: Double = 0.0
    
    
    @State var audioPlayer: AVAudioPlayer!
    var body: some View {
        ZStack {
            if self.didnotsetup { //First boot up initiziale setup
                VStack {
                    HStack(alignment: .top) {
                        
                        Button(action: {
                            if self.didnotsetup {
                                self.presentSheet = true
                            }
                        }) {
                            Image("HydrateIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60, alignment: .center)
                        }.sheet(isPresented: $presentSheet){
                            SettingsView(isPresented: self.$presentSheet, howTotalDrank: self.$totalDayDrank)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                    
                    VStack() {
                        Text("Add x ml of water to your daily intake").foregroundColor(.lightblue)
                        Image(systemName: "plus.app")
                        
                    }
                    
                    
                    
                    Spacer()
                }
                .sheet(isPresented: self.$didnotsetup ){
                    SetupView()
                        .modifier(DisableModalDismiss(disabled: true))
                }
            }
            
            if self.changeOccured { //Makes the UI refresh when a changed has occured
                Text("Reloading").onAppear(perform: {
                    withAnimation() { //Plays water splash sound when adding or changing settings for the water 
                        playSounds("WaterPoor.mp3")
                    }
                    AmountDrankDaily()
                    UserDefaults.standard.set(false, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
                    NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                        print("Reloaded")
                    
                })
                
            }
            else {
            Color.white.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack(alignment: .top) {
                        
                        Button(action: {
                            self.presentSheet = true
                        }) {
                            Image("HydrateIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60, alignment: .center)
                        }.sheet(isPresented: $presentSheet){
                            SettingsView(isPresented: self.$presentSheet, howTotalDrank: self.$totalDayDrank)
                        }
                        
                        Spacer()
                    }.zIndex(2)
                    Spacer()
                        VStack(alignment: .center) {
                            VStack {
                                Button(action: {
                                    self.waterAddSheet = true

                                }) {
                                    LinearGradient(gradient: Gradient(colors: [.lightblue, .Blu]), startPoint: .leading, endPoint: .trailing)
                                        .mask(Image(systemName: "plus.app").font(.system(size: 84)))
                                        
                                }.sheet(isPresented: self.$waterAddSheet) {
                                    AddWaterView(isShown: self.$waterAddSheet, test: self.$totalDayDrank)
                                }

                                Text("Add your drink").foregroundColor(.gray)
                            }.zIndex(1)
                            
                            WaterDropView().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .center)
                            
                            UserSettingsValues(amountDrank: self.$totalDayDrank )
                            
                        }.frame(width: UIScreen.main.bounds.width, alignment: .center)
                        
                    
                    
                    Spacer()
                }.onAppear(perform: { // So that the timer resest automatically at midnight
                    let timediff = Int(Date().timeIntervalSince(self.userSettings.startDrinkTime))
                    if timediff >= 86400 {
//                        self.AddToWeekly()
                        self.userSettings.firstDrinkDay = true
                        self.userSettings.percentageDrank = 0
                        self.userSettings.startDrinkTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
//                        self.userSettings.drankToday = 0
                        print("timedifference is more than a day")
                       
//                        UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
//                        NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
//                            print("Redirecting to Reload View")
                        
                        
                    }
                })
            }
            
            
            
        }.padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .onTapGesture {
            
        }
        .background(Color.white)
        
        
        .onAppear {
           
            AmountDrankDaily()
            scheduleNotifications() //In order to scheduleNotificaitons
            waterintake() //Incase of
         //Looks for if the value has changes so it can change the view
            
             NotificationCenter.default.addObserver(forName: NSNotification.Name("didnotsetup"), object: nil, queue: .main) { (_) in
                 
                 self.didnotsetup = UserDefaults.standard.value(forKey: "didnotsetup") as? Bool ?? true
             }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("changeOccured"), object: nil, queue: .main) { (_) in
                
                self.changeOccured = UserDefaults.standard.value(forKey: "changeOccured") as? Bool ?? false
            }
            //Necesarry to check changes on the view when loading
            
//            if userSettings.firstDrinkDay {
//                userSettings.startDrinkTime = (Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()))!
//            }
            //let day: TimeInterval = 86400
            
        
        }
        
    }
    
    func scheduleNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Success")
                  //To add badgeNumber
                  //UIApplication.shared.applicationIconBadgeNumber = badgeNumber (Integer Value)
                  
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            let content = UNMutableNotificationContent()
            content.title = "Dont forget to drink 💧"
            content.body = "Dont forget to log it"
            content.sound = UNNotificationSound.default
        let timing:TimeInterval = TimeInterval(userSettings.notificationTime * 60) //So that it can be changed by the user in the settings
            print(timing)
//            var dateComponents = DateComponents()
//            dateComponents.hour = 11
//            dateComponents.minute = 59
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timing, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
    }
    func AmountDrankDaily() {
        
        var viewContext: NSManagedObjectContext { PersistenceController.shared.container.viewContext } //remove error from '+entityForName: nil is not a legal NSManagedObjectContext parameter searching for entity name
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "HydrationData")
        self.totalDayDrank.removeAll()
        
        do {
            let result = try viewContext.fetch(req)
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
                           }
            }

        } catch {
            print(error.localizedDescription)
        }
    }
//    func AddToWeekly() {
//        let i = HydrationDailyData(context: viewContext)
//
//        i.id = UUID()
//        i.forDate = userSettings.startDrinkTime
////        i.amountDrank = Int64(userSettings.drankToday)
//        do {
//            try viewContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//
//    }
    
    func waterintake() {
        let hourstominutes = (Double(userSettings.exerciseweekly) ) * 60
        let restingLitres = (Double(userSettings.weight) ) * (0.04346551772)
        let workoutLitres = (hourstominutes / 7) * (0.01182937429)
        let total = restingLitres + workoutLitres
        userSettings.waterintakedaily = total
        
    }
    
    func playSounds(_ soundFileName : String) {
            guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
                fatalError("Unable to find \(soundFileName) in bundle")
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print(error.localizedDescription)
            }
        audioPlayer.play()
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .light).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension UIApplication { //Neccesary for the view sheet so that it cannot be dismissed
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }

    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

struct DisableModalDismiss: ViewModifier { //So in the setup view the sheet cannot be dismissed
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }

    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
    }
}

struct UserSettingsValues: View { //Debug only in case somnething goes wrong
    @ObservedObject var userSettings = UserSettings()
    @Binding var amountDrank: [Int]
    var body: some View {
        VStack {
            Text("\(userSettings.percentageDrank * 100, specifier: "%g")%").font(.largeTitle).bold()
            Text("You drank \(amountDrank.reduce(0, +)) ml of fluid so far").font(.headline).foregroundColor(.gray)
            Text("\(userSettings.waterintakedaily)").font(.footnote)
        }.onAppear(perform: {print("AmountDrank Int \(self.amountDrank) ")})
        

    }
    
    
}

struct WaterDropView: View {
    @ObservedObject var userSettings = UserSettings()
    var body: some View {
        GeometryReader() { geometry in
        ZStack() {
            Image("HydrateIcon").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
            
                ZStack {
                    Circle().foregroundColor(.white).frame(width: geometry.size.width , height: geometry.size.height , alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).offset(x: 0, y: -(geometry.size.width * 0.19))
                }.offset(x: 0, y: -(geometry.size.width * CGFloat(userSettings.percentageDrank) * 0.62)).zIndex(1)
            }.frame(width: geometry.size.width, height: geometry.size.width)
        }
        
    }
    
}


