//
//  CountdownView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/6/24.
//

import SwiftUI

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


struct CountdownView: View{
    
    @StateObject private var vm = ViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let width: Double = 250
    var body: some View{
        ZStack{
            color.appBGColor
                    .ignoresSafeArea()
            VStack{
                Text("\(vm.time)")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .padding()
                    .frame(width: width)
                    .background(.thinMaterial)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 4))
                    .alert("Timer done!", isPresented: $vm.showingAlert) {
                        Button("Continue", role: .cancel){
                            // Add functionality here
                        }
                    }
                
                Slider(value: $vm.minutes, in: 1...10, step: 1)
                    .padding()
                    .frame(width: width)
                    .disabled(vm.isActive)
                    .animation(.easeInOut, value: vm.minutes)
                
                HStack(spacing:50){
                    Button("Start"){
                        vm.start(minutes: vm.minutes)
                    }.disabled(vm.isActive)
                    
                    Button("Reset", action: vm.reset)
                        .tint(.red)
                }
                
            }
        }
        .onReceive(timer) { _ in
            vm.updateCountDown()
        }
    }
}

struct CountdownView_Previews: PreviewProvider{
    static var previews: some View{
        CountdownView()
    }
}
