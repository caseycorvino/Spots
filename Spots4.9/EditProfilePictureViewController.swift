//
//  EditProfilePictureViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 10/2/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class EditProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var ProfilePictureImageView: UIImageView!
    
    @IBOutlet var EditProfilePictureButton: UIButton!
    
    var picServices = ProfilePicServices()
    
    let picker = UIImagePickerController()
    
    var oldImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helper.putBorderOnButton(buttonView: EditProfilePictureButton, radius: 25)
        helper.putBorderOnButton(buttonView: ProfilePictureImageView, radius: 120)

        picker.delegate = self
       
        picServices.getProfPicSync(userId: activeUserId, imageView: ProfilePictureImageView)
        oldImage = ProfilePictureImageView.image
        // Do any additional setup after loading the view.
        
    }
    @IBAction func EditProfilePictureButtonClicked(_ sender: Any) {
        
        //do a a lot of shit
        picker.allowsEditing = false;
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .popover
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
        
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ProfilePictureImageView.image = image
        } else{
            print("Error loading image from camera roll")
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if(oldImage == ProfilePictureImageView.image){
            performSegue(withIdentifier: "backToSettings", sender: nil)
        } else {
            let alert = UIAlertController(title: "Submit changes?", message: "Do you want to change your profile picture?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction((UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backToSettings", sender: nil)
            })))
            
            alert.addAction((UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                self.picServices.uploadProfilePic(profPic: self.ProfilePictureImageView.image!)
                alert.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backToSettings", sender: nil)
            })))
            self.present(alert, animated: true, completion: nil)
        }
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
