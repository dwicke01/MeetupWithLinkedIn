//
//  ViewController.swift
//  MeetupWithLinkedIn
//
//  Created by Daniel Wickes on 9/15/15.
//  Copyright © 2015 danielwickes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        MeetupOAuth.sharedInstance.startOAuth2Login()
    }

}

