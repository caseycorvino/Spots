//
//  beforeViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/14/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class beforeViewController: UIViewController {


    //declare server
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if logged in
        backendless?.userService.isValidUserToken({
            (result : NSNumber?) -> Void in
            if(result?.boolValue == true){
                DispatchQueue.main.async(execute: {
                    activeUser = (self.backendless?.userService.currentUser)!
                    activeUserId = activeUser.objectId as String!
                    self.performSegue(withIdentifier: "toActiveMap", sender: nil)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "toOpening", sender: nil)
                })
            }
            
            print("Is login valid? - \(result?.boolValue ?? false)")
        },
                                                 error: {
                                                    (fault : Fault?) -> Void in
                                                    DispatchQueue.main.async(execute: {
                                                        self.performSegue(withIdentifier: "toOpening", sender: nil)
                                                    })
                                                    print("Server reported an error: \(fault?.message ?? "fault")")
        })

        
        // Do any additional setup after loading the view.
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
