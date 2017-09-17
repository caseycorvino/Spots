//
//  editMySpotsViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/27/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class editMySpotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editMySpotsCell", for: indexPath)
        
        cell.textLabel?.text = mySpots[indexPath.row].Title
        
        return cell
        
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
     }
 
    
    
     // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let spotsBackend = backendless?.data.of(Spot().ofClass())
        if editingStyle == .delete {
            // Delete the row from the data source
            print("deleting")
            spotsBackend?.remove(mySpots[indexPath.row], response: { (num: NSNumber?) in
                print("succesful remove")
                mySpots.remove(at: indexPath.row)
                self.table.reloadData()
                
            }, error: { (fault: Fault?) in
                //display alert
                print(fault ?? "Fault")
                let errorString: String! = String(describing: fault)
                self.displayAlert("Unable To Delete Spot", message: "Error: \(errorString)")
                self.table.reloadData()
            }
            )
        }
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
