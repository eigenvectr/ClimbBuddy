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
    @Published var myTimers : [MyTimer] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    init(){
        getTimerRecords()
    }
    
    // Function to fetch timer records from Core Data
    func getTimerRecords() {
        self.myTimers = [] // Clears the existing timers to prepare for fresh data
        // Define a fetch request for Tbl_Timer objects
        let fetchReq: NSFetchRequest<Tbl_Timer> = Tbl_Timer.fetchRequest()
        do {
            // Execute the fetch request to retrieve an array of Tbl_Timer instances
            let array = try context.fetch(fetchReq)
            // Iterate over each fetched Tbl_Timer object
            for i in array {
                var exe: [MyExercise] = [] // Initialize an empty array for MyExercise
                // Attempt to cast the 'exercises' relationship to a Set of Tbl_Exercise
                if let exercisesSet = i.exercises as? Set<Tbl_Exercise> {
                    let exercisesArray = Array(exercisesSet) // Convert the set to an array
                    // Iterate over the exercises array to populate the MyExercise array
                    for e in exercisesArray {
                        exe.append(MyExercise(name: e.name ?? "", duration: e.duration ?? ""))
                    }
                }
                // Append a new MyTimers object to the myTimers array with data from the current Tbl_Timer
                self.myTimers.append(MyTimer(id: i.id ?? UUID().uuidString, name: i.name ?? "", duration: i.duration ?? "", numberOfSets: i.numberOfSets ?? "0", exercises: exe))
            }
            // Debugging: logging amount of fetched timers
            print("Fetched timers:", array.count)
        } catch {
            // Logging an error if the fetch operation fails
            print("Could not load timer data: \(error.localizedDescription)")
        }
    }
    
    //saveTimers
    
    //updateTimers
    
    //deleteTimers
}
