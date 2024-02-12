//
//  TimerModel.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 1/30/24.
//

import Foundation

struct MyTimers: Identifiable,Equatable {
    var id = UUID().uuidString
    var name:String = ""
    var duration: String = ""
    var numberOfSets: String = ""
    var exercises: [MyExercise] = []
}

struct MyExercise: Identifiable ,Equatable{
    var id = UUID().uuidString
    var name: String = ""
    var duration: String = ""
}

struct FolderItem : Identifiable{
    var id = UUID()
    var title: String
    var timers: [MyTimers] // A folder contains an array of timers
}
