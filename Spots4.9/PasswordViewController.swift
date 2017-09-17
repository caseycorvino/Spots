//
//  PasswordViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/13/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {

    //IBOutlet instance variables
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var confirmPasswordField: UITextField!
    
    @IBOutlet var background: UIView!
    
    @IBOutlet var warningLabel: UILabel!
    
    @IBOutlet var nextButtonView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //background.backgroundColor = silver;
        nextButtonView.layer.cornerRadius = 25
        nextButtonView.layer.masksToBounds = true;
        
       
        helper.putBorderOnButton(buttonView: nextButtonView, radius: 25)
        helper.underlineTextField(field: passwordField)
        helper.underlineTextField(field: confirmPasswordField)
        
        // Do any additional setup after loading the view.
    }
    
    //clicked next button checks fields then goes to password page
    @IBAction func next(_ sender: Any) {
        
        //reset warning
        
        //stop receiving touches
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //set field.text to temporary email vars
        let checkPassword: String = passwordField.text!
        let checkConfirmPassword: String = confirmPasswordField.text!

        
        if(checkPassword == checkConfirmPassword){
            if(isValidPassword(testStr: checkPassword)){
            //set signup variables
            signupPassword = checkPassword
            
            //segue to next step
                self.performSegue(withIdentifier: "passwordToTermsOfServices", sender: nil)
            } else{
                warningLabel.text = "Password must be longer than 8 characters and have at least three lowercase letters."
                self.view.endEditing(true);
            }
            
        } else {
            //change warning text
            warningLabel.text = "Passwords do not match."
            self.view.endEditing(true);
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    //check password in external method wth regex
    func isValidPassword(testStr: String) -> Bool{
        //create valid email regex
        let passwordRegEx = "^(?=.*[a-z].*[a-z].*[a-z]).{8,30}"
        //at least 3 undercase letters, length 8
        
        //set up regex test
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        //execute regex test
        return passwordTest.evaluate(with: testStr)
    }
    
    @IBAction func passwordToRegister(_ sender: Any) {
        
        performSegue(withIdentifier: "passwordToRegister", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
