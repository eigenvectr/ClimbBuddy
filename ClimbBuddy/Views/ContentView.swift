//
//  ContentView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 1/23/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView{
            CountdownView()
                .tabItem { 
                    Image(systemName: "arrow.down.right.and.arrow.up.left.circle")
                    Text("Countdown")
                }
        }
    }
}

#Preview {
    ContentView()
}
