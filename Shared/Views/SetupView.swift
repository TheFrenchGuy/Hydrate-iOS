//
//  SetupView.swift
//  Hydrate
//
//  Created by Noe De La Croix on 28/01/2021.
//

import SwiftUI
import Combine
import CoreHaptics

struct SetupView: View {

    @State var weight: String = ""
    @State var hours: String = ""
    @State private var engine: CHHapticEngine?
    @State var showAlert = false
    @State var firstMinY: CGFloat = 0
    @ObservedObject var userSettings = UserSettings()
    @State var completion:Bool? = false
    
    // Stoping Bounces On SCrollView...
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    @State var minY: CGFloat = 0
    @State var lastMinY: CGFloat = 0
    @State var scale : CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0){
            if completion == true {
                CompletionView()
            }
            else {
                ScrollView{
                    
                    // Top Sticky View...
                    StickyView(firstMinY: $firstMinY,minY: $minY,lastMinY: $lastMinY,scale: $scale)
                    
                    VStack(alignment: .leading, spacing: 15, content: {
                        
                        VStack() {
                                Text("Lets calculate how much you need to drink")
                                        .foregroundColor(.black)
                                        .font(.system(size: 24, weight: .semibold, design: .default))
                                            Spacer()
                                            Text("Enter your weight").animation(.easeIn).frame(width: 250, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading ).padding(.trailing, 80)
                                            VStack {

                                                HStack {
                                                Image(systemName: "mount")
                                                TextField("Body Weight (with or without shoes)", text: self.$weight) //Input the rough amount eaten of the product
                                                .keyboardType(.numberPad)
                                                    .onReceive(Just(self.weight)) { newValue in //Filteres so only numbers can be inputed
                                                        let filtered = newValue.filter { "0123456789".contains($0) } //It can only contains numbers
                                                        if filtered != newValue {
                                                            
                                                            withAnimation(.spring()){self.weight = filtered}
                                                        }
                                                }
                                                Text("kg")
                                                }.padding()
                                                .background(RoundedRectangle(cornerRadius: 30).stroke(self.weight != "" ? Color.lightblue : Color(.black),lineWidth: 2)) //Changes the color when the user inputs into  the text field
                                                .frame(width: UIScreen.main.bounds.size.width - 40)
                                                    .onTapGesture {
                                                        self.hideKeyboard()
                                                }
                                            }
                                            
                                            
                                            Text("How many hours of sports do you do weekly").animation(.easeIn).frame(width: 250, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading ).padding(.trailing, 80)
                                            VStack {

                                                HStack {
                                                Image(systemName: "clock")
                                                TextField("Hours", text: self.$hours) //Input the rough amount eaten of the product
                                                .keyboardType(.numberPad)
                                                    .onReceive(Just(self.hours)) { newValue in //Filteres so only numbers can be inputed
                                                        let filtered = newValue.filter { "0123456789".contains($0) } //It can only contains numbers
                                                        if filtered != newValue {
                                                            withAnimation(.spring()){ self.hours = filtered }
                                                        }
                                                }
                                                Text("hr")
                                                }.padding()
                                                .background(RoundedRectangle(cornerRadius: 30).stroke(self.hours != "" ? Color.lightblue : Color(.black),lineWidth: 2)) //Changes the color when the user inputs into  the text field
                                                .frame(width: UIScreen.main.bounds.size.width - 40)
                                                    .onTapGesture {
                                                        self.hideKeyboard()
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            
                                            
                                                if self.weight != ""  && self.hours != "" {
                                                    VStack(alignment: .trailing) {
                                                        
                                                        Button(action:{
                                                            withAnimation(.spring()) {
                                                                userSettings.waterintakedaily = waterintake(weight: self.weight, hours: self.hours)
                                                                userSettings.weight = Double(weight) ?? 1.0
                                                                userSettings.exerciseweekly = Double(hours) ?? 0.0
                                                                completion?.toggle()
                                                                //UserDefaults.standard.set(false, forKey: "didnotsetup") // This means that the user is logging in the first time so he must complete the daily intake calculator
                                                                //NotificationCenter.default.post(name: NSNotification.Name("didnotsetup"), object: nil) //Put a backend notification to inform app the data has been written
                                                            }
                                                        }) {
                                                            Image(systemName: "arrow.forward.circle")
                                                                .font(.system(size: 65))
                                                                .padding(.top, 60)
                                                                .foregroundColor(.lightblue)
                                                        }
                                                    }.animation(.easeIn)
                                                } else {
                                                VStack(alignment: .trailing) {
                                                    
                                                    Button(action: {
                                                        self.showAlert.toggle()
                                                    }) {
                                                        Image(systemName: "arrow.forward.circle")
                                                            .font(.system(size: 65))
                                                            .padding(.top, 60)
                                                            .foregroundColor(.black)
                                                            
                                                        
                                                    }.onAppear(perform: prepareHaptics)
                                                    .alert(isPresented: self.$showAlert, content: {
                                                        Alert(title: Text("Hydrate"), message: Text("Please fill in all your information"), dismissButton: .default(Text("Ok"), action: complexSuccess))
                                                        
                                                    }).onAppear(perform: complexSuccess)
                                                    
                                                }.animation(.easeIn)
                                            }
                                        
                                    }
                    })
                    .padding()
                    // since were moving view up...
                    .padding(.bottom,lastMinY)
                    .background(Color.white)
                    .offset(y: scale > 0.4 ? minY : lastMinY)
                    .opacity(scale < 0.3 ? 1 : 0)
                }
            }
        }
            .ignoresSafeArea(.all, edges: .top)
            .background(Color("Color").ignoresSafeArea(.all, edges: .all))
        
    }
    
    func prepareHaptics() { //Needed in order to warm up the device
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func waterintake(weight: String, hours: String) -> Double {
        let hourstominutes = (Double(hours) ?? 0) * 60
        let restingLitres = (Double(weight) ?? 0) * (0.04346551772)
        let workoutLitres = (hourstominutes / 7) * (0.01182937429)
        let total = restingLitres + workoutLitres
        userSettings.waterintakedaily = total
        return total
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}


struct CompletionView: View { //Wont be displayed to the user instead it will be used to reload the content view
    @ObservedObject var userSettings = UserSettings()
    var body: some View {
        VStack {
        Text("\(userSettings.exerciseweekly)")
        Text("\(userSettings.weight)")
        Text("\(userSettings.waterintakedaily)")
        }.onAppear(perform: {
            UserDefaults.standard.set(false, forKey: "didnotsetup") // This means that the user is logging in the first time so he must complete the daily intake calculator
            NotificationCenter.default.post(name: NSNotification.Name("didnotsetup"), object: nil) //Put a backend notification to inform app the data has been written
        })
            
    }
}



#if canImport(UIKit)
extension View {
    func hideKeyboard() { //In order to hide the  keyboard when the user has finished typing
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension View{
    
    func getScreen()->CGRect{
        
        return UIScreen.main.bounds
    }
}
