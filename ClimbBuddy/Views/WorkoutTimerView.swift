//
//  WorkoutTimerView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/23/24.
//

import Foundation
import SwiftUI

struct WorkoutTimerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var vm: TimerViewModel
    
    @State var lblTimer: String = ""
    @State var lblElapsed: String = ""
    @State var lblRemaining: String = ""
    
    @State var myTimer: MyTimer
    
    @State  var countdownTimer      : Timer?
    
    @State var durations           : [String] = []
    @State var totalDurationSec    : Int = 0
    @State var currentDurationIndex: Int = 0
    @State var totalSeconds        : Int = 0
    @State var secondsRemaining    : Int = 0
    @State var isTimerRunning      : Bool = false
    
    @State var currentSetsIndex: Int = 0
    
    @State var playPausename: String = "ic_play"
    
    @State var isButtonDisabled = false
    
    @State private var workoutComplete = false

    
    var body: some View {
        VStack{
            VStack(spacing:20){
                topBar()
                
                Text(lblTimer)
                    .font(.custom(CustomFont.bold, size: 110))
                    .foregroundColor(color.appThemeColor)
                
                HStack{
                    VStack(spacing:5){
                        Text(lblElapsed)
                            .font(.custom(CustomFont.medium, size: 25))
                        Text("Elapsed")
                            .font(.custom(CustomFont.light, size: 15))
                            .foregroundColor(Color.white.opacity(0.5))
                    }.frame(width: (dSize.width / 3) - 10)
                    
                    Spacer()
                    
                    VStack(spacing:5){
                        HStack(spacing:2){
                            Text("\(self.currentSetsIndex + 1)")
                                .foregroundColor(color.appThemeColor)
                                .font(.custom(CustomFont.semiBold, size: 25))
                            Text("/")
                                .font(.custom(CustomFont.medium, size: 25))
                            Text("\(myTimer.numberOfSets)")
                                .font(.custom(CustomFont.medium, size: 25))
                        }
                        Text("Sets")
                            .font(.custom(CustomFont.light, size: 15))
                            .foregroundColor(Color.white.opacity(0.5))
                    }.frame(width: (dSize.width / 3) - 10)
                    
                    Spacer()
                    
                    VStack(spacing:5){
                        Text(String(format: "%02d:%02d", totalDurationSec / 60, totalDurationSec % 60))
                            .font(.custom(CustomFont.medium, size: 25))
                        Text("Remaining")
                            .font(.custom(CustomFont.light, size: 15))
                            .foregroundColor(Color.white.opacity(0.5))
                    }.frame(width: (dSize.width / 3) - 10)
                }
                
                ScrollViewReader { reder in
                    
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(spacing:15){
                            ForEach(myTimer.exercises.indices, id: \.self){ index in
                                let i = myTimer.exercises[index]
                                cardView(i, index: index)
                                    .id(index)
                            }
                        }.padding(.bottom,50)
                    }
                    .onChange(of: currentDurationIndex){ newValue in
                        withAnimation(.spring()){
                            reder.scrollTo(currentDurationIndex, anchor: .top)
                        }
                    }
                    .disabled(isButtonDisabled)
                }
            }.padding()
                .overlay(alignment: .bottom){
                    HStack{
                        Button(action: {
                            stopTimer()
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 20,height: 20)
                                .scaledToFit()
                        })
                        .padding(.leading,25)
                        .disabled(isButtonDisabled)
                        Spacer()
                        Button(action: {
                            isButtonDisabled.toggle()
                        }, label: {
                            Image(isButtonDisabled ? "ic_lockclos" :"ic_lockOpen")
                                .resizable()
                                .frame(width: 20,height: 20)
                                .scaledToFit()
                        })
                        Spacer()
                        Button(action: {
                            getAllDuration()
                            currentSetsIndex = 0
                            resetTimer()
                        }, label: {
                            Image("ic_refresh")
                                .resizable()
                                .frame(width: 20,height: 20)
                                .scaledToFit()
                        })
                        .disabled(isButtonDisabled)
                        Spacer()
                        Button(action: {
                            if isTimerRunning {
                                pauseTimer()
                                self.playPausename = "ic_play"
                            } else {
                                startTimer()
                                self.playPausename = "ic_pause"
                            }
                        }, label: {
                            Image(playPausename)
                                .resizable()
                                .frame(width: 20,height: 20)
                                .scaledToFit()
                        })
                        .padding(.trailing,25)
                        .disabled(isButtonDisabled)
                    }
                    .frame(maxWidth: .infinity,minHeight: 50)
                    .background(color.appCardColor)
                    .cornerRadius(15)
                    .padding(.horizontal,25)
                    .padding(.bottom,5)
                    .shadow(color: .black.opacity(0.2), radius: 5,x: 1,y: 1)
                }
        }
        .background(color.appBGColor)
        .foregroundColor(Color.white)
        .navigationBarHidden(true)
        .alert(isPresented: $workoutComplete) {
                    Alert(
                        title: Text("Workout Complete!"),
                        message: Text("Congratulations, you have completed your workout! 👏👏👏"),
                        dismissButton: .default(Text("OK")) {
                        }
                    )
                }
        .onAppear{
            getAllDuration()
            if !durations.isEmpty {
                setTotalTime(duration: durations[currentDurationIndex])
            }
        }
    }
    func topBar()-> some View {
        HStack{
            Button(action: {
                stopTimer()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20,height: 15)
            }).disabled(isButtonDisabled)
            
            Spacer()
            
            Text("Workout Timer")
                .font(.custom(CustomFont.bold, size: 20))
            
            Spacer()
        }
    }
    
    func cardView(_ item: MyExercise,index:Int) -> some View {
        HStack{
            Text(item.name)
                .font(.custom(CustomFont.semiBold, size: 25))
                .padding(.leading,10)
            
            Spacer()
            
            Text(item.duration)
                .font(.custom(CustomFont.regular, size: 50))
                .padding(.trailing,10)
        }
        .frame(maxWidth: .infinity,minHeight: 90)
        .background(self.currentDurationIndex == index ? color.appThemeColor : color.appCardColor)
        .cornerRadius(15)
    }
    
    func getAllDuration() {
        self.durations = []
        for i in myTimer.exercises {
            self.durations.append(i.duration)
        }
        
        self.totalDurationSec = sumDurationsInSeconds(durations)
    }
    
    func setTotalTime(duration: String) {
        let components = duration.components(separatedBy: ":")
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Int(components[1]) {
            totalSeconds = minutes * 60 + seconds
            secondsRemaining = totalSeconds
            updateTimerLabels()
        }
    }
    
    func updateTimerLabels() {
        let remainingMinutes = secondsRemaining / 60
        let remainingSeconds = secondsRemaining % 60
        let elapsedMinutes = (totalSeconds - secondsRemaining) / 60
        let elapsedSeconds = (totalSeconds - secondsRemaining) % 60
        
        self.lblTimer = (String(format: "%02d:%02d", remainingMinutes, remainingSeconds))
        self.lblElapsed = (String(format: "%02d:%02d", elapsedMinutes, elapsedSeconds))
    }
    
    func pauseTimer() {
        stopTimer()
    }
    
    func startTimer() {
        if isTimerRunning {
            return
        }
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // Code to be executed on each timer tick
            updateTimer()
        }
        
        isTimerRunning = true
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
        isTimerRunning = false
    }
    
    func updateTimer() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            updateTimerLabels()
            self.totalDurationSec -= 1
        } else {
            // Timer for the current duration has finished
            stopTimer()
            
            if currentDurationIndex < durations.count - 1 {
                // Move to the next duration
                currentDurationIndex += 1
                setTotalTime(duration: durations[currentDurationIndex])
                startTimer()
            } else {
                resetTimer()
                
                if  currentSetsIndex < (Int(myTimer.numberOfSets) ?? 1) - 1 {
                    currentSetsIndex += 1
                    startTimer()
                    self.playPausename = "ic_pause"
                    getAllDuration()
                }
                else {
                    workoutComplete = true
                    currentSetsIndex = 0
                    getAllDuration()
                }
            }
        }
    }
    
    func resetTimer() {
        stopTimer()
        currentDurationIndex = 0
        setTotalTime(duration: durations[currentDurationIndex])
        isTimerRunning = false
        self.playPausename = "ic_play"
        updateTimerLabels()
    }
}

struct WorkoutTimerView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTimerView(myTimer: MyTimer())
    }
}
