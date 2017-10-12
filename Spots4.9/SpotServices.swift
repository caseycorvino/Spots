//
//  SpotServices.swift
//  Spots4.9
//
//  Created by Casey Corvino on 9/13/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation

var followersDeviceIds = [String]()

class SpotServices{
    
    var backendless = Backendless.sharedInstance()
    
    //================is valid link===========//
    
    func isValidUrl(urlString: String?) -> Bool {
        //Check for nil
        if(urlString != ""){
            if let urlString = urlString {
                // create NSURL instance
                if let url = NSURL(string: urlString) {
                    // check if your application can open the NSURL instance
                    return UIApplication.shared.canOpenURL(url as URL)
                }
            }
            return false
        }else {
            return false
        }
    }
    
    
    
    //================^is valid link regex===========//
    
    //===============set dates for time ================//
    
    func getTimeFor(picker: UIDatePicker) -> Date{
        let time = picker.clampedDate
        if (time < NSDate() as Date){
            let newTime = Calendar.current.date(byAdding: .day, value: 1, to: time)
            return newTime!
        }
        return time
    }
    
    //===============^set dates for time ================//
    
    //===============remove spot from backend ================//
    func removeSpot(s: Spot){
        let dataStore = backendless?.data.of(Spot().ofClass())
        
        dataStore?.remove(byId: s.objectId,
                          response: {
                            (num : NSNumber?) -> () in
                            print("spott removed")
        },
                          error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault?.description ?? "unknown fault")")
        })
        
        
    }
    
    //===============^remove spot from backend ================//
    
        func setFollowersDeviceIds(completionHandler: @escaping () -> ()){
            
            //print("okay")
            
            followersDeviceIds.removeAll()
            
            
            let query = DataQueryBuilder().setWhereClause("following = '\(activeUserId)'")
            
            _ = query?.setPageSize(100).setOffset(0)
            
            let dataStore = self.backendless?.data.of(Followers().ofClass())
            
            _ = dataStore?.find(query,
                                
                                response: { ( anyObjects: [Any]?) in
                                    
                                    //fill followers Array.
                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                    
                                    
                                    
                                    let followerObjects = anyObjects as! [Followers]
                                    for f in followerObjects{
                                        if(f.followingDeviceId != "" || f.followingDeviceId != "empty"){
                                            followersDeviceIds.append(f.followingDeviceId)
                                        } else {
                                            followersDeviceIds.append("empty")
                                        }
                                    }
                                    
                                    
                                    
                                    self.retrieveNextFollowersDeviceIdsPage(query: query!, data: dataStore!, completionHandler: {
                                        completionHandler()
                                    })
                                    
                                    
            },//if error print error
                error: { (fault: Fault?) in
                    print("\(fault?.message ?? "fault"))")
                    completionHandler()
                    
            })
            
            
            
        }
        
        
        
        func  retrieveNextFollowersDeviceIdsPage(query: DataQueryBuilder, data:IDataStore,completionHandler: @escaping () -> () ) -> Void {
            print("\(followersDeviceIds.count) < \(followerCount) ")
            if(followersDeviceIds.count < followerCount){
                
                _ = query.prepareNextPage()
                
                data.find(query, response: { (anyObjects: [Any]?) in
                    let followerObjects = anyObjects as! [Followers]
                    
                    for f in followerObjects{
                        if(f.followingDeviceId != "" || f.followingDeviceId != "empty"){
                            followersDeviceIds.append(f.followingDeviceId)
                        } else {
                            followersDeviceIds.append("empty")
                        }
                    }

                    self.retrieveNextFollowersDeviceIdsPage(query: query, data: data, completionHandler: {
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
        
        
    func sendPushNotificationsToFollowers(){
        setFollowersDeviceIds(completionHandler: {
            for device in followersDeviceIds{
                if(device != "empty"){
                    helper.publishPushNotification(message: "\(activeUser.name) just added a new Spot!", deviceId: device)
                }
            }
        })
        
    }
    
    
    
    
}
