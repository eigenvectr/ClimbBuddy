//
//  TimerViewModel.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/12/24.
//

import Foundation
import CoreData
import UIKit
import Combine

class TimerViewModel: ObservableObject{
    @Published var MyTimers : [MyTimers] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    //Init
    
    //getTimers
    
    //saveTimers
    
    //updateTimers
    
    //deleteTimers
}
