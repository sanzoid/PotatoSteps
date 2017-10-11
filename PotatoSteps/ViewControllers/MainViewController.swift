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

// Features:
// A way to pick the date so that can update if wasn't able to update on that day
// Automatic update
// Make a widget to display stepCount to make sure it's getting updated in the background

// To do:
// Completion handlers

import UIKit
import HealthKit

class MainViewController: UIViewController
{
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    // keys 
    static let stepGoalKey = "stepGoalKey"
    static let tempTextKey = "tempTextKey"
    
    var stepGoal: Double = UserDefaults.standard.value(forKey: MainViewController.stepGoalKey) as? Double ?? 0 {
        didSet {
            if let stepGoalLabel = stepGoalLabel
            {
                stepGoalLabel.text = "\(Int(stepGoal))"
            }
            UserDefaults.standard.set(stepGoal, forKey: MainViewController.stepGoalKey)
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
    @IBOutlet weak var tempLabel: UILabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setConstraints()
        
        // labels
        navigationItem.title = "PotatoSteps"
        stepGoalTitleLabel.text = "Step Goal:"
        stepRunButton.setTitle("I can run to potato", for: .normal)
        stepGoalChangeButton.setTitle("Change Step Goal", for: .normal)
        
        // actions
        stepGoalChangeButton.addTarget(self, action: #selector(changeStepGoal(_:)), for: .touchUpInside)
        stepRunButton.addTarget(self, action: #selector(potatoRun(_:)), for: .touchUpInside)

        stepGoal = UserDefaults.standard.value(forKey: MainViewController.stepGoalKey) as? Double ?? 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        tempLabel?.text = UserDefaults.standard.value(forKey: MainViewController.tempTextKey) as? String ?? "Error"
        
        HealthKitManager.getSteps(completion: { stepCount in
            self.todaysSteps = stepCount
        })
    }
    
    func setConstraints()
    {
        let views: [String : UIView] = ["stepGoalTitleLabel" : stepGoalTitleLabel,
                                        "stepGoalLabel" : stepGoalLabel,
                                        "stepGoalChangeButton" : stepGoalChangeButton,
                                        "stepRunButton" : stepRunButton,
                                        "stepCountLabel" : stepCountLabel]
        
        for (_, view) in views
        {
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
        
        // size constraints
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200))
    }
    
    func changeStepGoal(_ sender: UIButton)
    {
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
    
    func potatoRun(_ sender: UIButton)
    {
        completeStepGoal()
    }
    
    func completeStepGoalInBackground()
    {
        // increase by 1 so we can see if it's happening
        self.stepGoal += 1
        completeStepGoal()
    }
    
    func completeStepGoal() {
        print("completeStepGoal \(stepGoal)")
        
        // if steps < stepGoal, add remaining
        HealthKitManager.getSteps(completion: { stepCount in
            if stepCount < self.stepGoal {
                HealthKitManager.addSteps(self.stepGoal - stepCount,
                                          completion: { success, error in
                    HealthKitManager.getSteps(completion: { stepCount in
                        self.todaysSteps = stepCount
                    })
                })
            }
            else {
                print("Step goal complete for the day")
            }
        })
    }
    
    
}
