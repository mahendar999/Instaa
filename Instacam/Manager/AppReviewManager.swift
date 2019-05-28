//
//  ReviewRequest.swift
//  ForTheCulture
//
//  Created by SFS3 on 28/01/19.
//  Copyright © 2019 MAC 3. All rights reserved.
//

import Foundation
import StoreKit


let runIncrementerSetting = "numberOfRuns"  // UserDefauls dictionary key where we store number of runs
let minimumRunCount = 4                     // Minimum number of runs that we should have until we ask for review


func incrementAppRuns() {                   // counter for number of runs for the app. You can call this from App Delegate
    let usD = UserDefaults()
    let runs = getRunCounts() + 1
    usD.setValuesForKeys([runIncrementerSetting: runs])
    usD.synchronize()
}

func getRunCounts () -> Int {               // Reads number of runs from UserDefaults and returns it.
    
    let usD = UserDefaults()
    let savedRuns = usD.value(forKey: runIncrementerSetting)
    
    var runs = 0
    if (savedRuns != nil) {
        runs = savedRuns as! Int
    }
    
    print("Run Counts are \(runs)")
    return runs
}

func showReview() {
    
    let runs = getRunCounts()
    print("Show Review")
    // Get the current bundle version for the app
    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { fatalError("Expected to find a bundle version in the info dictionary") }
    
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
    
    // Has the process been completed several times and the user has not already been prompted for this version?
    if runs >= 4 && currentVersion != lastVersionPromptedForReview {
        let twoSecondsFromNow = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
            UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        }
    }
}


class UserDefaultsKeys {
    class var processCompletedCountKey: String {
        return "processCompletedCount"
    }
    class var lastVersionPromptedForReviewKey: String {
        return "lastVersionPromptedForReview"
    }
}

