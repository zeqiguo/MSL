//
//  ViewController.swift
//  Lab3
//
//  Created by Xingming on 10/8/19.
//  Copyright © 2019 Southern Methodist University. All rights reserved.
//
import CoreMotion
import UIKit
import SpriteKit
class ViewController: UIViewController {
    
    // --------All the labels---------
    @IBOutlet weak var todayStepLabel: UILabel!
    @IBOutlet weak var yesterdayStepLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var goalStepLabel: UILabel!
    @IBOutlet weak var goalAchievedStack: UIStackView!
    @IBOutlet weak var goalSlider: UISlider!
    
    // --------All the lazy vars---------
    lazy var Activity = ""
    lazy var stepsOfToday = 0
    lazy var numStepsYesterday = 0
    lazy var goalSteps = 0
    
    //---------All the  CM things -------------
    let pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    let customQueue = OperationQueue()
    
    private var isModalDialogueCreated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.goalAchievedStack.isHidden=true
        
        
        // set up the montion activity
        if CMMotionActivityManager.isActivityAvailable()
        {
            self.activityManager.startActivityUpdates(to: customQueue) { (activity:CMMotionActivity?) -> Void in
            self.Activity = self.getActivity(activity: activity!)
            DispatchQueue.main.async{ self.activityLabel.text="Current activity: "+self.Activity
                }
            }
        }
        
        //get today's step
        let now = Date()
        //so we want to get the data from today 00:00
        let beginingOfTheDay = Calendar.current.startOfDay(for: now)
//        beginingOfTheDay  Calendar.current.startOfDay(for: now)
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from:beginingOfTheDay) {
                (pedData: CMPedometerData?, error: Error?) -> Void in
                DispatchQueue.main.async{
                    self.todayStepLabel.text="Steps of Today: "+String(pedData!.numberOfSteps.intValue)
                    if(pedData!.numberOfSteps.intValue>Int(self.goalSlider.value)){
                        self.goalAchievedStack.isHidden=false
                        
                    }
                    else{
                        self.goalAchievedStack.isHidden=true
                    }
                }
            }
        }
        
        //get yesterday's step
        let fromPrevious = beginingOfTheDay.addingTimeInterval(-60*60*24)
        self.pedometer.queryPedometerData(from: fromPrevious, to: beginingOfTheDay) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            self.numStepsYesterday = pedData!.numberOfSteps.intValue
            DispatchQueue.main.async{
                self.yesterdayStepLabel.text="Steps of Yesterday: "+String(self.numStepsYesterday)
            }
        }
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let rounded = Int(sender.value)/100 * 100
        self.goalStepLabel.text=String(rounded)
    }
    
    func getActivity(activity: CMMotionActivity) -> String {
        if activity.walking {
            return "Walking"
        }
        else if activity.running {
            return "Running"
        }
        else if activity.cycling {
            return "Cycling"
        }
        else if activity.automotive {
            return "Driving"
        }
        else if activity.stationary {
            return "Stationary"
        }
        return "Unknown"
    }
}

