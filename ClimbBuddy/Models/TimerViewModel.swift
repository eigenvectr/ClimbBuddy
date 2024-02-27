//
//  TimerViewModel.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/12/24.
//

import CoreData
import Foundation
import UIKit
import Combine

class TimerViewModel: ObservableObject{
    @Published var myTimers : [MyTimer] = []
    @Published var folderArray: [Folder] = []
    //    ["My Folder1":["uuid","uuid"],"My Folder2":["uuid","uuid"]]
    
    let context = PersistenceController.shared.container.viewContext
    
    init() {
        getTimerRecords()
        getFolderRecords()
    }
    
    func getTimerRecords() {
        // Reset the current array of timers to ensure it's empty before fetching new records
        self.myTimers = []
        // Create a fetch request for Tbl_Timer entities
        let fetchReq: NSFetchRequest<Tbl_Timer> = Tbl_Timer.fetchRequest()
        do {
            // Attempt to execute the fetch request and store the results in 'array'
            let array = try context.fetch(fetchReq)
            // Iterate through each fetched Tbl_Timer object
            for i in array {
                // Debug print the folderId of each timer (if present)
                print("FID->", i.folderId ?? "nil")
                // Check if the current timer does not belong to any folder
                if i.folderId == nil {
                    // Initialize an empty array to hold MyExercise objects
                    var exe: [MyExercise] = []
                    // Attempt to cast the 'exercises' relationship to a set of Tbl_Exercise
                    if let exercisesSet = i.exercises as? Set<Tbl_Exercise> {
                        // Convert the set to an array for easier iteration
                        let exercisesArray = Array(exercisesSet)
                        // Iterate through each Tbl_Exercise object in the set
                        for e in exercisesArray {
                            // Create a MyExercise object with properties from Tbl_Exercise
                            // and append it to the 'exe' array
                            exe.append(MyExercise(name: e.name ?? "", duration: e.duration ?? ""))
                        }
                    }
                    // Append a new MyTimer object to the 'myTimers' array with properties
                    // from the current Tbl_Timer and the exercises array
                    myTimers.append(MyTimer(id: i.id ?? "", name: i.name ?? "", duration: i.duration ?? "", numberOfSets: i.numberOfSets ?? "0", exercises: exe))
                }
            }
            // print the total number of timers fetched
            print("timers:", array.count)
        } catch {
            // print an error message
            print("Could not load save data: \(error.localizedDescription)")
        }
    }
    
    func getFolderRecords() {
        
        self.folderArray = []
        
        let fetchReq: NSFetchRequest<Tbl_Folder> = Tbl_Folder.fetchRequest()
        
        do {
            let array = try context.fetch(fetchReq)
            
            print("a->", array)
            
            for i in array {
                var time:[MyTimer] = []
                
                if let exercisesSet = i.timer as? Set<Tbl_Timer> {
                    let exercisesArray = Array(exercisesSet)
                    
                    for t in exercisesArray {
                        var exe: [MyExercise] = []
                        if let exercisesSet = t.exercises as? Set<Tbl_Exercise> {
                            let exercisesArray = Array(exercisesSet)
                            
                            for e in exercisesArray {
                                exe.append(MyExercise(name: e.name ?? "", duration: e.duration ?? ""))
                            }
                        }
                        time.append(MyTimer(id: t.id ?? UUID().uuidString,name: t.name ?? "", duration: t.duration ?? "",numberOfSets: t.numberOfSets!,exercises: exe))
                    }
                }
                folderArray.append(Folder(id:i.id ?? "",isExpand: false, folderName: i.folderName!,myTimers: time))
            }
            print("Folder:", array.count)
        } catch {
            print("Could not load save data: \(error.localizedDescription)")
        }
    }
    
    func saveFolderDataCD(_ folder: Folder) {
        
        let folderData = Tbl_Folder(context: context)
        folderData.id = folder.id
        folderData.folderName = folder.folderName
        for i in folder.myTimers {
            let timerData = Tbl_Timer(context: context)
            print("F->",i.folderId)
            timerData.name = i.name
            timerData.duration = i.duration
            timerData.numberOfSets = i.numberOfSets
            timerData.folderId = i.folderId
            folderData.addToTimer(timerData)
            
            for (_,obj) in i.exercises.enumerated() {
                
                let tmrData = Tbl_Exercise(context:context)
                tmrData.name = obj.name
                tmrData.duration = obj.duration
                timerData.addToExercises(tmrData)
            }
            
            saveContext()
        }
        saveContext()
    }
        
    func addTimerToExistingFolder(itame: Folder,newTimer:MyTimer) {
        do {
            // Fetch the existing folder from Core Data
            let fetchRequest: NSFetchRequest<Tbl_Folder> = Tbl_Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", itame.id)
            
            if let existingFolder = fetchFolderById(itame.id) {
                // Create a new timer
                
                print("add exxisting folder",itame,newTimer)
                
                let timerData = Tbl_Timer(context: context)
                
                print("number of set", newTimer.numberOfSets)
                timerData.folderId = itame.folderName
                timerData.numberOfSets = newTimer.numberOfSets
                timerData.name = newTimer.name
                timerData.duration = newTimer.duration
                timerData.id = UUID().uuidString
                
                for (_,obj) in newTimer.exercises.enumerated() {
                    
                    print("obj->",obj)
                    
                    let tmrData = Tbl_Exercise(context:context)
                    tmrData.name = obj.name
                    tmrData.duration = obj.duration
                    timerData.addToExercises(tmrData)
                }
                
                existingFolder.addToTimer(timerData)
                
                // Save changes to Core Data
                try context.save()
                print("Timer added to existing folder successfully\(existingFolder)")
            } else {
                print("Folder not found with ID:")
            }
        } catch {
            print("Failed to add timer to existing folder: \(error.localizedDescription)")
        }
    }
    
    func deleteFolderItem(_ myFolder: Folder) {
        let fetchRequest: NSFetchRequest<Tbl_Folder> = Tbl_Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", myFolder.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let timerToDelete = results.first {
                context.delete(timerToDelete)
                folderArray.removeAll { $0.id == myFolder.id }
                try context.save()
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    private func fetchFolderById(_ folderId: String) -> Tbl_Folder? {
        let fetchRequest: NSFetchRequest<Tbl_Folder> = Tbl_Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", folderId)

        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Error fetching folder by ID: \(error.localizedDescription)")
            return nil
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
    
    func updateTimerRecord(_myTimer: MyTimer){
        
        let fetchReq :NSFetchRequest<Tbl_Timer>
        fetchReq = Tbl_Timer.fetchRequest()
        fetchReq.predicate =  NSPredicate(format: "id == %@", _myTimer.id)
        
        let getData = try? self.context.fetch(fetchReq)
        
        let timerData = getData![0]
        timerData.name = _myTimer.name
        timerData.duration = _myTimer.duration
        timerData.numberOfSets = _myTimer.numberOfSets
        timerData.id = _myTimer.id
        
        timerData.removeFromExercises(timerData.exercises!)
        
        for (_,obj) in _myTimer.exercises.enumerated() {
            
            print("obj->",obj)
            
            let tmrData = Tbl_Exercise(context:context)
            tmrData.name = obj.name
            tmrData.duration = obj.duration
            timerData.addToExercises(tmrData)
        }
        
        do {
            try context.save()
        }
        catch {
            print("saving error:",error.localizedDescription)
        }
    }
}
