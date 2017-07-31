//
//  ForgotPasswordViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/14/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    //declare server
    var backendless = Backendless.sharedInstance()
    
    //IBOutlet vars
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var background: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        background.backgroundColor = silver;
        
        //make gestures
        // declare gestures
        let swipeLeft = UISwipeGestureRecognizer()
        
        // choose method to run when swiped
        swipeLeft.addTarget(self, action: #selector(OpeningViewController.swipeLeft))

        swipeLeft.direction = .left
        self.view!.addGestureRecognizer(swipeLeft)
        
    }

    @IBAction func ForgotPasswordToLogin(_ sender: Any) {
        
        performSegue(withIdentifier: "forgotPassToLogin", sender: nil)
        
    }
    
    @IBAction func sendTempPass(_ sender: Any) {
        
        let restoreEmail = emailField.text
        
        backendless?.userService.restorePassword(restoreEmail,
                                                response: {
                                                    (result : Any) -> Void in
                                                    self.displayAlertAndSegue("EMAIL SENT", message: "Please check your email inbox to reset your password")
                                                    print("Please check your email inbox to reset your password")
        },
                                                error: {
                                                    (fault : Fault?) -> Void in
                                                    self.displayAlert("Server error", message: "Check email and internet connection.")
                                                    print("Server reported an error: \(fault?.message ?? "Fault"))")
        })
    }
    
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertAndSegue(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "forgotPassToLogin", sender: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func swipeLeft(_ sender: Any){
        
        performSegue(withIdentifier: "forgotPassToLogin", sender: nil);
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
