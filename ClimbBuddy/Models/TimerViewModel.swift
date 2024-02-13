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
    
    func saveContext() {
        do{
            try context.save()
        }
        catch{
            print("saving error:",error.localizedDescription)
        }
    }
    
    func addTimer(_myTimer: MyTimer){
        // Creating new Tbl_Timer instance in the Core Data context
        let timerData = Tbl_Timer(context: context)
        
        // Setting properties of the Tbl_Timer instance from the MyTimer parameter
        timerData.name = _myTimer.name
        timerData.duration = _myTimer.duration
        timerData.numberOfSets = _myTimer.numberOfSets
        timerData.id = _myTimer.id
        
        // Iterate through the exercises array of the MyTimer parameter
        for (i,obj) in _myTimer.exercises.enumerated() {
            // Create a new Tbl_Exercise instance in the Core Data context for each exercise
            let tmrData = Tbl_Exercise(context:context)
            tmrData.name = obj.name
            tmrData.duration = obj.duration
            timerData.addToExercises(tmrData) // Add the Tbl_Exercise instance to the exercises set of the Tbl_Timer instance
            
            // If we are on the last exercise, save the context
            if i == _myTimer.exercises.count - 1 {
                saveContext()
            }
        }
        
        // Save the context after all exercises have been added to the timer
        saveContext()
    }
    
    func deleteItem(_ myTimer: MyTimer) {
        // Set up a fetch request to find the Tbl_Timer object in Core Data by its ID
        let fetchRequest: NSFetchRequest<Tbl_Timer> = Tbl_Timer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", myTimer.id)
        
        do {
            // Execute the fetch request to get an array of Tbl_Timer objects that match the predicate
            let results = try context.fetch(fetchRequest)
            
            // Check if we have a result and get the first one since IDs should be unique
            if let timerToDelete = results.first {
                // Delete the fetched Tbl_Timer object from the Core Data context
                context.delete(timerToDelete)
                
                // Remove the corresponding MyTimer object from the local array
                myTimers.removeAll { $0.id == myTimer.id }
                
                // Save the context to commit the deletion in Core Data
                try context.save()
            }
        } catch {
            // Log error if timer deletion fails
            print("Error deleting item: \(error)")
        }
    }
    
    func updateTimerRecord(_ myTimer: MyTimer) {
        // Set up a fetch request to find the Tbl_Timer object by its ID
        let fetchReq: NSFetchRequest<Tbl_Timer> = Tbl_Timer.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id == %@", myTimer.id)
        
        do {
            // Attempt to execute the fetch request
            let results = try context.fetch(fetchReq)
            
            // Ensure we have a timer to update
            if let timerData = results.first {
                // Update the timer properties
                timerData.name = myTimer.name
                timerData.duration = myTimer.duration
                timerData.numberOfSets = myTimer.numberOfSets
                timerData.id = myTimer.id
                
                // Remove all existing exercises
                if let exercises = timerData.exercises as? Set<Tbl_Exercise> {
                    exercises.forEach(context.delete)
                }
                
                // Add updated exercises
                myTimer.exercises.forEach { exercise in
                    let tmrData = Tbl_Exercise(context: context)
                    tmrData.name = exercise.name
                    tmrData.duration = exercise.duration
                    timerData.addToExercises(tmrData)
                }
                
                // Save the context after making all updates
                try context.save()
            }
        } catch {
            // Log error if timer update fails
            print("Error updating timer: \(error.localizedDescription)")
        }
    }
}
