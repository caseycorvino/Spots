//
//  ClickedUserViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/29/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var clickedUserFollowing: [BackendlessUser] = []

var clickedUserFollowers: [BackendlessUser] = []

//var clickedUserFollowing: [Followers] = [Followers()]
//var clickedUserFollowers: [Followers] = [Followers()]

//instantiate activeUserSpots Array
var clickedUserSpots = [Spot]();

var allClickedUserSpots = [Spot]();

var clickedUser: BackendlessUser = BackendlessUser()

var segueBack: String! = ""

class ClickedUserViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var followingButtonView: UIView!
    @IBOutlet var followersButtonView: UIView!
    @IBOutlet var backButtonView: UIView!
    
    
    @IBOutlet var followButtonBackground: UIView!
    @IBOutlet var clickedUserNameLabel: UILabel!
    
    
    
    //user location for addSpot
    var userLat: Double = 0;
    var userLon: Double = 0;
    
    
    //IBOutlet Map
    @IBOutlet var map: MKMapView!
    
    //IBOutletButtons
    @IBOutlet var followingButton: UIButton!
    @IBOutlet var followersButton: UIButton!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var myAccountButton: UIButton!
    
    //blur effect
    var blurEffect = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    //instantiante user location
    var locationManager = CLLocationManager()
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //instantiate backendless
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //update view backgrounds
        followingButtonView.backgroundColor = silver
        followersButtonView.backgroundColor = silver
        
        
        //update name
        clickedUserNameLabel.text = "\(clickedUser.name ?? "")"
        
        //change user location color
        map.tintColor = UIColor.darkGray
        
        //set up user location
        self.map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        sleep(1)
//        locationManager.stopUpdatingLocation()
        
        blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        blurEffectView.frame = view.bounds
        view.sendSubview(toBack: blurEffectView)
        
        
        myAccountButton.layer.cornerRadius = 36;
        myAccountButton.layer.masksToBounds = true
        myAccountButton.layer.borderWidth = 1
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toggleTable))
        tableButtonView.addGestureRecognizer(gesture)
        
        tableButtonView.backgroundColor = silver
        tableView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        tableSubView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        let blurEffect2 = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect2)
        blurEffectView2.frame = tableSubView.bounds
        blurEffectView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableSubView.addSubview(blurEffectView2)
        tableSubView.sendSubview(toBack: blurEffectView2)
        
        //setUp follow button and background
        followButtonBackground.layer.cornerRadius = 15;
        followButtonBackground.layer.masksToBounds = true
        followButtonBackground.layer.borderWidth = 1
        
        if(followingList.contains(clickedUser.objectId as String)){
            
            followButton.setTitle("Following", for: UIControlState.normal)
            followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            followButtonBackground.backgroundColor = silver;
            followButtonBackground.layer.borderColor = silver.cgColor
            
        } else {
            
            followButton.setTitle("Follow", for: UIControlState.normal)
            followButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            followButtonBackground.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0);
            followButtonBackground.layer.borderColor = UIColor.black.cgColor
        
        }

        if(clickedUser.objectId == activeUserId as NSString){
            followButtonBackground.isHidden = true;
        }
        
        
        //set up activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        
        
        clickedUserSpots.removeAll()
        
//        loadClickedUserSpots(completionHandler: {
//            self.SortSpotsArray()
//            self.calculateClickedFollowers(completionHandler: {
//                
//                self.SortFollowersArray()
//                
//                self.calculateClickedFollowing(completionHandler:{
//                    
//                    self.sortFollowingArray()
//                   
//                    UIApplication.shared.endIgnoringInteractionEvents()
//                    
//                    self.activityIndicator.stopAnimating()
//                    self.view.sendSubview(toBack: self.blurEffectView)
//                    self.tableView.reloadData()
//
//                })
//            })
//        })
        
        loadClickedUserSpots(completionHandler: {
            self.SortSpotsArray()
            followServices.getFollowerCount(userId: clickedUser.objectId as String, followerButton: self.followersButton, completionHandler: {
                followServices.getFollowingCount(userId: clickedUser.objectId as String, followingButton: self.followingButton, completionHandler: {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                    self.view.sendSubview(toBack: self.blurEffectView)
                    self.tableView.reloadData()

                })
            })
        })
        
        setOriginForTableSubView()
        setOriginForTableButtonView()
        setOriginForTableButton()
        setOriginForTableView()
        
        tableButtonView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        locationManager.stopUpdatingLocation()
    }
    
    
    //basic map set up
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        
        let latitude = userLocation.coordinate.latitude
        
        let longitude = userLocation.coordinate.longitude
        
        userLat = latitude
        
        userLon = longitude
        
        let latDelta:CLLocationDegrees = 0.05; //zoom
        
        let lonDelta:CLLocationDegrees = 0.05; //zoom
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta); //map span using zooms
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: false)
        
        self.map.showsUserLocation = true
        
    }
    
    
    @IBAction func followButtonClicked() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if(followingList.contains(clickedUser.objectId as String)){
            followButton.setTitle("Follow", for: UIControlState.normal)
            followButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            followButtonBackground.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0);
            followButtonBackground.layer.borderColor = UIColor.black.cgColor
            
            

            let dataStore = backendless?.data.of(Followers.ofClass())
            let query = DataQueryBuilder().setWhereClause("following = '\(clickedUser.objectId ?? "")' and follower = '\(activeUserId)'")
            dataStore?.find(query,
                            response: { (datas: [Any]?) in
                                if((datas?.count)! > 0){
                                    
                                    for data in datas!{
                                        
                                        dataStore?.remove(data, response: {(num: NSNumber?) in
                                                for (index, element) in clickedUserFollowers.enumerated() {
                                                    if activeUser.name ?? "" == element.name ?? ""{
                                                        clickedUserFollowers.remove(at: index)
                                                    }
                                                }
                                            
                                                for (index, element) in activeUserFollowing.enumerated() {
                                                    if clickedUser.name ?? "" == element.name ?? ""{
                                                        activeUserFollowing.remove(at: index)
                                                    }
                                                }
                                            
                                            for (index, element) in followingList.enumerated() {
                                                if clickedUser.objectId as String == element {
                                                    followingList.remove(at: index)
                                                    
                                                }
                                            }
                                            
                                                //do same thing
//                                              self.followersButton.setTitle("\(clickedUserFollowers.count)", for: UIControlState.normal)
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
            })
        
        } else {
            
            followButton.setTitle("Following", for: UIControlState.normal)
            followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            followButtonBackground.backgroundColor = silver;
            followButtonBackground.layer.borderColor = silver.cgColor;
            
            let dataStore = backendless?.data.of(Followers.ofClass())
            let newFollow = Followers()
            newFollow.follower = "\(activeUserId)"
            newFollow.following = "\(clickedUser.objectId ?? "")"
            
            dataStore?.save(newFollow, response: { (new: Any?) in
                clickedUserFollowers.append(activeUser)
                activeUserFollowing.append(clickedUser)
                followingList.append(clickedUser.objectId as String)
                //self.followersButton.setTitle("\(clickedUserFollowers.count)", for: UIControlState.normal)
                let deviceId = clickedUser.getProperty("deviceId")!
                
                helper.publishPushNotification(message: "New Follower!", deviceId: deviceId as? String ?? "")
                UIApplication.shared.endIgnoringInteractionEvents()
            }, error: { (fault: Fault?) in
                print(fault?.message ?? "fault")
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
    
    
    
    func loadClickedUserSpots(completionHandler: @escaping () -> ()) -> Void{
        
        
        
        let clickedUserId: String! = clickedUser.objectId! as String
        
        let query = DataQueryBuilder().setWhereClause("ownerId = '\(clickedUserId ?? "")'")
        _ = query?.setPageSize(100).setOffset(0)
        //_ = query?.setPageSize(100).setOffset(0)
        _ = self.backendless?.data.of(Spot.ofClass()).find(query,
                                                           
                                                           response: { ( userObjects: [Any]?) in
                                                           
                                                            //fill activeUserSpots Array.
                                                            //fill activeUserSpots Array.
                                                            allClickedUserSpots = userObjects as! [Spot]
                                                            
                                                            let now: Date = NSDate() as Date
                                                            for s in allClickedUserSpots{
                                                                if ((s.startTime as Date) < now) && ((s.endTime as Date) > now) {
                                                                    clickedUserSpots.append(s)
                                                                }
                                                            }
//                                                                                                                      print(clickedUserSpots)
                                                            
                                                            self.putSpotsOnMap(completionHandler: {
                                                                completionHandler()
                                                                
                                                            })
                                                            
                                                            
                                                            
                                                            
        },//if print error
            error: { (fault: Fault?) in
                print("\(String(describing: fault))")
                completionHandler()
                
                
        })
        //completionHandler();
    
    }
    
    func putSpotsOnMap(completionHandler: @escaping () -> ()) -> Void{
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        
        let formatter = DateFormatter()
        
        for spot in clickedUserSpots {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: spot.Latitude, longitude: spot.Longitude)
            annotation.title = spot.Title
            
            formatter.dateFormat = "h:mma"
            let stime = formatter.string(from: spot.startTime as Date)
            let etime = formatter.string(from: spot.endTime as Date)
            let subtitle = "\(stime)-\(etime)"
            
            annotation.subtitle = subtitle
            map.addAnnotation(annotation)
        }
        completionHandler();
        
    }
    



    //custom annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        for childView:AnyObject in view.subviews{
            childView.removeFromSuperview();
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "demo")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "demo")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        let image: UIImage = UIImage.init(named: "directions.png")!
        btn.tintColor = UIColor.black
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = btn
        
        
        let pinImage = UIImage(named: "crosshair.png")
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = newImage
        
        let calloutgesture = UITapGestureRecognizer(target: self, action:  #selector (self.calloutClicked (_:)))
        annotationView?.addGestureRecognizer(calloutgesture)
        
        return annotationView
        
    }
    
    func calloutClicked(_ sender:UITapGestureRecognizer){
        
        //todo. callout clicked
        
        
    }
    
    func  mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        for spot in clickedUserSpots{
            let annotationTitle: String! = (view.annotation?.title)!
            let annotationLat = Double((view.annotation?.coordinate.latitude)!)
            if spot.Title ==  annotationTitle && spot.Latitude == annotationLat {
                clickedSpot = spot
            }
        }
        
    }
    
    func getDirections(){
        let clickedSpotLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: clickedSpot.Latitude, longitude: clickedSpot.Longitude)
        let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: clickedSpotLocation, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = clickedSpot.Title
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    @IBAction func followingButtonClicked(_ sender: Any) {
         //fromBackButton = false;
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "clickedUserFollowingView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
       //performSegue(withIdentifier: "clickedUserToClickedUserFollowing", sender: nil)
        
    }
    
    
    @IBAction func followersButtonClicked(_ sender: Any) {
        // fromBackButton = false;
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "clickedUserFollowersView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "clickedUserToClickedUserFollowers", sender: nil)
        
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any){
    //switch statement of dif segues based on identifier 
        // fromBackButton = true;
        self.navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: segueBack, sender: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //--------------------------------------
    //table view shit
    var tableActive: Bool = false;
    
    @IBOutlet var tableView: UITableView!;
    
    @IBOutlet var tableSubView: UIView!;
    
    @IBOutlet var tableButtonView: UIView!
    
    @IBOutlet var tableButton: UIButton!
    
    @IBAction func changeTableViewStateButton(_ sender: Any) {
        
        toggleTable()
        
    }
    
    func tableButtonDragged(gesture: UIPanGestureRecognizer){
        
        
        //todo
        
        
        
    }
    
    func toggleTable() {
        if(tableActive){
            hideTableView()
        } else {
            showTableView()
        }
        
    }
    
    func setOriginForTableSubView(){
        let height = tableSubView.frame.size.height
        let width = view.frame.size.width
        
        let xPosition = tableSubView.frame.origin.x
        
        let yPosition = view.frame.height - 32
        
        UIView.animate(withDuration: 0.0, animations: {
            
            self.tableSubView.frame = CGRect.init(x: xPosition, y: yPosition, width: width, height: height)
            
        })
    }
    
    func setOriginForTableButtonView(){
        let height = tableButtonView.frame.size.height
        let width = view.frame.size.width
        
        let xPosition = tableButtonView.frame.origin.x
        
        let yPosition = tableButtonView.frame.origin.y
        
        UIView.animate(withDuration: 0.0, animations: {
            
            self.tableButtonView.frame = CGRect.init(x: xPosition, y: yPosition, width: width, height: height)
            
        })
    }
    
    func setOriginForTableButton(){
        
        let height = tableButtonView.frame.size.height
        let width = view.frame.size.width
        tableButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        UIView.animate(withDuration: 0.0, animations: {
            
            self.tableButton.frame.size = CGSize.init(width: width, height: height - 20)
        })
        
    }
    
    func setOriginForTableView(){
        
        let height = tableView.frame.size.height
        let width = view.frame.size.width - 32
        
        UIView.animate(withDuration: 0.0, animations: {
            
            self.tableView.frame.size = CGSize.init(width: width, height: height)
        })
        
    }
    
    func hideTableView(){
        let height = tableSubView.frame.size.height
        let width = tableSubView.frame.size.width
        
        let xPosition = tableSubView.frame.origin.x
        
        let yPosition = tableSubView.frame.origin.y + height - 32
        
        let up = UIImage.init(named: "upbutton.png")
        tableButton.setImage(up, for: .normal)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tableSubView.frame = CGRect.init(x: xPosition, y: yPosition, width: width, height: height)
        })
        tableActive = false;
        
    }
    
    func showTableView(){
        let height = tableSubView.frame.size.height
        let width = tableSubView.frame.size.width
        
        let xPosition = tableSubView.frame.origin.x
        
        let yPosition = tableSubView.frame.origin.y - height + 32
        
        let down = UIImage.init(named: "downbutton.png")
        tableButton.setImage(down, for: .normal)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tableSubView.frame = CGRect.init(x: xPosition, y: yPosition, width: width, height: height)
        })
        tableActive = true;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let spot = clickedUserSpots[indexPath.row]
        let lat = spot.Latitude - 0.004
        let lon = spot.Longitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.map.setRegion(region, animated: true)
        for annotation in map.annotations as [MKAnnotation] {
            if annotation.title ?? "" == spot.Title{
                map.selectAnnotation(annotation, animated: true)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clickedUserSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.spot = clickedUserSpots[indexPath.row]
        cell.spotTitle.text = clickedUserSpots[indexPath.row].Title
        cell.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        cell.spotDateCreated.text = formatter.string(from: clickedUserSpots[indexPath.row].created! as Date)
        
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    //end of table view shit
    //---------------------------------------//
    
    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            map.mapType = .standard
        default:
            map.mapType = .hybrid
        }
    }
    
    func SortSpotsArray(){
        
        clickedUserSpots.sort(by: {($0.startTime as Date).compare($1.startTime as Date) == .orderedDescending})
        
    }
    
    func SortFollowersArray(){
        
        clickedUserFollowers.sort(by: {(($0.getProperty("created")) as! Date).compare($1.getProperty("created") as! Date) == .orderedDescending})
        
    }
    
    func sortFollowingArray(){
        
        clickedUserFollowing.sort(by: {(($0.getProperty("created")) as! Date).compare($1.getProperty("created") as! Date) == .orderedDescending})
        
    }

    @IBOutlet var resetLocationButton: UIButton!
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
        if (Swift.abs(mapView.region.center.latitude - userLat) > 0.001 || Swift.abs(mapView.region.center.longitude - userLon) > 0.001)
        {
            resetLocationButton.isHidden = false;
        } else {
            resetLocationButton.isHidden = true;
        }
    }
    
    @IBAction func resetLocationButtonClicked(_ sender: Any) {
        
        updateLocation()
        
    }
    
    func updateLocation(){
        
        locationManager.startUpdatingLocation()//this runs locationManager()
        
        sleep(1)
        
        locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func TypeSegmentedControlClicked(_ sender: UISegmentedControl!) {
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            SpotsType = "Past";
            //load spots
            let now: Date = Date()
            let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            var removeCount = 0
            clickedUserSpots.removeAll()
            for (index,s) in allClickedUserSpots.enumerated(){
                if ((s.endTime as Date) < now){
                    if ((s.endTime as Date) > yesterday){
                        clickedUserSpots.append(s)
                    } else {
                        spotServices.removeSpot(s: s)
                        allClickedUserSpots.remove(at: index - removeCount)
                        removeCount += 1
                    }
                }
            }
            putSpotsOnMap(completionHandler: {
                
            })
            tableView.reloadData()
            break;
        case 2:
            SpotsType = "Upcoming";
            let now: Date = NSDate() as Date
            clickedUserSpots.removeAll()
            
            
            for s in allClickedUserSpots{
               
                if ((s.startTime as Date) > now) {
                    clickedUserSpots.append(s)
                }
            }
            putSpotsOnMap(completionHandler: {
                
            })
            tableView.reloadData()
            break;
        default:
            SpotsType = "Now";
            let now: Date = NSDate() as Date
            clickedUserSpots.removeAll()
            for s in allClickedUserSpots{
                if ((s.startTime as Date) < now) && ((s.endTime as Date) > now) {
                    clickedUserSpots.append(s)
                }
            }
            putSpotsOnMap(completionHandler: {
                
            })
            tableView.reloadData()
            break;
            
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
