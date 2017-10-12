//
//  FollowingViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/27/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var FollowingCount: UILabel!
    
    @IBOutlet var followingTable: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    //var oldActiveUserFollowing: [Follower] = [];
    var oldActiveUserFollowing: [BackendlessUser] = [];
    
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        followServices.calculateFollowing(offset: 0, userId: activeUserId, followingLabel: FollowingCount, view: self, completionHandler: {
            self.FollowingCount.text = "\(activeUserFollowing.count)"
           
            self.oldActiveUserFollowing = activeUserFollowing
            
            self.filteredResult = self.oldActiveUserFollowing;
            self.followingTable.reloadData()
        })
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
            cell.followImageView.layer.cornerRadius = 17;
            cell.followImageView.layer.masksToBounds = true;
            
            if(followingList.contains(cell.cellUser.objectId as String)){
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
            
            if(cell.cellUser.objectId == activeUserId as NSString!){
                cell.followButtonBackground.isHidden = true;
            } else {
                cell.followButtonBackground.isHidden = false;
            }
            
            
            return cell
        }
        
        print("error witth \(activeUserFollowers[indexPath.row].objectId)")
        
        return UITableViewCell()
        
    }
    
    func followButtonClicked(sender: UIButton?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let buttonIndex = sender?.tag
        let cell: FollowTableViewCell = followingTable.cellForRow(at: [0,buttonIndex!]) as! FollowTableViewCell
       
        if(followingList.contains(cell.cellUser.objectId as String)){
            cell.followButton.setTitle("Follow", for: UIControlState.normal)
            cell.followButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            cell.followButtonBackground.backgroundColor = UIColor.white;
            cell.followButtonBackground.layer.borderColor = UIColor.black.cgColor
            
       
            followServices.unfollowUserInActiveUserTable(user: cell.cellUser, FollowingCount: FollowingCount, completionHandler: {
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            

            
            
            
        } else {
            
            
            
            cell.followButton.setTitle("Following", for: UIControlState.normal)
            cell.followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            cell.followButtonBackground.backgroundColor = silver;
            cell.followButtonBackground.layer.borderColor = UIColor.white.cgColor
            
            //let dataStore = backendless?.data.of(Followers.ofClass())
           /* let newFollow = Followers()
            newFollow.follower = "\(activeUserId)"
            newFollow.following = "\(cell.cellUser.objectId ?? "")"*/
            
            followServices.followUserInActiveUserTable(user: cell.cellUser, FollowingCount: nil, completionHandler: {
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
        // fromBackButton = false;
        segueBack = "clickedUserToFollowing"
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "clickedUserView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "followingToClickedUser", sender: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    var filteredResult: [BackendlessUser] = [BackendlessUser]()
    
    
    func  searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
   
        if(searchText.characters.count < 2){
            filteredResult = oldActiveUserFollowing
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
       
        for user in oldActiveUserFollowing{
         
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
    
    @IBAction func backButtonClicked(_ sender: Any) {
         //fromBackButton = true;
        navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "back", sender: nil)
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
