//
//  TimerModel.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 1/30/24.
//

import Foundation

struct MyTimer: Identifiable,Equatable {
    var id = UUID().uuidString
    var folderId: String = "non"
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

struct Folder:Identifiable {
    var id = UUID().uuidString
    var isExpand:Bool = false
    var folderName: String = ""
    var myTimers:[MyTimer] = []
}
