//
//  HealthKitManager.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-10.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitManager
{
    static let healthKitStore: HKHealthStore = HKHealthStore()
    
    static func addSteps(_ value: Double, completion: ((Bool, Error?) -> Void)?)
    {
        checkAndRequestAuthorization(completion: { (authorized, error) in
            let startDate = dayDate()
            let endDate = startDate
            
            let stepType = HKSampleType.quantityType(forIdentifier: .stepCount)!
            let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: value)
            let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: startDate, end: endDate)
            
            healthKitStore.save(stepSample, withCompletion: {
                (success: Bool, error: Error?) in
                print("Saved steps: \(value) \(stepSample)")
                completion?(success, error)
            })
        })
    }
    
    static func getSteps(completion: ((_ stepCount: Double) -> Void)?)
    {
        checkAndRequestAuthorization(completion: { (authorized, error) in
            let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
            let startDate = Calendar.current.startOfDay(for: Date())
            let endDate = Date()
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(quantityType: stepQuantityType!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
            
            query.initialResultsHandler = { query, results, error in
                if let results = results
                {
                    results.enumerateStatistics(from: startDate, to: endDate, with: { statistics, stop in
                        if let quantity = statistics.sumQuantity()
                        {
                            let steps = quantity.doubleValue(for: HKUnit.count())
                            
                            print("Steps: \(steps)")
                            completion?(steps)
                        }
                        else
                        {
                            completion?(0)
                        }
                    })
                }
                else
                {
                    completion?(0)
                }
            }
            
            healthKitStore.execute(query)
        })
    }
    
    // completion with whether or not it was authorized
    static func checkAndRequestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    {
        // Check authorization and request if needed
        if !(healthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!) == .sharingAuthorized)
        {
            print("checkAndRequestAuthorization")
            authorizeHealthKit(completion: { (authorized, error) -> Void in
                if !authorized
                {
                    print("Health Kit not authorized!")
                }
                else
                {
                    print("Health Kit authorized!")
                }
                completion(authorized, error)
            })
        }
        else
        {
            completion(true, nil)
        }
    }
    
    static func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void)
    {
        print("authorizeHealthKit")
        
        let dataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        let dataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            print("Health Kit ain't available.")
        }
        
        healthKitStore.requestAuthorization(toShare: dataToWrite, read: dataToRead,
                                            completion: { (success, error) -> Void in
            if error != nil
            {
                print("authorizeHealthKit: \(error?.localizedDescription ?? "Error")")
            }
            
            completion(success, error)
        })
    }
    
    static func dayDate() -> Date
    {
        // Same day, but 4AM - unlikely to overlap with any data
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: .current, from: Date())
        components.hour = 4
        components.minute = 0
        components.second = 0
        
        return components.date!
    }
}
