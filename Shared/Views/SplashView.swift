//
//  SplashView.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 11/03/2021.
//

import SwiftUI

struct SpalshView: View {
    @State var animate = false
    @State var endSplash = false
    
    var body: some View {
        ZStack {
            ContentView() //SO that its draws and preload the ContentView in the background
            
            ZStack {
                
                
                Color(.white) //So that it doesnt show what behind
                
                Image("HydrateLarge")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: animate ? .fill : .fit)
                    .frame(width: animate ? nil : 85, height: animate ? nil :  85)
                
                
                //Scalling view
                
                    .scaleEffect(animate ? 3 : 1)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
            }.ignoresSafeArea(.all, edges: .all)
            .onAppear(perform: animateSplash)
            //hiding view after finished
            .opacity(endSplash ? 0 : 1) //Make it "disappear where actually it is just invisible "
        }
        
        
    }
    func animateSplash() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { //When the view loads then do it
            
            withAnimation(Animation.easeOut(duration: 0.55)) {
                
                animate.toggle()
            }
            
            withAnimation(Animation.linear(duration: 0.45)) {
                
                endSplash.toggle()
            }
            
            
        }
    }
    
    
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SpalshView()
    }
}
