//
//  MainViewController.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-07.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UIViewController {

    let healthKitStore: HKHealthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.yellow
        
        // Check authorization and request if needed 
        if !(healthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!) == .sharingAuthorized) {
            authorizeHealthKit(completion: {
                (authorized, error) -> Void in
                if !authorized {
                    print("Health Kit not authorized!")
                } else {
                    print("Health Kit authorized!")
                }
            })
        }
        
        getSteps()
        setSteps(1337)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSteps(_ value: Double) {
        let startDate = Date()
        let endDate = startDate
        
        let stepType = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: startDate, end: endDate)
        
        healthKitStore.save(stepSample, withCompletion: {
            (success: Bool, error: Error?) in
            print("Saved steps: \(value)")
            self.getSteps()
        })
    }
    
    func getSteps() {
        
        var steps = 0.0
        
        let stepType = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let stepSampleQuery = HKSampleQuery(sampleType: stepType,
                                            predicate: nil,
                                            limit: 100,
                                            sortDescriptors: nil,
                                            resultsHandler: {(query, results, error) in
                                                if let results = results as? [HKQuantitySample] {
                                                    print(results)
                                                    steps = results[0].quantity.doubleValue(for: HKUnit.count())
                                                    print("Steps: \(steps)")
                                                }
        })
        
        healthKitStore.execute(stepSampleQuery)
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
     
        print("authorizeHealthKit")
        
        let dataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        let dataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Health Kit ain't available.")
        }
        
        healthKitStore.requestAuthorization(toShare: dataToWrite, read: dataToRead, completion: {
            (success, error) -> Void in
            completion(success, error)
        })
    }
}
