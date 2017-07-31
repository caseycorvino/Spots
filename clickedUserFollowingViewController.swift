//
//  FollowingViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/27/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class clickedUserFollowingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var clickedUserFollowingCount: UILabel!
    
    @IBOutlet var followingTable: UITableView!
    
    var oldActiveUserFollowing: [BackendlessUser] = [];
    
    var backendless = Backendless.sharedInstance()
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clickedUserFollowingCount.text = "\(clickedUserFollowing.count)"
        oldActiveUserFollowing = clickedUserFollowing
        filteredResult = clickedUserFollowing
        
        searchBar.placeholder = "\(clickedUser.name ?? "")'s Following"
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResult.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO
        if let cell: FollowTableViewCell = tableView.dequeueReusableCell(withIdentifier: "followCell", for: indexPath) as? FollowTableViewCell{
            
            let followUser = filteredResult[indexPath.row]
            cell.followName.text = followUser.name! as String
            cell.cellUser = followUser
            cell.followButtonBackground.layer.cornerRadius = 10;
            cell.followButtonBackground.layer.masksToBounds = true
            cell.followButtonBackground.layer.borderWidth = 1
            cell.followImageView.backgroundColor = silver
            cell.followImageView.backgroundColor = silver
            cell.followImageView.layer.cornerRadius = 20;
            cell.followImageView.layer.masksToBounds = true;
            
            if(userInList(user: cell.cellUser, list: activeUserFollowing)){
                cell.followButton.setTitle("Following", for: UIControlState.normal)
                cell.followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
                cell.followButtonBackground.backgroundColor = silver;
                cell.followButtonBackground.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.followButton.setTitle("Follow", for: UIControlState.normal)
                cell.followButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
                cell.followButtonBackground.backgroundColor = UIColor.white;
                cell.followButtonBackground.layer.borderColor = UIColor.black.cgColor
            }
            
            cell.followButton.tag = indexPath.row
            cell.followButton.addTarget(self, action: #selector(self.followButtonClicked(sender:)), for: .touchUpInside)
            
            // cell.followImg.image =
            
            if(cell.cellUser.objectId == activeUserId as NSString){
                cell.followButtonBackground.isHidden = true;
            } else {
                cell.followButtonBackground.isHidden = false;
            }
            
            return cell
        }
        
        print("error with \(filteredResult[indexPath.row].objectId)")
        
        return UITableViewCell()
        
    }
    
    func followButtonClicked(sender: UIButton?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let buttonIndex = sender?.tag
        let cell: FollowTableViewCell = followingTable.cellForRow(at: [0,buttonIndex!]) as! FollowTableViewCell
       
        if(userInList(user: cell.cellUser, list: activeUserFollowing)){
            cell.followButton.setTitle("Follow", for: UIControlState.normal)
            cell.followButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            cell.followButtonBackground.backgroundColor = UIColor.white;
            cell.followButtonBackground.layer.borderColor = UIColor.black.cgColor
            
            
            let dataStore = backendless?.data.of(Followers.ofClass())
            let query = DataQueryBuilder().setWhereClause("following = '\(cell.cellUser.objectId ?? "")' and follower = '\(activeUserId)'")
            dataStore?.find(query,
                            response: { (datas: [Any]?) in
                                if((datas?.count)! > 0){
                                    
                                    for data in datas!{
                                        dataStore?.remove(data, response: {(num: NSNumber?) in
                                            for (index, element) in activeUserFollowing.enumerated() {
                                                if cell.cellUser.name ?? "" == element.name ?? ""{
                                                    activeUserFollowing.remove(at: index)
                                                }
                                            }
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        }
                                            , error: { (fault: Fault?) in
                                                print(fault?.message ?? "fault")
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                        })
                                    }
                                }
            },
                            error: { (fault: Fault?) in
                                print(fault?.message ?? "fault")
                                UIApplication.shared.endIgnoringInteractionEvents()
            })
            
            
            
        } else {
            
            
            
            cell.followButton.setTitle("Following", for: UIControlState.normal)
            cell.followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            cell.followButtonBackground.backgroundColor = silver;
            cell.followButtonBackground.layer.borderColor = UIColor.white.cgColor
           
            let dataStore = backendless?.data.of(Followers.ofClass())
            let newFollow = Followers()
            newFollow.follower = "\(activeUserId)"
            newFollow.following = "\(cell.cellUser.objectId ?? "")"
            
            dataStore?.save(newFollow, response: { (new: Any?) in
                
//                self.calculateFollowing(completionHandler: {
//                    print("Active User now following \(cell.cellUser.name ?? "")")
//                })
                activeUserFollowing.append(cell.cellUser)
                UIApplication.shared.endIgnoringInteractionEvents()
                //do same thing
            }, error: { (fault: Fault?) in
                print( fault?.message ?? "fault")
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            
        }
        
    }
    
    func userInList(user: BackendlessUser, list: [BackendlessUser] ) -> Bool {
        
        for backUser in list {
            if backUser.name == user.name{
                return true
            }
        }
        return false
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        clickedUser = filteredResult[indexPath.row]
        
        performSegue(withIdentifier: "clickedUserFollowingToClickedUser", sender: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func calculateFollowing(completionHandler: @escaping () -> ()) -> Void {
//        
//        let query = DataQueryBuilder().setWhereClause("follower = '\(activeUserId)'")
//        
//        
//        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
//                                                                
//                                                                response: { ( anyObjects: [Any]?) in
//                                                                    
//                                                                    //fill followers Array.
//                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
//                                                                    
//                                                                    let followingCount = anyObjects?.count
//                                                                    
//                                                                    //empty array
//                                                                    activeUserFollowing.removeAll()
//                                                                    
//                                                                    
//                                                                    let followerObjects = anyObjects as! [Followers]
//                                                                    print("Clicked User Followers: \(followerObjects.count)")
//                                                                    
//                                                                    
//                                                                    if(followerObjects.count == 0){
//                                                                        completionHandler()
//                                                                    }
//                                                                    var count = 0;
//                                                                    print("Clicked User Following: \(followerObjects.count)")
//                                                                    for followerObject: Followers in followerObjects {
//                                                                        self.backendless?.userService.find(byId: followerObject.following,
//                                                                                                           response: { (followingUser: BackendlessUser!) in
//                                                                                                            activeUserFollowing.append(followingUser)
//                                                                                                            count += 1;
//                                                                                                            if(count == followerObjects.count){
//                                                                                                                completionHandler()
//                                                                                                            }
//                                                                                                            
//                                                                                                            
//                                                                        }, error: { (fault: Fault?) in
//                                                                            print(fault?.message ?? "Fault")
//                                                                            print("Could not load following")
//                                                                            completionHandler();
//                                                                        })
//                                                                    }
//                                                                    
//                                                                    self.clickedUserFollowingCount.text = "\(followingCount!)"
//                                                                    
//                                                                    
//                                                                    
//        },//if error print error
//            error: { (fault: Fault?) in
//                print(fault?.message ?? "fault")
//                completionHandler();
//        })
//        
//        
//    }
    
    
    
    var filteredResult: [BackendlessUser] = [BackendlessUser]()
    
    
    func  searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.characters.count < 2){
            filteredResult = clickedUserFollowing
            followingTable.reloadData()
        } else {
            //loadData
            
            updateSearchedUsers(searchText: searchText, completionHandler: {
                self.followingTable.reloadData()
            })
        }
        
    }
    
    func updateSearchedUsers(searchText: String, completionHandler: @escaping () -> ()){
        filteredResult.removeAll()
        
        for user in clickedUserFollowing{
            
            if user.name.lowercased.contains(searchText.lowercased())
            {
                filteredResult.append(user)
            }
        }
        completionHandler()
    }
    
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    //keyboard dismissed on scroll
    func  scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    //keyboard dismissed on search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "clickedUserFollowingToClickedUser", sender: nil)
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
