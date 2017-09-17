//
//  FollowServices.swift
//  Spots4.9
//
//  Created by Casey Corvino on 9/13/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation

class FollowServices {
    
    //=======================Calculate Followers====================//
    
    var backendless = Backendless.sharedInstance()
    
    
    func calculateFollowers(userId: String, followersLabel: UILabel, view: UIViewController, completionHandler: @escaping () -> ()) -> Void {
        
        
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
                                                                
                                                                response: { ( anyObjects: [Any]?) in
                                                                    
                                                                    //fill followers Array.
                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                                                    
                                                                    let followersCount = anyObjects?.count
                                                                    
                                                                    let followerObjects = anyObjects as! [Followers]
                                                                    print("\(userId) Followers: \(followerObjects.count)")
                                                                    
                                                                    //empty array
                                                                    //activeUserFollowers.removeAll()
                                                                    
                                                                    
                                                                    if(followerObjects.count == 0){
                                                                        completionHandler()
                                                                    }
                                                                    //activeUserFollowers = followerObjects
                                                                    
                                                                    //todo: comment out
                                                                    //var count = 0;
                                                                    
                                                                    var whereQuery = "objectId = "
                                                                    
                                                                    
                                                                    for (index, followerObject) in followerObjects.enumerated() {
                                                                        
                                                                        if(index != followerObjects.count - 1){
                                                                            
                                                                            whereQuery += "'\(followerObject.follower)' OR objectId = "
                                                                            
                                                                        } else {
                                                                            whereQuery += "'\(followerObject.follower)'"
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                    _ = query2?.setPageSize(100).setOffset(0)
                                                                    
                                                                    _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                        
                                                                        if let _ : FollowersViewController = view as? FollowersViewController{
                                                                            activeUserFollowers.removeAll()
                                                                            activeUserFollowers = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        }
                                                                        if let _ : clickedUserFollowersViewController = view as? clickedUserFollowersViewController {
                                                                            clickedUserFollowers.removeAll()
                                                                            clickedUserFollowers = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        }
                                                                        
                                                                        
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler();
                                                                            
                                                                    })
                                                                    
                                                                    
                                                                    followersLabel.text = "\(followersCount!)"
                                                                    
                                                                    
        },//if error print error
            error: { (fault: Fault?) in
                print("\(String(describing: fault))")
                completionHandler();
                
        })
        
    }
    
    
    //=======================Calculate Following====================//
    
    
    func calculateFollowing(userId: String, followingLabel: UILabel, view: UIViewController, completionHandler: @escaping () -> ()) -> Void {
        
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
                                                                
                                                                response: { ( anyObjects: [Any]?) in
                                                                    
                                                                    //fill followers Array.
                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                                                    
                                                                    let followingCount = anyObjects?.count
                                                                    
                                                                    //empty array
                                                                    //activeUserFollowing.removeAll()
                                                                    
                                                                    
                                                                    let followerObjects = anyObjects as! [Followers]
                                                                    print("\(userId) Following: \(followerObjects.count)")
                                                                    
                                                                    
                                                                    if(followerObjects.count == 0){
                                                                        completionHandler()
                                                                    }
                                                                    
                                                                    
                                                                    var whereQuery = "objectId = "
                                                                    
                                                                    
                                                                    for (index, followerObject) in followerObjects.enumerated() {
                                                                        
                                                                        if(index != followerObjects.count - 1){
                                                                            
                                                                            whereQuery += "'\(followerObject.following)' OR objectId = "
                                                                            
                                                                        } else {
                                                                            whereQuery += "'\(followerObject.following)'"
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                    _ = query2?.setPageSize(100).setOffset(0)
                                                                    
                                                                    _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                        
                                                                        
                                                                        if let _ : FollowingViewController = view as? FollowingViewController{
                                                                            activeUserFollowing.removeAll()
                                                                            activeUserFollowing = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        }
                                                                        if let _ : clickedUserFollowingViewController = view as? clickedUserFollowingViewController {
                                                                            clickedUserFollowing.removeAll()
                                                                            clickedUserFollowing = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        }
                                                                        
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler();
                                                                            
                                                                    })
                                                                    
                                                                    
                                                                    followingLabel.text = "\(followingCount!)"
                                                                    
                                                                    
                                                                    
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler();
        })
        
        
    }
    
    func calculateFollowingSearch(userId: String, view: UIViewController, completionHandler: @escaping () -> ()) -> Void {
        
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
                                                                
                                                                response: { ( anyObjects: [Any]?) in
                                                                    
                                                                    //fill followers Array.
                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                                                    
                                                                    
                                                                    
                                                                    //empty array
                                                                    //activeUserFollowing.removeAll()
                                                                    
                                                                    
                                                                    let followerObjects = anyObjects as! [Followers]
                                                                    print("\(userId) Following: \(followerObjects.count)")
                                                                    
                                                                    
                                                                    if(followerObjects.count == 0){
                                                                        completionHandler()
                                                                    }
                                                                    
                                                                    
                                                                    var whereQuery = "objectId = "
                                                                    
                                                                    
                                                                    for (index, followerObject) in followerObjects.enumerated() {
                                                                        
                                                                        if(index != followerObjects.count - 1){
                                                                            
                                                                            whereQuery += "'\(followerObject.following)' OR objectId = "
                                                                            
                                                                        } else {
                                                                            whereQuery += "'\(followerObject.following)'"
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                    _ = query2?.setPageSize(100).setOffset(0)
                                                                    
                                                                    _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                        
                                                                        
                                                                        
                                                                        activeUserFollowing.removeAll()
                                                                        activeUserFollowing = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        
                                                                        
                                                                        
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler();
                                                                            
                                                                    })
                                                                    
                                                                    
                                                                    
                                                                    
                                                                    
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler();
        })
        
        
    }
    
    
    //=======================^Calculate Following^====================//
    
    
    //=======================Follow user====================//
    
    func followUserInActiveUserTable(user: BackendlessUser, FollowingCount: UILabel!, completionHandler: @escaping() -> ()) {
        let dataStore = backendless?.data.of(Followers.ofClass())
        let newFollow = Followers()
        newFollow.follower = "\(activeUserId)"
        newFollow.following = "\(user.objectId ?? "")"
        
        dataStore?.save(newFollow, response: { (new: Any?) in
            //                self.calculateFollowing(completionHandler: {
            //                    print("\(activeUserId) now following \(cell.cellUser.objectId ?? "")")
            //
            //                })//do same thing
            activeUserFollowing.append(user)
            if(FollowingCount != nil){
                FollowingCount.text = "\(activeUserFollowing.count)";
            }
            
            let deviceId = user.getProperty("deviceId")!
            helper.publishPushNotification(message: "New Follower!", deviceId: deviceId as? String ?? "")
            
            followingList.append(user.objectId as String)
            print("add" + (user.objectId as String))
            //            self.adjustFollowerCount(user: user, count: 1, completionHandler: {
            //                completionHandler()
            //            })
            
            completionHandler()
            //UIApplication.shared.endIgnoringInteractionEvents()
            
        }, error: { (fault: Fault?) in
            print("fault")
            completionHandler()
            //UIApplication.shared.endIgnoringInteractionEvents()
        })
        
    }
    
    
    
    
    
    
    //=======================Unfollow user====================//
    
    func unfollowUserInActiveUserTable(user: BackendlessUser, FollowingCount: UILabel!,completionHandler: @escaping() -> ()){
        
        
        let dataStore = backendless?.data.of(Followers.ofClass())
        let query = DataQueryBuilder().setWhereClause("following = '\(user.objectId ?? "")' and follower = '\(activeUserId)'")
        dataStore?.find(query,
                        response: { (datas: [Any]?) in
                            if((datas?.count)! > 0){
                                
                                for data in datas!{
                                    dataStore?.remove(data, response: {(num: NSNumber?) in
                                        //                                            self.calculateFollowing(completionHandler: {
                                        //                                                print(num!)
                                        //                                            })//do same thing to activeUserFollowing
                                        for (index, element) in activeUserFollowing.enumerated() {
                                            if user.name ?? "" == element.name ?? ""{
                                                activeUserFollowing.remove(at: index)
                                                
                                            }
                                        }
                                        for (index, element) in followingList.enumerated() {
                                            if user.objectId as String == element {
                                                followingList.remove(at: index)
                                                print("removed" + element + (user.objectId as String))
                                            }
                                        }
                                        if(FollowingCount != nil){
                                            FollowingCount.text = "\(activeUserFollowing.count)"
                                        }
                                        
                                        //                                        self.adjustFollowerCount(user: user, count: -1, completionHandler: {
                                        //                                            completionHandler()
                                        //                                        })
                                        
                                        completionHandler();
                                        //UIApplication.shared.endIgnoringInteractionEvents()
                                    }
                                        , error: { (fault: Fault?) in
                                            print(fault ?? "fault")
                                            completionHandler()
                                            //UIApplication.shared.endIgnoringInteractionEvents()
                                    })
                                }
                            }
        },
                        error: { (fault: Fault?) in
                            print(fault ?? "fault")
                            completionHandler()
                            //UIApplication.shared.endIgnoringInteractionEvents()
        })
        
        
        
    }

    //================get follower count===================//
    
    func getFollowerCount (userId: String, followerButton: UIButton,completionHandler: @escaping ()->()) {
        let dataStore = self.backendless?.persistenceService.of(Followers.ofClass())
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    
                                    
                                    followerButton.setTitle("\(objectCount ?? 0)", for: .normal)
                                    print("Found follower objects: \(objectCount ?? 0)")
                                    completionHandler()
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknonw fault")")
                                    completionHandler()
        })
    }
    
    func getFollowingCount (userId: String, followingButton: UIButton,completionHandler: @escaping ()->()) {
        let dataStore = self.backendless?.persistenceService.of(Followers.ofClass())
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    followingCount = Int(objectCount!)
                                    
                                    followingButton.setTitle("\(objectCount ?? 0)", for: .normal)
                                    print("Found following objects: \(objectCount ?? 0)")
                                    completionHandler()
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                    completionHandler()
        })
    }
    
    //================^get follower count===================//
    
    
    func setFollowingList(followingButton: UIButton, completionHandler: @escaping () -> ()){
        
        print("okay")
        
        followingList.removeAll()
        
        
        let query = DataQueryBuilder().setWhereClause("follower = '\(activeUserId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        let dataStore = self.backendless?.data.of(Followers().ofClass())
        
        _ = dataStore?.find(query,
                            
                            response: { ( anyObjects: [Any]?) in
                                
                                //fill followers Array.
                                //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                
                                
                                
                                let followerObjects = anyObjects as! [Followers]
                                for f in followerObjects{
                                    followingList.append(f.following)
                                }
                                
                                
                                
                                self.retrieveNextFollowingPage(query: query!, data: dataStore!, completionHandler: {
                                    completionHandler()
                                })
                                
                                
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler()
                
        })
        
        
        
    }
    
    
    
    func  retrieveNextFollowingPage(query: DataQueryBuilder, data:IDataStore,completionHandler: @escaping () -> () ) -> Void {
        print("\(followingList.count) < \(followingCount) ")
        if(followingList.count < followingCount){
            
            _ = query.prepareNextPage()
            
            data.find(query, response: { (anyObjects: [Any]?) in
                let followerObjects = anyObjects as! [Followers]
                
                for f in followerObjects{
                    followingList.append(f.following)
                }
                self.retrieveNextFollowingPage(query: query, data: data, completionHandler: {
                    completionHandler()
                })
                
            }, error: { (fault: Fault?) in
                print(fault?.description ?? "fault")
                completionHandler()
            })
            
            
        } else {
            completionHandler()
        }
    }
    
    
}
