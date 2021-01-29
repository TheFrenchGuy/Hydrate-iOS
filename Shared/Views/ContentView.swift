//
//  ContentView.swift
//  Shared
//
//  Created by Noe De La Croix on 27/01/2021.
//

import SwiftUI

struct ContentView: View {
    @State var didnotsetup = UserDefaults.standard.value(forKey: "didnotsetup") as? Bool ?? true //Wethever the user is logged in
    @State var presentSheet = false
    @ObservedObject var userSettings = UserSettings()
    @State var weight = UserSettings().weight
    @State var exerciseweekly = UserSettings().exerciseweekly
    var body: some View {
        ZStack {
            if self.didnotsetup {
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
                        Image(systemName: "plus.app")
                        
                    }
                    
                    
                    
                    Spacer()
                }
                .sheet(isPresented: self.$didnotsetup ){
                    SetupView()
                        .modifier(DisableModalDismiss(disabled: true))
                }
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
                        Image(systemName: "plus.app")
                        
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
                }
            }
            
            
            
        }.onTapGesture {
            
        }
        .background(Color.white)
        
        
        .onAppear {
         //Looks for if the value has changes so it can change the view
             NotificationCenter.default.addObserver(forName: NSNotification.Name("didnotsetup"), object: nil, queue: .main) { (_) in
                 
                 self.didnotsetup = UserDefaults.standard.value(forKey: "didnotsetup") as? Bool ?? true
             }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .light)
    }
}

extension UIApplication {

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

struct DisableModalDismiss: ViewModifier {
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

struct UserSettingsValues: View {
    @ObservedObject var userSettings = UserSettings()
    var body: some View {
        Text("\(userSettings.exerciseweekly)")
        Text("\(userSettings.weight)")
        Text("\(userSettings.waterintakedaily)")
    }
}
