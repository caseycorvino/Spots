//
//  ViewController.swift
//  Spots
//
//  Created by Casey Corvino on 6/9/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit





class OpeningViewController: UIViewController {
    
    //left-side instance vars
    @IBOutlet var loginView: UIView!
    @IBOutlet var loginButton: UIButton!
    
    //right-side instance vars
    @IBOutlet var registerView: UIView!
    @IBOutlet var registerButton: UIButton!
    
    var backendless = Backendless.sharedInstance()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //make .backgroundColors precise
        //make .backgroundColors return to default when opened again in same run
        loginView.backgroundColor = orange;
        registerView.backgroundColor = silver;
        
        //make gestures
        //declare gestures
        let swipeRight = UISwipeGestureRecognizer()
        let swipeLeft = UISwipeGestureRecognizer()
        
        //choose method to run when swiped
        swipeRight.addTarget(self, action: #selector(OpeningViewController.swipeRight))
        swipeLeft.addTarget(self, action: #selector(OpeningViewController.swipeLeft))
        
        //set directions of swipes
        swipeRight.direction = .right
        swipeLeft.direction = .left
        
        //add gestures to view
        self.view!.addGestureRecognizer(swipeRight)
        self.view!.addGestureRecognizer(swipeLeft)
        
        let deviceId = backendless?.messaging.currentDevice().deviceId
        
        cancelDeviceRegistration(deviceId: deviceId!)
        
        
    }
    
    //actions
    //login clicked action
    @IBAction func loginClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "login", sender: nil)
        
    }
    
    //register clicked action
    @IBAction func registerClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "register", sender: nil)
        
    }
    
    //Swipe Right
    @IBAction func swipeRight(_ sender: Any){
        
        performSegue(withIdentifier: "login", sender: nil)
    }
    
    //Swipe Left
    @IBAction func swipeLeft(_ sender: Any){
        
        performSegue(withIdentifier: "openingToRegister", sender: nil);
    }
    
    
    func cancelDeviceRegistration(deviceId: String) {
        backendless?.messaging.unregisterDevice(deviceId,
                                               response: {
                                                (result : Any?) -> Void in
                                                print("Device registration canceled: \(result.debugDescription )")
        },
                                               error: {
                                                (fault : Fault?) -> Void in
                                                print("Server reported an error: \(fault.debugDescription )")
        })
    }
    
    
    //override variables
    //status bar
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

