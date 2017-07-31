//
//  registerEmailViewController.swift
//  Spots
//
//  Created by Casey Corvino on 6/9/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

//sign up variables
var signupUsername: String = ""
var signupEmail: String = ""
var signupPassword: String = ""

class registerEmailViewController: UIViewController {
    
    //declare server
    var backendless = Backendless.sharedInstance()
    
    //IBOutlet vars
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var confirmEmailField: UITextField!
    @IBOutlet var nextButtonView: UIView!
    @IBOutlet var nextButton: UIButton!
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = silver;
        nextButtonView.layer.cornerRadius = 25;
        nextButtonView.layer.masksToBounds = true;
        nextButton.setTitleColor(UIColor.gray, for: UIControlState.normal);
        // Do any additional setup after loading the view.
        
        //declare gestures
        let swipeRight = UISwipeGestureRecognizer()
        
        //choose method to run when swiped
        swipeRight.addTarget(self, action: #selector(OpeningViewController.swipeRight))
        
        //set directions of swipes
        swipeRight.direction = .right
        
        //add gestures to view
        self.view!.addGestureRecognizer(swipeRight)
        
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
    
    
    //segues
    
    //clicked back button returns to opening
    @IBAction func returnToOpening(_ sender: Any) {
        
        performSegue(withIdentifier: "openingFromRegister", sender: nil)
    }
    
    //clicked next button checks fields then goes to password page
    @IBAction func next(_ sender: Any) {
        //reset warning
        warningLabel.text = ""
        
       
        
        
        //set field.text to temporary username var
        let checkUsername: String = usernameField.text!.lowercased()
        
        //set field.text to temporary email vars
        let checkEmail: String = emailField.text!.lowercased()
        let checkConfirmEmail: String = confirmEmailField.text!.lowercased()
        
        // check username and email
        //first check username
        if isValidUsername(testStr: checkUsername) {
            
            //check emails match
            if(checkEmail == checkConfirmEmail){
                
                //check email is valid
                if isValidEmail(testStr: checkEmail){
                    //stop receiving touches
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    activityIndicator.startAnimating()
                    //create search query
                    let query = DataQueryBuilder().setWhereClause("email = '\(checkEmail)'")
                    
                    //search
                    _ = backendless?.data.of(BackendlessUser.ofClass()).find(query,
                                
                                //when complete check if found
                                response: { ( userObjects: [Any]?) in
                                
                                //if user found
                                if (userObjects?.count)! > 0{
                                    
                                    //change warning text
                                    self.warningLabel.text = "Email is already registered."
                                    self.view.endEditing(true);
                                    //stop receiving touches
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.activityIndicator.stopAnimating()
                                
                                } else{
                                    //if no username is found else block
                                    
                                    //check if username is taken
                                    let query2 = DataQueryBuilder().setWhereClause("name = '\(checkUsername)'")
                                    _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2,
                                        //when complete check if found
                                        response: { ( userObjects: [Any]?) in
                                            
                                            //if user found
                                            if (userObjects?.count)! > 0{
                                                //change warning text
                                                self.warningLabel.text = "Username is already taken."
                                                self.view.endEditing(true);
                                                //stop receiving touches
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                self.activityIndicator.stopAnimating()

                                            } else{
                                                //set signup variables
                                                signupEmail = checkEmail
                                                signupUsername = checkUsername
                                                
                                                //stop receiving touches
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                self.activityIndicator.stopAnimating()

                                                //segue to next step
                                                self.performSegue(withIdentifier: "registerToPassword", sender: nil)
                                                
                                            }
                                            
                                            
                                    },//if error print error
                                        error: { (fault: Fault?) in
                                            print("\(String(describing: fault))")
                                            self.warningLabel.text = "Server Error."
                                            //stop receiving touches
                                            self.view.endEditing(true);
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.activityIndicator.stopAnimating()

                                    })
                                    }
                                                                                
                    }, //if error print error
                        error: { (fault: Fault?) in
                        print("\(String(describing: fault))")
                        
                        self.warningLabel.text = "Server Error."
                            //stop receiving touches
                            self.view.endEditing(true);
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.activityIndicator.stopAnimating()

                    })
                    
                    
                } else {
                    //is valid email else block
                    
                    //change warning text
                    warningLabel.text = "Invalid email."
                    self.view.endEditing(true);
                }
                
                
            } else {
                //check that emails match else block
                
                //change warning text
                warningLabel.text = "Emails do not match."
                self.view.endEditing(true);
            }
        } else {
            //check username is valid else block
            
            //changeWarning text
            warningLabel.text = "Invalid username. Username should be longer than 8 characters, less than 18, and only consist of letters, numbers, and underscores."
            self.view.endEditing(true);
        }
        
        //resume touches
        
        
        
    }
    
    //check email in external method wth regex
    func isValidEmail(testStr:String) -> Bool {
        //create valid email regex
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        //set up regex test
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        //execute regex test
        return emailTest.evaluate(with: testStr)
    }
    
    
    //check username in external method wth regex
    func isValidUsername(testStr:String) -> Bool {
        //create valid username regex
        let usernameRegEx = "^[0-9a-zA-Z\\_]{8,18}$"
        
        //set up regex test
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        //execute regex test
        return usernameTest.evaluate(with: testStr)
    }
    
    
    //do eventually
    /*//Check backend to see if email is available
     func emailIsNotAlreadyTaken(testStr:String) -> Bool{
     
     
     }
     */
    
    /*//Check backend to see if username is available
     func usernameIsNotAlreadyTaken(testStr:String) -> Bool{
     
     
     }
     */
    
    //swipe right
    @IBAction func swipeRight(_ sender: Any){
        
        performSegue(withIdentifier: "openingFromRegister", sender: nil);
    }
    
    
    //override functions
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
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
