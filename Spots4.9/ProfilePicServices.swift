//
//  UserServices.swift
//  Spots4.9
//
//  Created by Casey Corvino on 10/1/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import Foundation

class ProfilePicServices{
    
    var backendless = Backendless.sharedInstance()
    
    func uploadProfilePic(profPic: UIImage) -> Void{
        
        print("\n============ Uploading profile picture with the ASYNC API ============")
        
        let compressedPic = profPic.resizeWith(width: 255)
        
        let data = UIImageJPEGRepresentation(compressedPic!, 1)
        
        
        backendless?.file.saveFile("ProfilePicture/\(activeUserId).jpeg", content: data! as Data, overwriteIfExist: true, response: { (file: BackendlessFile?) in
             print("Upload Succesful. File URL is - \(file?.fileURL ?? "PATH ERROR")")
        }, error: { (fault: Fault?) in
            print("Error: \(fault?.description ?? "Unknown Fault")")
        })
        
    }
    
    
    var gottenPic: UIImage?;
    
//    func getProfilePicture(userId: String, imageView: UIImageView, completionHandler: @escaping ()->()){
//        
////        getRequestForProfPic(userId: userId, completionHandler: {
////            completionHandler()
////        })
//       fetchProfilePicture(userId: userId, imageView: imageView, completionHandler: {
//            completionHandler()
//        })
//        
//    }
//    
//    
//    func getRequestForProfPic(userId: String, completionHandler: @escaping () -> ()){
//        
//        var request = URLRequest(url: URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")!)
//        request.httpMethod = "GET"
//        //request.addValue(<#T##value: String##String#>, forHTTPHeaderField: <#T##String#>)
//        let session = URLSession.shared
//        
//        session.dataTask(with: request) {data, response, err in
//            
//            if(err == nil){
//                if let res = response as? HTTPURLResponse{
//                    print("Response code: \(res.statusCode)")
//                    
//                
//                    if let im: UIImage = UIImage(data: (data! as NSData) as Data){
//                        self.gottenPic = im;
//                        completionHandler();
//                    } else {
//                        print("==========Image is nil")
//                        completionHandler()
//                    }
//                } else {
//                    print("unknown response code, some unknown error")
//                    self.gottenPic = nil
//                    completionHandler()
//                }
//            } else {
//                
//                print("Error fetching Profile Pic: \(err ?? "error" as! Error)")
//                completionHandler();
//            }
//            
//            }.resume()
//
//        
//        
//    }
//    
//    func fetchProfilePicture(userId: String, imageView: UIImageView, completionHandler: @escaping () -> ()){
//        
//        let url = URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")!
//        let session = URLSession(configuration: .default)
//        let picTask = session.dataTask(with: url) { (data, response, error) in
//            if error != nil {
//                print("Could not download Pictire with error: \(error ?? "Unknown error" as! Error)")
//            } else {
//                
//                if let res = response as? HTTPURLResponse {
//                    print("Response Code: \(res.statusCode)")
//                    if let im: UIImage = UIImage(data: (data! as NSData) as Data){
//                        print(url)
//                        self.gottenPic = im;
//                        imageView.image = im;
//                       
//                        completionHandler();
//                    } else {
//                        print("===========Image is nil")
//                        self.gottenPic = nil
//                         imageView.image = UIImage(named: "default-profile.png")
//                        completionHandler()
//                    }
//                } else {
//                    print("Couldn't get response code for some reason")
//                    completionHandler()
//                }
//            }
//        }
//        
//        picTask.resume()
//    }
    
    func getProfPicAsync(userId: String, imageView: UIImageView, completionHandler: @escaping ()->()){
        let url = URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
                
                completionHandler()
                }} else {
                completionHandler()
            }
        }
    }
    func getProfPicAsync(userId: String, imageView: UIButton, completionHandler: @escaping ()->()){
        let url = URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    imageView.setImage(UIImage(data: data), for: .normal)
                    imageView.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
                    //print("success")
                    completionHandler()
                }} else {
                completionHandler()
            }
        }
    }
    
    func getProfPicSync(userId: String, imageView: UIImageView){
        let url = URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")
        if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageView.image = UIImage(data: data)
        }
    }
    func getProfPicSync(userId: String, imageView: UIButton){
        let url = URL(string: "https://api.backendless.com/CF852600-0A40-34C2-FFC8-7C9C03250600/771A9B0C-C5D0-14AF-FF1C-DFC4B9406800/files/ProfilePicture/\(userId).jpeg")
        if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageView.setImage(UIImage(data: data), for: .normal)
        }
    }
}

extension UIImage {
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
