//
//  ViewController.swift
//  bluetoothHeartRate
//
//  Created by Curtis Bacon on 05/12/2015.
//  Copyright © 2015 Curtis Bacon. All rights reserved.
//

import UIKit

let heartBeatKey = "heartBeat:"

class ViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.btle = BTLE()
    }
    
    @IBOutlet weak var heartRateLabel: UILabel!
    
    var btle: BTLE!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "heartBeatNotification:", name: heartBeatKey, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when there's a notification from the model
    func heartBeatNotification(notification: NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let messageString = userInfo["heartRate"]
        heartRateLabel.text = messageString
    }
    
}