//
//  Constant.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/13/24.
//

import Foundation
import SwiftUI

let dSize = UIScreen.main.bounds.size

struct color {
    
    static let appThemeColor: Color = Color("AppThemeColor")
    static let appCardColor : Color = Color("CardColor")
    static let appBGColor : Color = Color("BGColor")
    
}


struct CustomFont {
    static let bold       = "Inter-Bold"
    static let extraBold  = "Inter-ExtraBold"
    static let semiBold   = "Inter-SemiBold"
    static let medium     = "Inter-Medium"
    static let regular    = "Inter-Regular"
    static let thin       = "Inter-Thin"
    static let light      = "Inter-Light"
    static let extraLight = "Inter-ExtraLight"
}

func sumDurations(_ timer: [MyExercise]) -> String {
    var totalMinutes = 0

    for i in timer {
        let components = i.duration.components(separatedBy: ":")
        if components.count == 2,
           let hours = Int(components[0]),
           let minutes = Int(components[1]) {
            totalMinutes += hours * 60 + minutes
        }
    }

    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    // Format the result as "HH:mm"
    let formattedResult = String(format: "%02d:%02d", hours, minutes)

    return formattedResult
}


func sumDurationsInSeconds(_ durations: [String]) -> Int {
    var totalSeconds = 0

    for duration in durations {
        let components = duration.components(separatedBy: ":")
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Int(components[1]) {
            totalSeconds += minutes * 60 + seconds
        }
    }

    return totalSeconds
}
