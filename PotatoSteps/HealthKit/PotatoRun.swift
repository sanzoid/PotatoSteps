//
//  PotatoRun.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-10.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit

class PotatoRun
{
    static func completeStepGoalInBackground()
    {
        // increase by 1 so we can see if it's happening
        //self.stepGoal += 1
        completeStepGoal(completion: { success, error in
            HealthKitManager.getSteps(completion: { stepCount in
                
            })
        })
    }
    
    static func completeStepGoal(completion: ((Bool, Error?) -> Void)?)
    {
        let stepGoal = UserDefaults.init(suiteName: "group.com.sandzapps")?.value(forKey: "stepGoalKey") as? Double ?? 0
        print("completeStepGoal \(stepGoal)")
        
        // if steps < stepGoal, add remaining
        HealthKitManager.getSteps(completion: { stepCount in
            if stepCount < stepGoal {
                HealthKitManager.addSteps(stepGoal - stepCount,
                                          completion: { success, error in
                                            completion?(success, error)
                })
            }
            else {
                print("Step goal complete for the day")
            }
        })
    }
    
}
