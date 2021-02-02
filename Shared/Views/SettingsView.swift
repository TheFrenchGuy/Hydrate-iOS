//
//  SettingsView.swift
//  Hydrate
//
//  Created by Noe De La Croix on 28/01/2021.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var userSettings = UserSettings()
    @State var newWeight = 0.0 //If changing the weight will be temporary stored into this value
    @State var newWorkout = 0.0 //If changing the workout hour will be temporary stored into this value
    @State var newNotificationTiming: Int32 = 0 //If changing the notificationResend will be temporary stored into this value
    @State var newCupSize: Int32 = 1000 //Chaning Default cup size
    @State var size: CGSize = .zero ///Needed to align all the rows correctly
    @State var changeOccured = UserDefaults.standard.value(forKey: "changeOccured") as? Bool ?? false //Wethever the user has adjusted values
    @State var showEmailAlert = false ///Show the email address when user promps alert
    @State var showCalendar = false ///Show the Past data calendar to the user
    var format = "%g"
    var body: some View {
            ZStack {
                GeometryReader { bounds in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center) {
                            Text("Hey \(Autofiller().guessNameOfDeviceOwner(name: Autofiller.NameComponent.fullNameInCurrentPersonNameComponentsFormatterStyle))").font(.title).bold()
                                .frame(width: bounds.size.width, alignment: .leading)
                                .padding()
                                .padding(.leading, 30)
                                .padding(.top, 60)
                                //.padding(.bottom, 10)
                        LottieView(filename: "SettingsLottie", speed: 1, loop: .loop)
                            .frame(width: bounds.size.width  * 0.4, height: bounds.size.height * 0.2, alignment: .center)
                            .padding(.top, -40)
                        
                        
                        Text("Settings").font(.subheadline).frame(width: bounds.size.width, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(.gray)
                        
                        
                            GeometryReader() { geometry in
                            ZStack {
                                RoundedRectangle(cornerRadius: 15).stroke(Color.lightblue, lineWidth: 6)
                                
                                VStack() {
                                    HStack() {
                                        Stepper("Did you lose weight? ", value: $newWeight, in: 40...130)
                                        Text("\(self.newWeight, specifier: format)kg").frame(width: self.size.width, height: self.size.height)
                                    }.padding(.bottom, 10)
                                    //.padding(.top, 10)
                                    
                                    HStack() {
                                        Stepper("Working out more?", value: $newWorkout, in: 0...24)
                                        Text("\(self.newWorkout, specifier: format)hr").frame(width: self.size.width, height: self.size.height)
                                    }.padding(.bottom, 10)
                                    .padding(.top, 10)
                                    
                                    HStack() {
                                        Stepper("What your water cup size?", value: $newCupSize, in: 100...1500, step: 25)
                                        Text("\(self.newCupSize)ml").frame(width: self.size.width, height: self.size.height)
                                    }.padding(.top, 10)
                                    .padding(.bottom, 10)
                                    HStack() {
                                        Stepper("How often should you be reminded to drink water?", value: $newNotificationTiming, in: 15...3600, step: 15)
                                        Text("\(self.newNotificationTiming)min").frame(width: 70)
                                            .background( GeometryReader { proxy in
                                                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
                                            })

                                    }//.padding(.bottom, 10)
                                    .padding(.top, 10)
                                    
                                    
                                    
                                }.frame(width: geometry.size.width - 25)
                            }
                        }.frame(width: bounds.size.width - 20,height: size.height * 14)
                        .padding(.bottom, 30)
                            
                        Text("Your previous drinking data").font(.subheadline).frame(width: bounds.size.width, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(.gray)
                            
                        GeometryReader() { geometry in
                            ZStack() {
                                 RoundedRectangle(cornerRadius: 15).stroke(Color.lightred, lineWidth: 6)
                                Button(action: {
                                    self.showCalendar.toggle()
                                }){
                                    HStack {
                                     Text("Press here to search through previous day data")
                                        Image(systemName: "calendar")
                                    }.frame(width: geometry.size.width - 25).foregroundColor(.black)
                                }.sheet(isPresented: self.$showCalendar) { PastDataView()}
                            }
                        }.frame(width: bounds.size.width - 20,height: size.height * 3).padding(.bottom, 30)
                            
                            
                        Text("Misc").font(.subheadline).frame(width: bounds.size.width, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(.gray)
                            
                        GeometryReader() { geometry in
                            ZStack() {
                                RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 6)
                                Button(action: {
                                    self.showEmailAlert = true //Triggers an alert to be shown on the screen
                                }) {
                                    HStack {
                                     Text("Error or feature request?")
                                        Image(systemName: "captions.bubble")
                                    }.frame(width: geometry.size.width - 25).foregroundColor(.black)
                                }.alert(isPresented: self.$showEmailAlert) {
                                    Alert(title: Text("FoodyScan Feedback"), message: Text("Please send an email to noedelacroix@protonmail.com"),primaryButton: .default(Text("Copy Email Address"), action: {
                                        UIPasteboard.general.string = "noedelacroix@protonmail.com"
                                    }), secondaryButton: .default(Text("Okay"))) //Copies to clipboard my email address so user can send feedback
                            }
                            }
                        }.frame(width: bounds.size.width - 20,height: size.height * 3).padding(.bottom, 30)
                            
                            Button(action: {
                                //Add later when all the permsions have been asked
                            }) {
                                Text("Terms and Conditions").font(.footnote).padding(.bottom, 30)
                            }
                        Spacer()
                            
                            
                        
                            
                            

                        
                        
                        }.frame(width: UIScreen.main.bounds.width)
                    }
                   
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }.onAppear(perform: { //Retrieve the stored value
                self.newWeight = userSettings.weight
                self.newNotificationTiming = userSettings.notificationTime
                self.newWorkout = userSettings.exerciseweekly
                self.newCupSize = userSettings.cupSize
                print("Data loaded") //debug only
                
            })
            .onPreferenceChange(SizePreferenceKey.self) { preferences in
                self.size = preferences //stores the value of the sise of text into CGSize
                
            }
        
            .onDisappear(perform: {
                
                if self.newWeight != userSettings.weight || self.newNotificationTiming != userSettings.notificationTime || self.newWorkout != userSettings.exerciseweekly || self.newCupSize != userSettings.cupSize  { ///If any of the values are changed then will save new values
                    self.userSettings.weight = self.newWeight
                    self.userSettings.exerciseweekly = self.newWorkout
                    self.userSettings.notificationTime = self.newNotificationTiming
                    self.userSettings.cupSize = self.newCupSize
                    waterintake()
                    UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
                    NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                    print("New Data saved")
                } else {
                    print("Data has not been changed")
                }
            })
    }
    struct SizePreferenceKey: PreferenceKey { ///Reference to https://stackoverflow.com/questions/56573373/swiftui-get-size-of-child //to get the size of the child
        typealias Value = CGSize
        static var defaultValue: Value = .zero

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }

    
    func waterintake() { //Recalculate the new value
        let hourstominutes = (Double(self.newWorkout) ) * 60
        let restingLitres = (Double(self.newWeight) ) * (0.04346551772)
        let workoutLitres = (hourstominutes / 7) * (0.01182937429)
        let total = restingLitres + workoutLitres
        userSettings.waterintakedaily = total
        
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}

struct PastDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var userSettings = UserSettings()
    @FetchRequest(fetchRequest: HydrationData.fetchAllItems()) var hydrationData: FetchedResults<HydrationData> //Fetches the coredate product stacks
    @State var date: Date = Date()
    var body: some View {
        
        VStack {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            List() {
                ForEach(hydrationData) { hydration in
                    let timediff = Int(self.date.timeIntervalSince(hydration.dateIntake))
                    if timediff <= 86400 && timediff >= 0 {
                        HStack {
                            Text("\(hydration.amountDrank)")
                            Text("\(hydration.dateIntake)")
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
}
