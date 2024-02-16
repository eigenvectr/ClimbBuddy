//
//  TimerListView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/14/24.
//
import SwiftUI
struct TimerListView: View{
    
    @StateObject var vm = TimerViewModel()
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(color.appBGColor)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
            ZStack{
                color.appBGColor
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(spacing:15){
                            // Add timers here
                        }.padding(.top,10)
                    }
                }
                .background(color.appBGColor)
                .navigationTitle("My Timers")
                .navigationBarItems(
                    trailing:
                        NavigationLink {
                            // Add functionality for adding/editing timers
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 28,height: 28)
                                .background(color.appThemeColor)
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }
                )
            }
        }

    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    struct TimerListView_Previews: PreviewProvider {
        static var previews: some View {
            TimerListView()
        }
    }
}
