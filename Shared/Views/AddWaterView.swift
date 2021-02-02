//
//  AddWaterView.swift
//  Hydrate
//
//  Created by Noe De La Croix on 01/02/2021.
//

import SwiftUI
import CoreData
import Combine
import AVFoundation

struct AddWaterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var userSettings = UserSettings()
    @Binding var isShown:Bool
    let beverageTypes = ["Water", "Coffee", "Tea", "Milk", "Beer", "Other"]
    @State var dateIntake  = Date()
    @State private var selectedBeverage = 0
    @State var amountDrank = "0"
    @State var cupDrank = 0
    
    @State var audioPlayer: AVAudioPlayer!
    var body: some View {

        NavigationView {
            ZStack {
                Color(#colorLiteral(red: 0.9489265084, green: 0.949085772, blue: 0.9704096913, alpha: 1)).edgesIgnoringSafeArea(.all)
                VStack {
                    Form {
                        Section(header: Text("Amount drank"),footer: Text("Tip: You can adjust your prefered cup size in the settings")) {
                            HStack {
                            Image(systemName: "clock")
                            TextField("How many millilitres", text: self.$amountDrank) //Input the rough amount eaten of the product
                            .keyboardType(.numberPad)
                                .onReceive(Just(self.amountDrank)) { newValue in //Filteres so only numbers can be inputed
                                    let filtered = newValue.filter { "0123456789".contains($0) } //It can only contains numbers
                                    if filtered != newValue {
                                        withAnimation(.spring()){ self.amountDrank = filtered }
                                    }
                            }
                            Text("ml")
                            }

                            HStack() {
                                Image(systemName: "gear")
                                Stepper("How many cups did you drink? \(cupDrank) cups", value: self.$cupDrank, in: 0...5)
                            }
                        }


                        Section(header: Text("Beverage")) {
                            Picker(selection: $selectedBeverage, label: Text("Drink Type")){
                                ForEach(0 ..< beverageTypes.count) {
                                    Text(self.beverageTypes[$0]).tag($0)
                                }
                            }
                        }


                        Button(action: {
                            withAnimation() {
                                playSounds("PooringWater.mp3")
                            }
                            AddToWaterIntake()
                            howMuchDrank()
                            waterintake()
                            print("added water to intake")
                        }) {
                            Text("Drank it")
                        }
                    }
                }
            }.navigationTitle("Water yourself")
        }

    }
    
    func waterintake() {
        let hourstominutes = (Double(userSettings.exerciseweekly) ) * 60
        let restingLitres = (Double(userSettings.weight) ) * (0.04346551772)
        let workoutLitres = (hourstominutes / 7) * (0.01182937429)
        let total = restingLitres + workoutLitres
        userSettings.waterintakedaily = total
        
    }
    func AddToWaterIntake() {
        let i = HydrationData(context: viewContext)
        let drankml = Int64(self.amountDrank)
        let cup = Int64(self.cupDrank)
        
        i.id = UUID()
        i.dateIntake = Date()
        i.beverage = self.beverageTypes[self.selectedBeverage]
        if drankml == 0 {
            print(cup)
            print(userSettings.cupSize)
            i.amountDrank = cup * Int64(UserSettings().cupSize)
           // i.dailyAmountDrank = i.dailyAmountDrank + i.amountDrank
            self.userSettings.drankToday += Int32(i.amountDrank)
        }
        
        
        else if drankml != 0 && cupDrank != 0 { //Case where there is both the fields filled in
            i.amountDrank = drankml ?? 0
          //  i.dailyAmountDrank = i.dailyAmountDrank + i.amountDrank
            self.userSettings.drankToday += Int32(i.amountDrank)
        }
       else {
            i.amountDrank = drankml ?? 0
          //  i.dailyAmountDrank = i.dailyAmountDrank + i.amountDrank
            self.userSettings.drankToday += Int32(i.amountDrank)
        }
        
        do {
                try viewContext.save()
                print("Water Saved.")
                withAnimation(.spring()) {
                    self.isShown = false
                }
                UserDefaults.standard.set(true, forKey: "changeOccured") // This means that the user is logging in the first time so he must complete the daily intake calculator
                NotificationCenter.default.post(name: NSNotification.Name("changeOccured"), object: nil) //Put a backend notification to inform app the data has been written
                    print("Redirecting to Reload View")
            } catch {
                print(error.localizedDescription)
            }




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

struct AddWaterView_Previews: PreviewProvider {
    static var previews: some View {
        AddWaterView(isShown: .constant(true))
    }
}
