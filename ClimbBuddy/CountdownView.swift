//
//  CountdownView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/6/24.
//

import Foundation

extension ContentView{
    final class ViewModel: ObservableObject {
        @Published var isActive = false
        @Published var showingAlert = false
        @Published var time: String = "1:00"
        @Published var minutes: Float = 1.0 {
            didSet{
                self.time = "\(Int(minutes)):00"
            }
        }
        private var initialTime = 0
        private var endDate = Date()
        
        func start(minutes: Float){
            self.initialTime = Int(minutes)
            self.endDate = Date()
            self.isActive = true
            self.endDate = Calendar.current.date(byAdding: .minute, value: Int(minutes), to: endDate)!
        }
        
        func reset(){
            self.minutes = Float(initialTime)
            self.isActive = false
            self.time = "\(Int(minutes)):00"
        }
        
        func updateCountDown(){
            guard isActive else {return}
            let now = Date()
            let diff = endDate.timeIntervalSince1970 - now.timeIntervalSince1970
            
            if diff <= 0 {
                self.isActive = false
                self.time = "0:00"
                self.showingAlert = true
                return
            }
            
            let date = Date(timeIntervalSince1970: diff)
            let calender = Calendar.current
            let minutes = calender.component(.minute, from: date)
            let seconds = calender.component(.second, from: date)
            
            self.minutes = Float(minutes)
            self.time = String(format: "%d:%.02d", minutes, seconds)
        }
    }
}
