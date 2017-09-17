//
//  Helper.swift
//  Spots4.9
//
//  Created by Casey Corvino on 8/3/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

//universal color declarations for the rest of the app
var orange: UIColor = UIColor.init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
var silver: UIColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
var clear: UIColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)

 var followingList: [String] = []

class Helping{
    
    var backendless = Backendless.sharedInstance()
    
    //==============Send Push Notification To Singular Device ==================//
    
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
    
    //============== ^Send Push Notification To Singular Device^ ==================//
    
   

    
    //==================buttons==================//
    func putBorderOnButton(buttonView: UIView, radius: Int ){
        
        buttonView.layer.borderColor = UIColor.black.cgColor
        buttonView.layer.borderWidth = 1
        buttonView.layer.cornerRadius = CGFloat(radius)
        buttonView.layer.masksToBounds = true;
        
    }
    
    
    //==================blur background view==================//
    func blurView(buttonView: UIView){
        
        buttonView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        
        //blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = buttonView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        buttonView.insertSubview(blurEffectView, at: 0)
        
        
    }
    
   
    ///===========text field=======================//
    func underlineTextField(field : UITextField){
        
        field.isEnabled = true;
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: field.frame.size.height)
    
        border.borderWidth = width
        field.layer.addSublayer(border)

    
    }
    func underlineTextFieldInactive(field : UITextField){
        
        field.isEnabled = false;
        field.text = ""
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = silver.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: field.frame.size.height)
        
        border.borderWidth = width
        field.layer.addSublayer(border)
        
        
    }
    
    
    
    //===========Dispay Alert==============//
    
    func displayAlertOK(_ title: String, message: String, view :UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    //===========^Dispay Alert^==============//
    
   
    
    
}





extension UIDatePicker {
    
    public var clampedDate: Date {
        let referenceTimeInterval = self.date.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTimeInterval.truncatingRemainder(dividingBy: TimeInterval(minuteInterval*60))
        let timeRoundedToInterval = referenceTimeInterval - remainingSeconds
        return Date(timeIntervalSinceReferenceDate: timeRoundedToInterval)
    }
    
}













