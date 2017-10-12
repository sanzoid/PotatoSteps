//
//  TodayViewController.swift
//  PotatoStepsWidget
//
//  Created by Sandy House on 2017-10-10.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var stepRunButton: UIButton!
    
    var stepGoal: Double = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.addConstraints()
        
        stepCountLabel.textColor = UIColor.white
        stepRunButton.addTarget(self, action: #selector(potatoRun(_:)), for: .touchUpInside)
        stepGoal = UserDefaults.init(suiteName: "group.com.sandzapps")?.value(forKey: "stepGoalKey") as? Double ?? 0
        
        HealthKitManager.getSteps(completion: { stepCount in
            DispatchQueue.main.async {
                self.stepCountLabel.text = "Steps: \(Int(stepCount))/\(Int(self.stepGoal))"
            }
        })
    }
    
    @objc func potatoRun(_ sender: UIButton)
    {
        PotatoRun.completeStepGoal(completion: { success, error in
            HealthKitManager.getSteps(completion: { stepCount in
                DispatchQueue.main.async {
                    self.stepCountLabel.text = "Steps: \(Int(stepCount))/\(Int(self.stepGoal))"
                }
            })
        })
        
    }
    
    func addConstraints()
    {
        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false
        stepRunButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: stepCountLabel, attribute: .centerY, relatedBy: .equal, toItem: stepCountLabel.superview!, attribute: .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stepCountLabel, attribute: .leading, relatedBy: .equal, toItem: stepCountLabel.superview!, attribute: .leading, multiplier: 1.0, constant: 16))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .centerY, relatedBy: .equal, toItem: stepRunButton.superview!, attribute: .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .trailing, relatedBy: .equal, toItem: stepRunButton.superview!, attribute: .trailing, multiplier: 1.0, constant: -16))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        view.addConstraint(NSLayoutConstraint(item: stepRunButton, attribute: .width, relatedBy: .equal, toItem: stepRunButton, attribute: .height, multiplier: 1.0, constant: 0))
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
