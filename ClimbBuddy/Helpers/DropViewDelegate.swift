//
//  DropViewDelegate.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/16/24.
//

import Foundation
import SwiftUI

struct DropViewDelegate: DropDelegate{
    var item: MyExercise
    @Binding var items: [MyExercise]
    var currentItem : MyExercise
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        let fromIndex = items.firstIndex{ item -> Bool in
            return item.id == currentItem.id
        } ?? 0
        
        let toIndex = items.firstIndex{ item -> Bool in
            return item.id == self.item.id
        } ?? 0
        
        if fromIndex != toIndex {
            withAnimation {
                let fromItem = items[fromIndex]
                items[fromIndex] = items[toIndex]
                items[toIndex] = fromItem
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
