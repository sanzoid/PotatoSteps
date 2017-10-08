//
//  MainViewController.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-07.
//  Copyright © 2017 sandzapps. All rights reserved.
//

// The goal is to automatically update HealthKit at the same time every day 
// This way, the app doesn't need to be launched at all 
// Show what the number of steps is 
// A button to update the number of steps for when the step goal increases

import UIKit
import HealthKit

class MainViewController: UIViewController {

    let healthKitStore: HKHealthStore = HKHealthStore()
    
    var stepGoal: Double = 0 {
        didSet {
            stepGoalLabel.text = "\(Int(stepGoal))"
        }
    }
    
    var todaysSteps: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.stepCountLabel.text = "Today's Steps: \(Int(self.todaysSteps))"
            }
        }
    }
    
    @IBOutlet weak var stepGoalTitleLabel: UILabel!
    @IBOutlet weak var stepGoalLabel: UILabel!
    @IBOutlet weak var stepRunButton: UIButton!
    @IBOutlet weak var stepGoalChangeButton: UIButton!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setConstraints()
        DispatchQueue.main.async {
        }
        
        stepGoal = 7000
        
        stepGoalTitleLabel.text = "Step Goal:"
        stepRunButton.titleLabel?.text = "RUN LIKE A POTATO!!!"
        stepGoalChangeButton.titleLabel?.text = "Change Step Goal"
        
        // actions
        stepGoalChangeButton.addTarget(self, action: #selector(changeStepGoal(_:)), for: .touchUpInside)
        stepRunButton.addTarget(self, action: #selector(potatoRun(_:)), for: .touchUpInside)

        
        getSteps(completion: {
            stepCount in
            self.todaysSteps = stepCount
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        authorize()
    }
    
    func setConstraints() {
        
        let views: [String : UIView] = ["stepGoalTitleLabel" : stepGoalTitleLabel,
                                        "stepGoalLabel" : stepGoalLabel,
                                        "stepGoalChangeButton" : stepGoalChangeButton,
                                        "stepRunButton" : stepRunButton,
                                        "stepCountLabel" : stepCountLabel]
        
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-74-[stepGoalChangeButton]-8-[stepGoalTitleLabel]-16-[stepGoalLabel]-24-[stepRunButton]-48-[stepCountLabel]", options: [], metrics: nil, views: views)
        view.addConstraints(verticalConstraints)
        
        // horizontal constraints
        view.addConstraint(NSLayoutConstraint(item: stepGoalChangeButton, attribute: .trailing, relatedBy: .equal, toItem: stepGoalChangeButton.superview!, attribute: .trailing, multiplier: 1.0, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: stepGoalTitleLabel, attribute: .leading, relatedBy: .equal, toItem: stepGoalTitleLabel.superview!, attribute: .leading, multiplier: 1.0, constant: 8))
        view.addConstraint(NSLayoutConstraint(item: stepGoalLabel, attribute: .centerX, relatedBy: .equal, toItem: stepGoalLabel.superview!, attribute: .centerX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .centerX, relatedBy: .equal, toItem: stepRunButton.superview!, attribute: .centerX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stepCountLabel, attribute: .centerX, relatedBy: .equal, toItem: stepCountLabel.superview!, attribute: .centerX, multiplier: 1.0, constant: 0))
    }
    
    func changeStepGoal(_ sender: UIButton) {
        print("Change Step Goal")
        
        // prompt for change 
        
        let alert = UIAlertController(title: "Update Step Goal", message: "Enter in the number of steps you would like to run on the daily.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textField in
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {
            action in
            // change step goal
            if let text = alert.textFields?[0].text {
                if let value = Double(text) {
                    self.stepGoal = value
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func potatoRun(_ sender: UIButton) {
        print("Potato run!")
        
        completeStepGoal()
    }
    
    func completeStepGoal() {
        // if steps < stepGoal, add remaining
        getSteps(completion: {
            stepCount in
            if stepCount < self.stepGoal {
                self.addSteps(self.stepGoal - stepCount)
            }
        })
    }
    
    func authorize() {
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
    }
    
    func dayDate() -> Date {
        // Same day, but 6AM
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: .current, from: Date())
        components.hour = 6
        components.minute = 0
        components.second = 0
        
        return components.date!
    }
    
    func addSteps(_ value: Double) {
        
        let startDate = dayDate()
        let endDate = startDate
        
        let stepType = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: startDate, end: endDate)
        
        healthKitStore.save(stepSample, withCompletion: {
            (success: Bool, error: Error?) in
            print("Saved steps: \(value) \(stepSample)")
            self.getSteps(completion: nil)
        })
    }
    
    func getSteps(completion: ((_ stepCount: Double) -> Void)?) {
        
        let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        let date = Date()
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepQuantityType!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            if let results = results {
                results.enumerateStatistics(from: startDate, to: endDate, with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        print("Steps: \(steps)")
                        
                        completion?(steps)
                    }
                })
            }
        }
        
        healthKitStore.execute(query)
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
