//
//  TermsOfServicesViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/13/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class TermsOfServicesViewController: UIViewController {

    //declare server
    var backendless = Backendless.sharedInstance()
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    //IBOutlet instance variables
    @IBOutlet var background: UIView!
    
    @IBOutlet var buttonBackground: UIView!
    
    @IBOutlet var acceptlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //background.backgroundColor = silver;
        
        
        acceptlabel.textColor = UIColor.black        // Do any additional setup after loading the view.
        
     
        helper.putBorderOnButton(buttonView: buttonBackground, radius: 25)
        
        //set up activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)

    }

    @IBAction func finishSignup(_ sender: Any) {
        
        
        // create new BackendlessUser object
        let newUser = BackendlessUser()
        
        //set newUser properties
        newUser.setProperty("email", object: signupEmail)
        newUser.name = signupUsername as NSString
        newUser.password = signupPassword as NSString
        
        SignUpUser(user: newUser)
        
        
        
        
        
        
    }
    
    func SignUpUser(user: BackendlessUser) -> Void{
        
        activityIndicator.startAnimating()
        //stop receiving touches
        UIApplication.shared.beginIgnoringInteractionEvents()
        backendless?.userService.register(user,
                                          response: {
                                            (registeredUser : BackendlessUser?) -> Void in
                                            //end stop receiving touches
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.activityIndicator.stopAnimating()
                                            self.displayAlertAndSegue("REGISTRATION SUCCESFULL", message: "You can now login to Spots!")
                                            print("User registered \(String(describing: registeredUser?.value(forKey: "email")!))")
                                            
        },
                                          error: {
                                            (fault : Fault?) -> Void in
                                            //end stop receiving touches
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.displayAlert("Server reported an error", message: "Please check email, username, password and try again.")
                                            print("Server reported an error: \(String(describing: fault?.message))")
                                            self.activityIndicator.stopAnimating()
        })

        
        
    }
    
    @IBAction func termsOfServicesToPassword(_ sender: Any) {
        
        performSegue(withIdentifier: "termsOfServicesToPassword", sender: nil)
    
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
            self.performSegue(withIdentifier: "TermsOfServicesToLogin", sender: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
