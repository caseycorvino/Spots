//
//  LoginViewController.swift
//  Spots
//
//  Created by Casey Corvino on 6/9/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

var activeUser: BackendlessUser = BackendlessUser()
var activeUserId: String = ""

class LoginViewController: UIViewController {
    
    
    //declare server
    var backendless = Backendless.sharedInstance()
    
    
    //instance vars
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var enterButtonView: UIView!
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = orange;
        enterButtonView.backgroundColor = silver
        enterButtonView.layer.cornerRadius = 25
        enterButtonView.layer.masksToBounds = true;
        // Do any additional setup after loading the view.
        
        //declare gestures
        let swipeLeft = UISwipeGestureRecognizer()
        
        //choose method to run when swiped
        swipeLeft.addTarget(self, action: #selector(OpeningViewController.swipeLeft))
        
        //set directions of swipes
        swipeLeft.direction = .left
        
        //add gestures to view
        self.view!.addGestureRecognizer(swipeLeft)
        
        //set up activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //button methods
    
    //clicked back buttom returns to opening
    @IBAction func returnToOpening(_ sender: Any) {
        performSegue(withIdentifier: "openingFromLogin", sender: nil)
    }
    
    //clicked forgot password button opens forgot password page
    @IBAction func forgotPassword(_ sender: Any) {
        
        performSegue(withIdentifier: "loginToForgotPass", sender: nil)
    }
    
    //login user to backendless and continue to mapViewController
    @IBAction func enterButton(_ sender: Any) {
        
        activityIndicator.startAnimating()
        
        let loginEmail = emailField.text?.lowercased()
        let loginPassword = passwordField.text
        backendless?.userService.login(loginEmail,
                                      password: loginPassword,
                                      response: {
                                        (loggedUser : BackendlessUser?) -> Void in
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        self.backendless?.userService.setStayLoggedIn(true)
                                        activeUser = loggedUser!
                                        activeUserId = activeUser.objectId as String
                                        self.performSegue(withIdentifier: "loginToActiveMap", sender: nil)
                                        
                                        let deviceId = self.backendless?.messaging.currentDevice().deviceId
                                        
                                        activeUser.setProperty("deviceId", object: deviceId)
                                        self.backendless?.userService.update(activeUser, response: { (user: BackendlessUser?) in
                                            print("Update DeviceId: succesful")
                                        }, error: { (fault: Fault?) in
                                            print("Fault=\(fault?.description ?? "")")
                                        })
                                       
                                        print("User logged in")
        },
                                      error: {
                                        (fault : Fault?) -> Void in
                                        self.displayAlert("Server Error", message: "Please check internet connection, email and password.")
                                        print("Server reported an error: \(String(describing: fault?.message))")
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.shared.endIgnoringInteractionEvents()
        })
        
    }
    
    //swipe left
    @IBAction func swipeLeft(_ sender: Any){
        
        performSegue(withIdentifier: "openingFromLogin", sender: nil);
    }
    
    //override functions
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
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
