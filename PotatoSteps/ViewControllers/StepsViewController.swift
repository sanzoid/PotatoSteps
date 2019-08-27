//
//  StepsViewController.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-14.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit

class StepsViewController: UIViewController {

    let containerView: UIView
    
    let stepsView: UIView
    let stepCountLabel: UILabel
    let stepProgressView: UIView
    
    let changeStepGoalView: UIView = UIView()
    let changeStepGoalButton: UIButton = UIButton()
    
    let runButtonView: UIView
    let runButton: UIButton
    
    init() {
        containerView = {
            let view = UIView()
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.backgroundColor = UIColor.magenta
            view.clipsToBounds = true
            return view
        }()
        
        stepsView = {
            let view = UIView()
            view.backgroundColor = UIColor.cyan
            view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            return view
        }()
        
        stepCountLabel = {
            let label = UILabel()
            label.text = "Step Count: "
            return label
        }()
        
        stepProgressView = {
            let view = UIView()
            view.backgroundColor = UIColor.magenta
            return view
        }()
        
        runButtonView = {
            let view = UIView()
            view.backgroundColor = UIColor.yellow
            view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            return view
        }()

        runButton = {
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setImage( #imageLiteral(resourceName: "potatosteps_round"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets.zero
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            return button
        }()
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "PotatoSteps"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\u{2699}\u{0000FE0E}", style: .plain, target: self, action: #selector(pressSettings(_:)))
        
        setUpViews()
    }
    
    func setUpViews() {
        view.addSubview(containerView)
        containerView.frame = view.frame
        
        // container views
        containerView.addSubview(changeStepGoalView)
        containerView.addSubview(stepsView)
        containerView.addSubview(runButtonView)
        
        // subviews
        stepsView.addSubview(stepCountLabel)
        stepsView.addSubview(stepProgressView)
        
        changeStepGoalView.addSubview(changeStepGoalButton)
        
        runButtonView.addSubview(runButton)
        
        let views: [String : UIView] = [
            "changeStepGoalView" : changeStepGoalView,
            "stepsView" : stepsView,
            "runButtonView" : runButtonView,
            "stepsCountLabel" : stepCountLabel,
            "stepProgressView" : stepProgressView,
            "runButton" : runButton
        ]
        
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
        }
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[changeStepGoalView(==100)]-8-[stepsView(==200)]-8-[runButtonView(>=100)]-8-|", options: [.alignAllCenterX], metrics: nil, views: views)
        containerView.addConstraints(verticalConstraints)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[changeStepGoalView]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stepsView]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[runButtonView]|", options: [], metrics: nil, views: views))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressSettings(_ sender: UIButton) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
