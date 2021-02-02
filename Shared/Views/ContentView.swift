//
//  ContentView.swift
//  Shared
//
//  Created by Noe De La Croix on 27/01/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var didnotsetup = UserDefaults.standard.value(forKey: "didnotsetup") as? Bool ?? true //Wethever the user is logged in
    @State var changeOccured = UserDefaults.standard.value(forKey: "changeOccured") as? Bool ?? false //Wethever the user has adjusted values
    @State var presentSheet = false
    @State var waterAddSheet = false
    @ObservedObject var userSettings = UserSettings()
    @State var weight = UserSettings().weight
    @State var exerciseweekly = UserSettings().exerciseweekly
    @State var test = ""
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
                            SettingsView(isPresented: self.$presentSheet)
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
                    
                    UserDefaults.standard.set(false, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
                    NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                        print("Redirecting to Reload View")
                    
                    self.test = "updated "
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
                            SettingsView(isPresented: self.$presentSheet)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                    
                    VStack() {
                        Text("Add x ml of water to your daily intake").foregroundColor(.lightblue)
                        Text(test)
                        Button(action: {
                            self.waterAddSheet = true
                        }) {
                            Image(systemName: "plus.app")
                                .font(.system(size: 54))
                        }.sheet(isPresented: self.$waterAddSheet) {
                            AddWaterView(isShown: self.$waterAddSheet)
                        }
                        
                        
                        //Text("\(userSettings.waterintakedaily) L")
                        //Text("\(exerciseweekly)")
                        
                        UserSettingsValues()
                        
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "didnotsetup") // This means that the user is logging in the first time so he must complete the daily intake calculator
                            NotificationCenter.default.post(name: NSNotification.Name("didnotsetup"), object: nil) //Put a backend notification to inform app the data has been written
                        }) {
                            Text("Reset")
                                .foregroundColor(.black)
                        }

                    }
                    
                    Spacer()
                }.onAppear(perform: { // So that the timer resest automatically at midnight
                    let timediff = Int(Date().timeIntervalSince(self.userSettings.startDrinkTime))
                    if timediff >= 86400 {
                        self.AddToWeekly()
                        self.userSettings.firstDrinkDay = true
                        self.userSettings.startDrinkTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                        self.userSettings.drankToday = 0
                        print("timedifference is more than a day")
                        self.test = "timedifference is more than a day"
                        UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
                        NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                            print("Redirecting to Reload View")
                        
                        
                    }
                })
            }
            
            
            
        }.onTapGesture {
            
        }
        .background(Color.white)
        
        
        .onAppear {
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
    
    func AddToWeekly() {
        let i = HydrationDailyData(context: viewContext)

        i.id = UUID()
        i.forDate = userSettings.startDrinkTime
        i.amountDrank = Int64(userSettings.drankToday)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func waterintake() {
        let hourstominutes = (Double(userSettings.exerciseweekly) ) * 60
        let restingLitres = (Double(userSettings.weight) ) * (0.04346551772)
        let workoutLitres = (hourstominutes / 7) * (0.01182937429)
        let total = restingLitres + workoutLitres
        userSettings.waterintakedaily = total
        
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
    var body: some View {
        
        Button(action: {
            userSettings.startDrinkTime = (Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()))!
        }) {
            Text("Time")
        }
        Text("\(userSettings.exerciseweekly)")
        Text("\(userSettings.weight)")
        Text("\(userSettings.waterintakedaily)")
        Text("\(userSettings.startDrinkTime)")
        Text("\(Date())")
        Text("\(userSettings.drankToday)")
        
        

    }
}
