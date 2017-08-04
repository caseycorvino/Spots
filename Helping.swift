//
//  Helper.swift
//  Spots4.9
//
//  Created by Casey Corvino on 8/3/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation
class Helping{
    var backendless = Backendless.sharedInstance()
    
    func publishPushNotification(message: String, deviceId:String) {
        
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-alert":message,
                                      "ios-badge":1,
                                      "ios-sound":"default"])
        
        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        
        backendless?.messaging.publish(
            "default",
            message: message,
            publishOptions:publishOptions,
            deliveryOptions:deliveryOptions,
            response: {
                (status: MessageStatus?) -> Void in
                print("here")
                print("Status: \(status?.errorMessage ?? "Message Success")")
        },
            error: {
                (fault: Fault?) -> Void in
                print("Server reported an error: \(fault?.description ?? "fault")")
        })
    }
    
}
