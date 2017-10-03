//
//  searchViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 7/1/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

var searchedUsers: [BackendlessUser] = [BackendlessUser()]

class searchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var searchTable: UITableView!
    
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(activeUserFollowing.count < 1){
        followServices.calculateFollowingSearch(userId: activeUserId, view: self, completionHandler: {
            
     
        if searchedUsers.count > 0{
            if searchedUsers[0].name == nil{
                searchedUsers.removeAll()
                self.searchTable.reloadData()
            }
        }
        })} else {
            if searchedUsers.count > 0{
                if searchedUsers[0].name == nil{
                    searchedUsers.removeAll()
                    self.searchTable.reloadData()
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO
        
        if (searchedUsers[indexPath.row].name) != nil {
        if let cell: FollowTableViewCell = tableView.dequeueReusableCell(withIdentifier: "followCell", for: indexPath) as? FollowTableViewCell{
            let searchUser = searchedUsers[indexPath.row]
            cell.followName.text = searchUser.name! as String
            cell.cellUser = searchUser
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
            
            let profilePicService = ProfilePicServices()
            profilePicService.getProfPicAsync(userId: cell.cellUser.objectId as String, imageView: cell.followImg, completionHandler: {
                
            })
            
            if(cell.cellUser.objectId == activeUserId as NSString!){
                cell.followButtonBackground.isHidden = true;
            }
            
            return cell
            }}
        
        print("error witth \(searchedUsers[indexPath.row].objectId)")
        
        return UITableViewCell()
        
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
        clickedUser = searchedUsers[indexPath.row]
         //fromBackButton = false;
        segueBack = "clickedUserToSearch"
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "clickedUserView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "searchToClickedUser", sender: nil)
    }
    
    
    func followButtonClicked(sender: UIButton?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let buttonIndex = sender?.tag
        let cell: FollowTableViewCell = searchTable.cellForRow(at: [0,buttonIndex!]) as! FollowTableViewCell
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
//                                            self.calculateFollowing(completionHandler: {
//                                                })
                                            //replace with activeUserFollowing.remove(data)
                                            for (index, element) in activeUserFollowing.enumerated() {
                                                if cell.cellUser.name ?? "" == element.name ?? ""{
                                                    activeUserFollowing.remove(at: index)
                                                }
                                            }
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        }
                                            , error: { (fault: Fault?) in
                                                print(fault ?? "fault")
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                        })
                                    }
                                }
            },
                            error: { (fault: Fault?) in
                                print(fault ?? "fault")
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
//                    print("Active User now following \(cell.cellUser.objectId ?? "")")
//                })
                //replace with activeUserFollowing.add(data)
                activeUserFollowing.append(cell.cellUser)
                UIApplication.shared.endIgnoringInteractionEvents()
            }, error: { (fault: Fault?) in
                print("fault")
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            
        }
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
//                                                                    
//                                                                    //empty array
//                                                                    activeUserFollowing.removeAll()
//                                                                    
//                                                                    
//                                                                    let followerObjects = anyObjects as! [Followers]
//                                                                    print("Followers: \(followerObjects.count)")
//                                                                    
//                                                                    
//                                                                    if(followerObjects.count == 0){
//                                                                        completionHandler()
//                                                                    }
//                                                                    var count = 0;
//                                                                    print("Following: \(followerObjects.count)")
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
//                                                                            print(fault ?? "Fault")
//                                                                            print("Could not load following")
//                                                                            completionHandler();
//                                                                        })
//                                                                    }
//                                                                    
//                                                                    
//                                                                    
//                                                                    
//                                                                    
//        },//if error print error
//            error: { (fault: Fault?) in
//                print("\(String(describing: fault))")
//                completionHandler();
//        })
//        
//        
//    }
    
    var count = 0;
    func  searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count < 1){
            searchedUsers.removeAll()
            searchTable.reloadData()
        } else {
            //loadData
        
            UIApplication.shared.beginIgnoringInteractionEvents()
            updateSearchedUsers(searchText: searchText, completionHandler: {_ in
                self.searchTable.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
         
        }
      
    }

    func updateSearchedUsers(searchText: String, completionHandler: @escaping () -> ()){
        
//        searchedUsers.removeAll()
//        
//        
//        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
//        let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%'")
//        
//        dataStore?.find(query, response: { (anyObjects: [Any]?) in
//            searchedUsers = anyObjects as! [BackendlessUser]
//            completionHandler()
//        }, error: { (fault: Fault?) in
//            print(fault  ?? "fault")
//            completionHandler()
//        })
        
        searchedUsers.removeAll()
        
        let toSearch = activeUserFollowing + activeUserFollowers;
        
        for user in toSearch{
            
            if user.name.lowercased.contains(searchText.lowercased())
            {
                if(!userInList(user: user, list: searchedUsers)){
                    searchedUsers.append(user)
                }
            }
        }
        completionHandler()
        
    }
    
    func updateSearchedUsersWithBackend(searchText: String, completionHandler: @escaping () -> ()){
        
        searchedUsers.removeAll()
        
        let toSearch = activeUserFollowing + activeUserFollowers;
        
        for user in toSearch{
            
            if user.name.lowercased.contains(searchText.lowercased())
            {
                if(!userInList(user: user, list: searchedUsers)){
                    searchedUsers.append(user)
                }
            }
        }
        
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%'")
        
        dataStore?.find(query, response: { (anyObjects: [Any]?) in
            for user in anyObjects as! [BackendlessUser]{
               
                if(!self.userInList(user: user, list: searchedUsers)){
                    
                    searchedUsers.append(user)
                }
            }
            completionHandler()
        }, error: { (fault: Fault?) in
            print(fault  ?? "fault")
            completionHandler()
        })

    }
    
    @IBAction func back(_ sender: Any) {
        
        searchedUsers.removeAll()
         //fromBackButton = true;
        self.navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "searchToActiveMap", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.searchBar.endEditing(true)
        print(searchBar.text!)
        updateSearchedUsersWithBackend(searchText: searchBar.text!, completionHandler: {
             self.searchTable.reloadData()
            UIApplication.shared.endIgnoringInteractionEvents()
        })
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
