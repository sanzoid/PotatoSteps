//
//  AppDelegate.swift
//  PotatoSteps
//
//  Created by Sandy House on 2017-10-07.
//  Copyright © 2017 sandzapps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
//        let navViewController = UINavigationController()
//        navViewController.viewControllers.append(StepsViewController())
//        self.window?.rootViewController = navViewController
        
        // set root view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = initialViewController
        
        // set how often a background fetch will occur
        UIApplication.shared.setMinimumBackgroundFetchInterval(60*60)
        
        return true
    }

    // background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        var backgroundMessage = "BG: \(dateString)."
        
        // complete step goal
        if let navVC = self.window?.rootViewController as? UINavigationController,
            let mainVC = navVC.viewControllers[0] as? MainViewController
        {
            PotatoRun.completeStepGoalInBackground()
            backgroundMessage += " Complete \(mainVC.stepGoal)"
        }
        
        UserDefaults.standard.set(backgroundMessage, forKey: MainViewController.tempTextKey)
        
        // say there's newData every time so that it thinks it's important
        completionHandler(.newData)
    }
    
}

