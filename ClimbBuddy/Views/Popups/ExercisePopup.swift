//
//  ExercisePopup.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/23/24.
//

import Foundation
import SwiftUI

struct ExercisePopup: View {
    
    @Binding var show: Bool
    
    @Binding var myExercise:[MyExercise]
    
    @State var exerciseName: String = ""
    
    @State var time: Date = Date()
    
    @State var selectedMinutes = 0
    
    @State var selectedSeconds = 0
    
    @State var editExercise: MyExercise
    @State var comeFrom: Action
    
    var body: some View{
        
        ZStack{
            
            color.appBGColor.opacity(0.3)
                .ignoresSafeArea()
            
            
            VStack{
                VStack(spacing: 25){
                    HStack{
                        Button(action: {show = false}, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 20,height: 20)
                        })
                        
                        Spacer()
                        
                        Text("Add Exercises")
                            .font(.custom(CustomFont.semiBold, size: 18))
                        Spacer()
                    }
                    VStack(spacing:15){
                        HStack{
                            Text("Name")
                                .font(.custom(CustomFont.semiBold, size: 15))
                                .padding(.leading)
                            
                            TextField("Enter Name", text: $exerciseName)
                                .multilineTextAlignment(.trailing)
                                .padding(.trailing)
                        }
                        .frame(height: 45)
                        .background(color.appBGColor)
                        .cornerRadius(15)
                        
                        
                        HStack{
                            Text("Time")
                                .font(.custom(CustomFont.semiBold, size: 15))
                                .padding(.leading)
                            
                            Spacer()
                            
                            HStack(spacing:0) {
                                Picker("Minutes", selection: $selectedMinutes) {
                                    ForEach(0 ..< 60) { minute in
                                        Text("\(minute) min")
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 100)
                                
                                Picker("Seconds", selection: $selectedSeconds) {
                                    ForEach(0 ..< 60) { second in
                                        Text("\(second) sec")
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 100)
                            }.preferredColorScheme(.dark)
                                .clipped()
                        }
                        .frame(height: 45)
                        .background(color.appBGColor)
                        .cornerRadius(15)
                        
                    }
                    
                    Button(action: {
                        
                        let exer = MyExercise(name: self.exerciseName,duration: String(format: "%02d:%02d", self.selectedMinutes, self.selectedSeconds))
                        
                        if self.comeFrom == .edit {
                            if let index = myExercise.firstIndex(where: { $0.id == editExercise.id }) {
                                self.myExercise[index] = exer
                            }
                        } else{
                            self.myExercise.append(exer)
                        }
                        self.show = false
                    }, label: {
                        ZStack{
                            color.appThemeColor
                                .cornerRadius(15)
                            Text("Done")
                                .font(.custom(CustomFont.semiBold, size: 15))
                        }.frame(width: 166,height: 40)
                    })
                }.padding(.horizontal)
            }.frame(maxWidth: .infinity,minHeight: 255)
                .background(color.appCardColor)
                .shadow(color: .black.opacity(0.2), radius: 5,x: 1,y: 1)
                .cornerRadius(15)
                .padding()
        }.foregroundColor(.white)
            .onAppear{
                self.exerciseName = editExercise.name
                let components = editExercise.duration.components(separatedBy: ":")
                if components.count == 2, let minutes = Int(components[0]), let seconds = Int(components[1]) {
                    self.selectedMinutes = minutes
                    self.selectedSeconds = seconds
                }
            }
    }
}
