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
            // Setting endDate to the future
            self.endDate = Calendar.current.date(byAdding: .second, value: Int(minutes * 60), to: Date())!
            // Update the UI immediately when starting
            updateCountDown()
        }
    
    func reset(){
        self.minutes = Float(initialTime)
        self.isActive = false
        self.time = "\(Int(minutes)):00"
    }
    
    func updateCountDown(){
        guard isActive else {return}
        let now = Date()
        let diff = endDate.timeIntervalSince(now)
        
        if diff <= 0 {
            self.isActive = false
            self.time = "00:00"
            self.showingAlert = true
            return
        }
        
        // Use seconds to calculate both minutes and seconds
        let totalSeconds = Int(diff)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        // Updated to ensure both minutes and seconds are displayed as two digits
        self.time = String(format: "%02d:%02d", minutes, seconds)
    }
}


struct CountdownView: View{
    
    @StateObject private var vm = ViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let presetTimes: [Int] = [30, 60, 90, 120, 150, 180]
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Assuming the background is black for your app
            VStack(spacing: 30) { // Adjust spacing as needed
                Text(vm.time)
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                // Grid for the buttons
                let columns = [
                    GridItem(.flexible(minimum: 10)),
                    GridItem(.flexible(minimum: 10))
                ]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(presetTimes, id: \.self) { seconds in
                        Button(action: {
                            vm.start(minutes: Float(seconds) / 60)
                        }) {
                            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .semibold))
                                .frame(width: 150, height: 80) // Adjust size as needed
                                .background(Color.gray.opacity(0.5)) // Adjust opacity as needed
                                .cornerRadius(20)
                        }
                        .disabled(vm.isActive)
                    }
                }
                // Reset button
                Button("Reset") {
                    vm.reset()
                }
                .foregroundColor(.white)
                .font(.system(size: 25, weight: .semibold))
                .frame(width: 300, height: 80) // Adjust size as needed
                .background(Color.red) // Assuming Reset button is red
                .cornerRadius(20)
            }
            .padding()
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
