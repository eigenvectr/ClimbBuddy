//
//  DragAndDropDelegate.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/16/24.
//

import Foundation
import MobileCoreServices
import SwiftUI


struct DragAndDropDelegate: DropDelegate {
    let item: Folder
    let vm: TimerViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [kUTTypePlainText as String]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { (provider, error) in
            if let draggedItemID = UUID(uuidString: provider as! String),
               let draggedTimer = vm.myTimers.first(where: { $0.id == draggedItemID.uuidString }) {
                // Perform actions with draggedTimer, e.g., move it to the folder
                
                DispatchQueue.main.async {
                    
                    vm.deleteItem(draggedTimer)
                    vm.addTimerToExistingFolder(itame: item, newTimer: draggedTimer)
                    vm.getFolderRecords()
                    vm.getTimerRecords()
                }
                
                print("Dropped Timer ID: \(draggedTimer.id) into Folder ID: \(item.id)")
            }
        }
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
}
