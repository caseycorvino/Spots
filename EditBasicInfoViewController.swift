//
//  EditBasicInfoViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/26/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class EditBasicInfoViewController: UIViewController {

    @IBOutlet var submitButtonView: UIView!
    
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    //instantiate backend
    var backendless  = Backendless.sharedInstance()
    
    var userName = NSString()
    var userEmail = NSString()
   
    var flag: Bool = false;
    var errorMessage = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButtonView.layer.borderColor = UIColor.gray.cgColor
        submitButtonView.layer.borderWidth = 1
        submitButtonView.layer.cornerRadius = 25
        submitButtonView.layer.masksToBounds = true;
        
        userName = activeUser.name
        usernameField.text = userName as String
       
        userEmail = activeUser.email
        emailField.text = userEmail as String
        
        passwordField.isHidden = true;
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    
    @IBAction func backbutton(_ sender: Any) {
        performSegue(withIdentifier: "editBasicInfoToSettings", sender: nil)
        //_ = self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func submitButton(_ sender: Any) {
        
        flag = false;
        errorMessage = ""
        
        setUsername(completionHandler: {
           
            self.setEmail(completionHandler: {
               
                if self.flag{
                    self.displayAlert("Sumbit error", message: self.errorMessage)
                } else {
                    self.displayAlertAndSegue("Basic Info Updated", message: "")
                }
            })
        })
        
    }
    
    func setUsername(completionHandler: @escaping () -> ()) -> Void{
        let newUsername: String! = usernameField.text?.lowercased()
        
        if(newUsername != userName.lowercased as String){
            if(isValidUsername(testStr: newUsername!)){
                let user = activeUser
                let query = DataQueryBuilder().setWhereClause("name = '\(newUsername!)'")
                _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query,
                                                                              //when complete check if found
                    response: { ( userObjects: [Any]?) in
                        
                        //if user found
                        if (userObjects?.count)! > 0{
                            self.view.endEditing(true);
                            print("Username is already taken")
                            self.flag = true;
                            self.errorMessage = "Username is already taken"
                            completionHandler()
                            
                        } else{
                            
                            user.name = newUsername! as NSString
                            self.backendless?.userService.update(user, response: { (updatedUser: BackendlessUser?) in
                                print("name changed to \(updatedUser?.name ?? "")")
                                activeUser.name = newUsername! as NSString
                                completionHandler()
                            }, error: { (fault: Fault?) in
                                print(fault?.message ?? "fault")
                                self.flag = true;
                                self.errorMessage = "Server Error"
                                completionHandler()
                            })
                        }
                        
                        
                },//if error print error
                    error: { (fault: Fault?) in
                        print(fault?.message ?? "")
                        self.flag = true;
                        self.errorMessage = "Server Error"
                        self.view.endEditing(true);
                        completionHandler()
                })
                
            } else{
                print("invalid username")
                flag = true;
                errorMessage = "Invalid username"
                completionHandler()
            }
        } else {
            //display alert
            print("same username")
            completionHandler()
        }

    }
    
    func setEmail(completionHandler: @escaping () -> ()) -> Void {
        
        let newEmail: String! = emailField.text?.lowercased()
        
        if(newEmail != userEmail.lowercased as String){
            if(isValidEmail(testStr: newEmail!)){
                let user = activeUser
                let query = DataQueryBuilder().setWhereClause("email = '\(newEmail!)'")
                _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query,
                                                                              //when complete check if found
                    response: { ( userObjects: [Any]?) in
                        
                        //if user found
                        if (userObjects?.count)! > 0{
                            self.view.endEditing(true);
                            print("email is already taken")
                            self.flag = true;
                            self.errorMessage = "Email is already taken"
                            completionHandler()
                            
                        } else{
                            print("Username is available")
                            user.email = newEmail! as NSString
                            self.backendless?.userService.update(user, response: { (updatedUser: BackendlessUser?) in
                                print("email changed to \(updatedUser?.email ?? "")")
                                activeUser.email = newEmail! as NSString
                                completionHandler()
                            }, error: { (fault: Fault?) in
                                print(fault ?? "fault")
                                self.flag = true;
                                self.errorMessage = "Server Error"
                                completionHandler()
                            })
                        }
                        
                        
                },//if error print error
                    error: { (fault: Fault?) in
                        print("\(String(describing: fault))")
                        self.view.endEditing(true);
                        self.flag = true;
                        self.errorMessage = "Server Error"
                        completionHandler()
                })
                
            } else{
                print("invalid email")
                self.flag = true;
                self.errorMessage = "Invalid email"
                completionHandler()
            }
        } else {
            //display alert
            print("same email")
            completionHandler()
        }

        
    }
    
    
    
    //check username in external method wth regex
    func isValidUsername(testStr:String) -> Bool {
        //create valid username regex
        let usernameRegEx = "^[0-9a-zA-Z\\_]{6,18}$"
        
        //set up regex test
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        //execute regex test
        return usernameTest.evaluate(with: testStr)
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
    
    func displayAlertAndSegue(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "editBasicInfoToSettings", sender: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
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
