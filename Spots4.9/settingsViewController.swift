//
//  settingsViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/20/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    var backendless = Backendless.sharedInstance()
    
    @IBOutlet var table: UITableView!
    
    
    @IBOutlet var backButtonView: UIView!
    
    let settingsCategories = ["MY ACCOUNT", "MY SPOTS", "MORE" ]
    
    let settingsArray = [["Edit Basic Info"] , ["Edit My Spots"], ["About Spots", "Contact", "Terms of Services and Privacy Policy"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButtonView.backgroundColor = silver
        
//        //declare gestures
//        let swipeLeft = UISwipeGestureRecognizer()
//        
//        //choose method to run when swiped
//        swipeLeft.addTarget(self, action: #selector(OpeningViewController.swipeLeft))
//        
//        //set directions of swipes
//        swipeLeft.direction = .left
//        
//        //add gestures to view
//        self.view!.addGestureRecognizer(swipeLeft)
        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButton(_ sender: Any) {
        
        backendless?.userService.logout({ (result: Any?) in
            print("User has been logged out")
            activeUser = BackendlessUser();
            activeUserId = "";
             //fromBackButton = false;
            self.performSegue(withIdentifier: "settingsToOpening", sender: nil)
        },
                                        
            error: { (fault: Fault?) in
                //todo display alert
            print("Server reported an error: \(String(describing: fault?.message))")
        })
    }
    
    
    @IBAction func back(_ sender: Any) {
        // fromBackButton = true;
        self.performSegue(withIdentifier: "settingsToActiveMap", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsCategories[section]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return settingsArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = settingsArray[indexPath.section][indexPath.row]
        
        return cell
        
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0,0]:
            performSegue(withIdentifier: "settingsToEditBasicInfo", sender: nil)
            break;
        case [1,0]:
            performSegue(withIdentifier: "settingsToEditMySpots", sender: nil)
            break;
        case [2,0]:
            performSegue(withIdentifier: "settingsToAboutSpots", sender: nil)
            break;
        case [2,1]:
            if let url = URL(string: "mailto:caseycorvino@nyu.edu") {
                UIApplication.shared.open(url)
            }
            break;
        case [2,2]:
            performSegue(withIdentifier: "settingsToTermsOfServices", sender: nil)
            break;
        default:
            break;
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
//    @IBAction func swipeLeft(_ sender: Any){
//        
//        performSegue(withIdentifier: "settingsToActiveMap", sender: nil);
//    }
//    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
