//
//  ActiveMapViewController.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/14/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation


var activeUserFollowing: [BackendlessUser] = []

var activeUserFollowers: [BackendlessUser] = []

//var activeUserFollowing: [Followers] = [Followers()]
//var activeUserFollowers: [Followers] = [Followers()]

//instantiate activeUserSpots Array
var activeUserSpots = [Spot]();

var clickedSpot = Spot()


class ActiveMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    //IBOutlet Views
    @IBOutlet var newSpotButtonView: UIView!
    @IBOutlet var searchButtonView: UIView!
    @IBOutlet var followingButtonView: UIView!
    @IBOutlet var followersButtonView: UIView!
    @IBOutlet var settingButtonView: UIView!
    
    //overlay view
    @IBOutlet var addSpotView: UIView!
    @IBOutlet var addSpotTitleField: UITextField!
    
    @IBOutlet var resetLocationButton: UIButton!
    
    //user location for addSpot
    var userLat: Double = 0;
    var userLon: Double = 0;
    
    //blur effect
    var blurEffect = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    //IBOutlet Map
    @IBOutlet var map: MKMapView!
    
    //IBOutletButtons
    @IBOutlet var followingButton: UIButton!
    @IBOutlet var followersButton: UIButton!
    
    //instantiante user location
    var locationManager = CLLocationManager()
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    //instantiate backendless
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetLocationButton.isHidden = true;
        
        //update view backgrounds
        newSpotButtonView.backgroundColor = orange
        searchButtonView.backgroundColor = silver
        followingButtonView.backgroundColor = silver
        followersButtonView.backgroundColor = silver
        settingButtonView.backgroundColor = silver
        
        addSpotView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.0)
        addSpotView.isHidden = true
        
        
        //gestures
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toggleTable))
        tableButtonView.addGestureRecognizer(gesture)
        
//        let gestureDrag = UIPanGestureRecognizer(target: self, action: #selector(tableButtonDragged))
//        tableButtonView.addGestureRecognizer(gestureDrag)
//        tableButtonView.isUserInteractionEnabled = true
        
        
        
        blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        blurEffectView.frame = view.bounds
        view.sendSubview(toBack: blurEffectView)
        
        
        //change user location color
        map.tintColor = UIColor.darkGray
        
        //set up user location
        self.map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        sleep(1)
        locationManager.stopUpdatingLocation()
        
        //set up activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        
        activeUserSpots.removeAll()
        
        loadActiveUserSpots(completionHandler: {
            self.calculateFollowers(completionHandler: {
                self.SortFollowersArray()
                self.calculateFollowing(completionHandler:{
                    self.SortFollowersArray()
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
        tableButtonView.backgroundColor = silver
        tableView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        tableSubView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        let blurEffect2 = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect2)
        blurEffectView2.frame = tableSubView.bounds
        blurEffectView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableSubView.addSubview(blurEffectView2)
        tableSubView.sendSubview(toBack: blurEffectView2)
    }

    
    
    
    //basic map set up
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        
        let longitude = userLocation.coordinate.longitude
        
        userLat = Double(userLocation.coordinate.latitude)
        userLon = Double(userLocation.coordinate.longitude)
        
        let latDelta:CLLocationDegrees = 0.05; //zoom
        
        let lonDelta:CLLocationDegrees = 0.05; //zoom
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta); //map span using zooms
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: false)
        
        self.map.showsUserLocation = true

    }
    
    func loadActiveUserSpots(completionHandler: @escaping () -> ()) -> Void{
       
        
        let query = DataQueryBuilder().setWhereClause("ownerId = '\(activeUserId)'")
        _ = self.backendless?.data.of(Spot.ofClass()).find(query,
                                                           
            response: { ( userObjects: [Any]?) in
                
                //fill activeUserSpots Array.
                activeUserSpots = userObjects as! [Spot]
                self.SortSpotsArray()
                self.putSpotsOnMap(completionHandler: {
                    completionHandler()
                })
                
                
                
                
        },//if print error
            error: { (fault: Fault?) in
                print("\(String(describing: fault))")
               completionHandler()
                
                
        })
    }
    
    func putSpotsOnMap(completionHandler: @escaping () -> ()) -> Void{
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        
        let formatter = DateFormatter()
        
        for spot in activeUserSpots {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: spot.Latitude, longitude: spot.Longitude)
            annotation.title = spot.Title
            
            formatter.dateFormat = "MM/dd/yyyy"
            let subtitle = formatter.string(from: spot.created! as Date)
           
            annotation.subtitle = subtitle
            map.addAnnotation(annotation)
        }
        completionHandler();
        
    }
    
    
    func calculateFollowers(completionHandler: @escaping () -> ()) -> Void {
        
       
        let query = DataQueryBuilder().setWhereClause("following = '\(activeUserId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
                                                           
                                                                response: { ( anyObjects: [Any]?) in
                                                                    
                                                                    //fill followers Array.
                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                                                    
                                                                    let followersCount = anyObjects?.count
                                                                    
                                                                    let followerObjects = anyObjects as! [Followers]
                                                                    print("Active User Followers: \(followerObjects.count)")
                                                                    
                                                                    //empty array
                                                                    activeUserFollowers.removeAll()
                                                                    
                                                                    
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
                                                                        
                                                                    
                                                                        activeUserFollowers = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                    
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler();
                                                                            
                                                                    })
                                                                    
//                                                                    for followerObject: Followers in followerObjects {
//                                                                        self.backendless?.userService.find(byId: followerObject.follower,
//                                                                                                           response: { (followerUser: BackendlessUser!) in
//                                                                                                            activeUserFollowers.append(followerUser)
//                                                                                                            count += 1;
//                                                                                                            if(count == followerObjects.count){
//                                                                                                                completionHandler()
//                                                                                                            }
//                                                                                                            
//                                                                                                            
//                                                                        }, error: { (fault: Fault?) in
//                                                                            print(fault ?? "Fault")
//                                                                            print("Could not load following")
//                                                                             completionHandler();
//                                                                        })
//                                                                    }
                                                                   
                                                                    
                                                                    self.followersButton.setTitle("\(followersCount!)", for: UIControlState.normal)
                                                                    
                                                            
        },//if error print error
            error: { (fault: Fault?) in
                print("\(String(describing: fault))")
               completionHandler();
                
        })

    }
    
    
    func calculateFollowing(completionHandler: @escaping () -> ()) -> Void {
        
        let query = DataQueryBuilder().setWhereClause("follower = '\(activeUserId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        _ = self.backendless?.data.of(Followers.ofClass()).find(query,
                                                                
                                                                response: { ( anyObjects: [Any]?) in
                                                                    
                                                                    //fill followers Array.
                                                                    //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                                                    
                                                                    let followingCount = anyObjects?.count
                                                                    
                                                                    //empty array
                                                                    activeUserFollowing.removeAll()
                                                                    
                                                                    
                                                                    let followerObjects = anyObjects as! [Followers]
                                                                    print("Active User Following: \(followerObjects.count)")
                                                                    
                                                                   
                                                                    if(followerObjects.count == 0){
                                                                        completionHandler()
                                                                    }
                                                                    
                                                                    //activeUserFollowing = followerObjects
                                                                    
                                                                    
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
                                                                        
                                                                        
                                                                        activeUserFollowing = followUsers as! [BackendlessUser];                                                                        completionHandler()
                                                                        
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler();
                                                                            
                                                                    })
                                                                    
                                                                    //todo: comment out
//                                                                    var count = 0;
//                                                                    for followerObject: Followers in followerObjects {
//                                                                        self.backendless?.userService.find(byId: followerObject.following,
//                                                                                                           response: { (followingUser: BackendlessUser!) in
//                                                                            activeUserFollowing.append(followingUser)
//                                                                                                            count += 1;
//                                                                                                            if(count == followerObjects.count){
//                                                                                                                completionHandler()
//                                                                                                            }
//                                                                                                           
//                                                                            
//                                                                        }, error: { (fault: Fault?) in
//                                                                            print(fault ?? "Fault")
//                                                                            print("Could not load following")
//                                                                             completionHandler();
//                                                                        })
//                                                                        }
                                                                    
                                                                    self.followingButton.setTitle("\(followingCount!)", for: UIControlState.normal)
                                                   
                                                                    
                                                                    
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler();
        })

        
    }
    
    @IBAction func newSpotButton(_ sender: Any) {
        
        
        addSpotView.isHidden = false
        addSpotTitleField.becomeFirstResponder()
        
        
        
       
        self.view.insertSubview(blurEffectView, at: 9)
        
    }
    
    
    @IBAction func cancelNewSpotButton(_ sender: Any) {
        
        addSpotView.isHidden = true
        
        self.view.endEditing(true)
        //updateMap()
        self.view.sendSubview(toBack: blurEffectView)
        
    }
    
    
    @IBAction func addSpotButton(_ sender: Any) {
        
        if (addSpotTitleField.text?.characters.count)! > 5{
            let newSpot = Spot()
            newSpot.Title = addSpotTitleField.text!
            newSpot.Latitude = userLat
            newSpot.Longitude = userLon
            
            
            let dataStore = backendless?.data.of(Spot().ofClass())
            
            dataStore!.save(newSpot,
                            response: {
                                (newSpot) -> () in
                                print("Spot saved and succesfully uploaded to backend")
                                self.view.endEditing(true)
                                self.addSpotView.isHidden = true
                                
                                self.addSpotTitleField.text = ""
                                activeUserSpots.append(newSpot as! Spot)
                                //replace with addSpot to activeUserSpots and re annotate map
                                self.putSpotsOnMap( completionHandler: {
                                     self.view.sendSubview(toBack: self.blurEffectView)
                                })
                               
            },
                            error: {
                                (fault : Fault?) -> () in
                                print("Server reported an error: \(fault?.message ?? "Fault"))")
                                self.displayAlert("Server Error", message: fault?.message ?? "Fault")
            })
            
            
            
            
        } else {
            displayAlert("Invalid Title", message: "Title needs to be longer than 5 characters.")
        }
        
        
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        
        performSegue(withIdentifier: "activeMapToSettings", sender: nil)
    }
    
     
    
    func updateMap() -> Void {
        
        updateLocation()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()

        loadActiveUserSpots(completionHandler: {
            self.putSpotsOnMap(completionHandler: {
                self.calculateFollowers(completionHandler: {
                    self.calculateFollowing(completionHandler: {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.activityIndicator.stopAnimating()
                    })
                })
            })
        })
        
    }
    
    
    func updateLocation(){
        
        locationManager.startUpdatingLocation()//this runs locationManager()
        
        sleep(1)
        
        locationManager.stopUpdatingLocation()
        
    }
    
    
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
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
        
        return annotationView
        
    }
    
    func  mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for spot in activeUserSpots{
            let annotationTitle: String! = (view.annotation?.title)!
            if spot.Title ==  annotationTitle{
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
    
        performSegue(withIdentifier: "settingsToFollowing", sender: nil)
    
    }


    @IBAction func followersButtonClicked(_ sender: Any) {
        
        
        performSegue(withIdentifier: "settingsToFollowers", sender: nil)
        
    }
   
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "activeMapToSearch", sender: nil)
    
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
        let spot = activeUserSpots[indexPath.row]
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
        return activeUserSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.spot = activeUserSpots[indexPath.row]
        cell.spotTitle.text = activeUserSpots[indexPath.row].Title
        cell.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        cell.spotDateCreated.text = formatter.string(from: activeUserSpots[indexPath.row].created! as Date)
        
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    //end of table view shit
    //---------------------------------------//
    
    
    
    //toggle map style
    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            map.mapType = .standard
        default:
            map.mapType = .hybrid
        }
    }

    
    func SortSpotsArray(){
        
        activeUserSpots.sort(by: {($0.created! as Date).compare($1.created! as Date) == .orderedDescending})
        
    }
    
    func SortFollowersArray(){
        
        activeUserFollowers.sort(by: {(($0.getProperty("created")) as! Date).compare($1.getProperty("created") as! Date) == .orderedDescending})
    
    }
    
    func sortFollowingArray(){
        
        activeUserFollowing.sort(by: {(($0.getProperty("created")) as! Date).compare($1.getProperty("created") as! Date) == .orderedDescending})

    }
    
    
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
    
    
    
    //status bar
//    override var prefersStatusBarHidden : Bool {
//        return true;
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
