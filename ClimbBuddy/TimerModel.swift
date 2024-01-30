//
//  TimerModel.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 1/30/24.
//

import Foundation

struct TimerItem : Identifiable{
    var id = UUID()
    var title: String
    // Think of more things that will be in the timer.
}

struct FolderItem : Identifiable{
    var id = UUID()
    var title: String
    var timers: [TimerItem] // A folder contains an array of timers
}
