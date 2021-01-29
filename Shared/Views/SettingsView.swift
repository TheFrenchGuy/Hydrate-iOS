//
//  SettingsView.swift
//  Hydrate
//
//  Created by Noe De La Croix on 28/01/2021.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
