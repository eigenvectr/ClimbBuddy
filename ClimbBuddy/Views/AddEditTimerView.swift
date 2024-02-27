//
//  AddEditTimerView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/23/24.
//

import Foundation
import SwiftUI

struct AddEditTimerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var vm: TimerViewModel
    
    @State var myTimer = MyTimer()
    
    @State var name: String = ""
    
    @State var numberOfSets: String = ""
    
    @State var comeFrom: Action
    
    @State var showAddexercisePopup: Bool = false
    
    @State var myExercises: [MyExercise] = []
    
    @State var currentExercise: MyExercise?
    
    @State var clipboard: [MyExercise] = []
    
    @State var selectedClipboard: [MyExercise] = []
    
    @State var goFrom : Action = .addNew
    @State var editExercise = MyExercise()
    
    @State var isTextVisible = false
    @State var visibleText = ""
    
    
    var body: some View {
        VStack{
            VStack(spacing:25){
                
                topBar()
                
                VStack(spacing:15){
                    HStack{
                        Text("Name")
                            .font(.custom(CustomFont.semiBold, size: 15))
                            .padding(.leading)
                        
                        TextField("Enter Name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                            .foregroundColor(Color.white)
                    }
                    .frame(height: 45)
                    .background(color.appCardColor)
                    .cornerRadius(15)
                    
                    HStack{
                        Text("Number Of Sets")
                            .font(.custom(CustomFont.semiBold, size: 15))
                            .padding(.leading)
                        
                        TextField("0", text: $numberOfSets)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .padding(.trailing)
                            .foregroundColor(Color.white)
                            .preferredColorScheme(.dark)
                    }
                    .frame(height: 45)
                    .background(color.appCardColor)
                    .cornerRadius(15)
                }
                HStack(spacing: 15){
                    Text("Add Exercises")
                        .font(.custom(CustomFont.bold, size: 20))
                    
                    Spacer()
                    
                    Button(action: {
                        for i in self.clipboard {
                            let exe = MyExercise(name:i.name,duration: i.duration)
                            myExercises.append(exe)
                        }
                    }, label: {
                        Image(systemName: "rectangle.fill.on.rectangle.fill")
                            .resizable()
                            .frame(width: 25,height: 25)
                            .foregroundColor(color.appThemeColor)
                    }).opacity(self.clipboard.isEmpty && selectedClipboard.isEmpty ? 0 : 1)
                    
                    
                    if !selectedClipboard.isEmpty {
                        
                        Button(action: {
                            self.isTextVisible = true
                            self.visibleText = "Copy"
                            self.clipboard = []
                            for i in selectedClipboard {
                                self.clipboard.append(i)
                            }
                        }, label: {
                            Image(systemName: "plus.square.fill.on.square.fill")
                                .resizable()
                                .foregroundStyle(.white,color.appThemeColor)
                                .frame(width: 25,height: 25)
                                .foregroundColor(color.appThemeColor)
                        })
                        
                        Button(action: {
                            self.isTextVisible = true
                            self.visibleText = "Cut"
                            self.clipboard = []
                            for i in selectedClipboard {
                                self.clipboard.append(i)
                                withAnimation {
                                    myExercises.removeAll { $0.id == i.id }
                                }
                            }
                        }, label: {
                            Image(systemName:"scissors")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25,height: 25)
                                .foregroundColor(color.appThemeColor)
                        })
                    }
                    
                    Button(action: {
                        self.editExercise = MyExercise()
                        self.goFrom = .addNew
                        showAddexercisePopup.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .frame(width: 28,height: 28)
                            .background(color.appThemeColor)
                            .cornerRadius(14)
                            .foregroundColor(.white)
                    })
                }.padding(.top,5)
                
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing:15){
                        ForEach(myExercises) { i in
                            exerciseCardView(i)
                                .onDrag({
                                    self.currentExercise = i
                                    return NSItemProvider(contentsOf: URL(string: "\(i.id)")!)!
                                })
                                .onDrop(of: [.url], delegate: DropViewDelegate(item: i, items: $myExercises, currentItem: self.currentExercise))
                        }
                    }
                }
                
                HStack(spacing:20){
                    
                    Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                        Text("Cancel")
                            .font(.custom(CustomFont.semiBold, size: 15))
                    })
                    .frame(maxWidth: .infinity,minHeight: 40)
                    .background(color.appCardColor)
                    .cornerRadius(20)
                    
                    Button(action: {
                        print("total",sumDurations(myExercises))
                        let timer = MyTimer(id:myTimer.id,name: name,duration:sumDurations(myExercises), numberOfSets: numberOfSets,exercises: myExercises)
                        self.myTimer = timer
                        if comeFrom == .addNew {
                            vm.addTimer(_myTimer: self.myTimer)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                                vm.getTimerRecords()
                            }
                        }else if comeFrom == .edit {
                            if let index = vm.myTimers.firstIndex(where: { $0.id == myTimer.id }) {
                                vm.myTimers[index] = myTimer
                                vm.updateTimerRecord(_myTimer: myTimer)
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save")
                            .font(.custom(CustomFont.semiBold, size: 15))
                    })
                    .frame(maxWidth: .infinity,minHeight: 40)
                    .background(color.appThemeColor)
                    .cornerRadius(20)
                }
            }.padding()
        }
        .background(color.appBGColor)
        .foregroundColor(Color.white)
        .navigationBarHidden(true)
        .onAppear{
            print("F_id->",myTimer.folderId)
            self.myExercises = myTimer.exercises
            self.name = self.myTimer.name
            self.numberOfSets = self.myTimer.numberOfSets
        }
        .overlay{
            if showAddexercisePopup {
                ExercisePopup(show: $showAddexercisePopup, myExercise: $myExercises, editExercise: self.editExercise,comeFrom: goFrom)
            }
        }
        .overlay(alignment: .bottom) {
            if isTextVisible {
                Text(self.visibleText)
                    .font(.custom(CustomFont.medium, size: 11))
                    .padding(.bottom,80)
                    .onAppear{
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            withAnimation {
                                self.isTextVisible = false
                            }
                        }
                    }
            }
        }
    }
    
    func topBar()-> some View {
        HStack{
            Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20,height: 15)
            })
            Spacer()
            Text("Add Work Timer")
                .font(.custom(CustomFont.bold, size: 20))
            Spacer()
        }
    }
    
    func exerciseCardView(_ item: MyExercise) -> some View {
        VStack{
            HStack(spacing:12){
                
                Button(action: {
                    if let index = self.selectedClipboard.firstIndex(of: item) {
                        self.selectedClipboard.remove(at: index)
                    } else {
                        self.selectedClipboard.append(item)
                    }
                }, label: {
                    Image(self.selectedClipboard.contains(item) ? "ic_circlefill" : "ic_circle")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .foregroundColor(color.appThemeColor)
                })
                
                Text(item.name)
                    .font(.custom(CustomFont.regular, size: 15))
                
                Spacer()
                
                Text(item.duration)
                    .font(.custom(CustomFont.regular, size: 15))
                
                Button(action: {}, label: {
                    Image(systemName:"line.3.horizontal")
                        .resizable()
                        .frame(width: 15,height: 10)
                }).padding(.leading,10)
            }.padding(.horizontal)
        }
        .frame(height: 45)
        .background(color.appCardColor)
        .cornerRadius(15)
        .onDelete(
            callFrom: "exe",
            style: .init(radius: 10, corners: [.topRight, .bottomRight]),
            deleteAction: {
                withAnimation {
                    myExercises.removeAll(where: { $0.id == item.id })
                }
            },
            editAction: {
                self.goFrom = .edit
                self.editExercise = item
                showAddexercisePopup = true
            },
            copyAction: {
                clipboard = []
                visibleText = "Copy"
                self.isTextVisible = true
                clipboard.append(item)
            },
            cutAction: {
                clipboard = []
                visibleText = "Cut"
                self.isTextVisible = true
                clipboard.append(item)
                withAnimation {
                    myExercises.removeAll { $0.id == item.id }
                }
            })
    }
}

struct AddEditWorkTimerView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditTimerView(comeFrom: .addNew)
    }
}
