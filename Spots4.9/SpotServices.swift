//
//  SpotServices.swift
//  Spots4.9
//
//  Created by Casey Corvino on 9/13/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation

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
    
    
    
}
