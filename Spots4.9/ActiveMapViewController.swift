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

var mySpots = [Spot]()

var allSpots = [Spot]();

var clickedSpot = Spot()

var SpotsType = "Now"

let helper = Helping();

let followServices = FollowServices();

let spotServices = SpotServices();

var followingCount: Int = 0;

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
    @IBOutlet var addSpotLinkField: UITextField!
    @IBOutlet var addSpotLocationField: UITextField!
    @IBOutlet var addSpotStartTime: UIDatePicker!
    @IBOutlet var addSpotEndTime: UIDatePicker!
    @IBOutlet var addSpotTypeSwitch: UISegmentedControl!
    
    
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
    
    
    
    //profile pick
    @IBOutlet var myAccountButton: UIButton!
    
    
    //instantiante user location
    var locationManager = CLLocationManager()
    
    //instantiate loading icon
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    //instantiate backendless
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        followersButtonView.isHidden = true
        followingButtonView.isHidden = true
        
        
       
        helper.underlineTextField(field: addSpotTitleField)
        helper.underlineTextField(field: addSpotLinkField)
        setForNow()
        
        self.navigationController?.isNavigationBarHidden = true
        
        resetLocationButton.isHidden = true;
        
        //update view backgrounds
        newSpotButtonView.backgroundColor = orange
        searchButtonView.backgroundColor = silver
        followingButtonView.backgroundColor = silver
        followersButtonView.backgroundColor = silver
        settingButtonView.backgroundColor = silver
        
        
        locationResultsTable.isHidden = true
        addSpotLocationField.addTarget(self, action: #selector(locationTextFieldDidChange(textField:)), for: .editingChanged)
        //locationResultsTable.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        
        
        addSpotView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.0)
        addSpotView.isHidden = true
        
        
        //gestures
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toggleTable))
        tableButtonView.addGestureRecognizer(gesture)
        
//        let gestureDrag = UIPanGestureRecognizer(target: self, action: #selector(tableButtonDragged))
//        tableButtonView.addGestureRecognizer(gestureDrag)
//        tableButtonView.isUserInteractionEnabled = true
        
        
        //profile pick
        myAccountButton.layer.cornerRadius = 36;
        myAccountButton.layer.masksToBounds = true
        myAccountButton.layer.borderWidth = 1
        
        
        
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
//        sleep(1)
//        locationManager.stopUpdatingLocation()
        
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

        /*
        followServices.getFollowerCount(userId: activeUserId, followerButton: followersButton, completionHandler: {
            
        })*/
        followServices.getFollowingCount(userId: activeUserId, followingButton: followingButton, completionHandler: {
            
            
        followServices.setFollowingList(followingButton: self.followingButton, completionHandler: {
           
            self.loadFollowingSpots(completionHandler: {
               
                    self.loadActiveUserSpots(completionHandler: {
                        
                                self.SortMySpotsArray()
                        self.tableView.reloadData()
                        self.putSpotsOnMap(completionHandler:  {
                            
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.activityIndicator.stopAnimating()
                            self.view.sendSubview(toBack: self.blurEffectView)
                            self.tableView.reloadData()
                            self.updateCounts(completionHandler: {})
                        })

                })
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
        
        tableButtonView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        //set up user location
       
      
        locationManager.stopUpdatingLocation()
        
        //followServices.getFollowingCount(userId: activeUserId, followingButton: followingButton, completionHandler: {
            
        //})
    
    }
    
    func updateCounts(completionHandler:  @escaping () -> ()){
//        self.followersButton.setTitle("\(activeUserFollowers.count)", for: UIControlState.normal)
//        self.followingButton.setTitle("\(activeUserFollowing.count)", for: UIControlState.normal)
        //update for followingList
        self.followingButton.setTitle("\(followingList.count)", for: UIControlState.normal)
        
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
       
        //todo 
        //query by type
        let query = DataQueryBuilder().setWhereClause("ownerId = '\(activeUserId)'")
        _ = query?.setPageSize(100).setOffset(0)
        _ = self.backendless?.data.of(Spot.ofClass()).find(query,
                                                           
            response: { ( userObjects: [Any]?) in
                
                //fill activeUserSpots Array.
                allSpots += userObjects as! [Spot]
                mySpots = userObjects as! [Spot]
                
                let now: Date = NSDate() as Date
                for s in allSpots{
                    if ((s.startTime as Date) < now) && ((s.endTime as Date) > now) {
                        activeUserSpots.append(s)
                    }
                }
             
               
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
    
    func loadFollowingSpots(completionHandler: @escaping () -> ()) -> Void{
    
        
        var whereQuery = "ownerId = "
        
        
        for (index, user) in followingList.enumerated() {
            
            if(index != followingList.count - 1){
                
                whereQuery += "'\(user)' OR ownerId = "
                
            } else {
                whereQuery += "'\(user)'"
            }
            
            
        }
        
      
        
        if(whereQuery != "ownerId = "){
            
            let query = DataQueryBuilder().setWhereClause(whereQuery)
            _ = query?.setPageSize(100).setOffset(0)
            _ = self.backendless?.data.of(Spot.ofClass()).find(query,
                                                           
                                                           response: { ( userObjects: [Any]?) in
                                                            
                                                            //fill activeUserSpots Array.
                                                            allSpots = userObjects as! [Spot]
                                                            print("loadFollowingSpots succesful")
                                                            completionHandler()
                                                            
                                                            
                                                            
                                                            
            },//if print error
                error: { (fault: Fault?) in
                print("\(String(describing: fault))")
                completionHandler()
                
                
            })
        } else {
            completionHandler()
        }
        
        
        
    }
    
    func putSpotsOnMap(completionHandler: @escaping () -> ()) -> Void{
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        
        let formatter = DateFormatter()
        
        for spot in activeUserSpots {
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
    
    
    /*func calculateFollowers(completionHandler: @escaping () -> ()) -> Void {
        
        helper.calculateFollowers(userId: activeUserId, followersButton: followersButton, view: self, completionHandler: {
            completionHandler();
        })
//        helper.getFollowerCount(followerButton: followersButton, completionHandler: {
//            completionHandler()
//        })
      

    }*/
    
    
    /*func calculateFollowing(completionHandler: @escaping () -> ()) -> Void {
        
        helper.calculateFollowing(userId: activeUserId, followingButton: followingButton, view: self, completionHandler: {
            completionHandler();
        })
        


        
    }*/
    
    @IBAction func newSpotButton(_ sender: Any) {
        
        
        addSpotView.isHidden = false
        addSpotTitleField.becomeFirstResponder()

        addSpotTypeSwitch.selectedSegmentIndex = 0;
        setForNow()
        
        self.view.insertSubview(blurEffectView, at: 11)
       
    }
    
    
    @IBAction func cancelNewSpotButton(_ sender: Any) {
        
        addSpotView.isHidden = true
        
        self.view.endEditing(true)
        //updateMap()
        self.view.sendSubview(toBack: blurEffectView)
        
    }
    
    
    @IBAction func addSpotButton(_ sender: Any) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if (addSpotTitleField.text?.characters.count)! > 5{
            
            let validUrl = spotServices.isValidUrl(urlString: addSpotLinkField.text)
            if(addSpotLinkField.text == "" || (addSpotLinkField.text != "" && validUrl)){
            
                let newSpot = Spot()
                
                newSpot.Title = addSpotTitleField.text!
                if(addSpotLinkField.text != ""){
                    newSpot.url = addSpotLinkField.text!
                }
                
                newSpot.endTime = spotServices.getTimeFor(picker: addSpotEndTime) as NSDate
            
                if(addSpotTypeSwitch.selectedSegmentIndex == 0){
                
                    newSpot.Latitude = userLat
                    newSpot.Longitude = userLon
            
                    newSpot.startTime = addSpotStartTime.clampedDate as NSDate
                    self.uploadNewSpot(newSpot: newSpot)
            
                } else if(addSpotTypeSwitch.selectedSegmentIndex == 1){
                  
                    newSpot.startTime = spotServices.getTimeFor(picker: addSpotStartTime) as NSDate
                    
                
                    getLocationForAddress(newSpot: newSpot, address: addSpotLocationField.text!, completionHandler: {
                        if self.getLocationError == false{
                            self.uploadNewSpot(newSpot: newSpot)
                        }
                    })
                    
                }
                
                
               
                
            } else {
                displayAlert("Invalid Url", message: "Please check url and try again")
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        } else {
            displayAlert("Invalid Title", message: "Title needs to be longer than 5 characters.")
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
        
    }
    var getLocationError =  false
    func getLocationForAddress(newSpot: Spot, address: String, completionHandler: @escaping () -> ()){
        getLocationError =  false

        
        let geoCoder = CLGeocoder()
        
        var err: Error?

        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            if(error == nil){
                newSpot.Latitude = (placemarks?.first?.location?.coordinate.latitude)!
                newSpot.Longitude = (placemarks?.first?.location?.coordinate.longitude)!
                completionHandler()
                
                
            } else {
                err = error!
                print(err.debugDescription)
                helper.displayAlertOK("Invalid Address", message: "Upcoming events require a location", view: self)
                self.getLocationError = true
                completionHandler()
            }
            
            
        }
        
        
    }
    
    @IBAction func settingsButton(_ sender: Any) {
         //fromBackButton = false;

        performSegue(withIdentifier: "activeMapToSettings", sender: nil)
        
    }
    
     
    func uploadNewSpot(newSpot: Spot){
        let dataStore = backendless?.data.of(Spot().ofClass())
        
        dataStore!.save(newSpot,
                        response: {
                            (newSpot) -> () in
                            print("Spot saved and succesfully uploaded to backend")
                            self.view.endEditing(true)
                            self.addSpotView.isHidden = true
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            self.addSpotTitleField.text = ""
                            self.addSpotLinkField.text = ""
                            
                            allSpots.append(newSpot as! Spot)
                            mySpots.append(newSpot as! Spot)
                            //replace with addSpot to activeUserSpots and re annotate map
                            
                            self.TypeSegmentedControlClicked(self.TypeSegmentedControl)
                            
                            self.putSpotsOnMap( completionHandler: {
                                self.view.sendSubview(toBack: self.blurEffectView)
                                self.tableView.reloadData()
                                self.SortSpotsArray()
                                
                            })
                            
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault?.message ?? "Fault"))")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            self.displayAlert("Server Error", message: fault?.message ?? "Fault")
                            
        })
    }
    
//    func updateMap() -> Void {
//        
//        updateLocation()
//        
//        UIApplication.shared.beginIgnoringInteractionEvents()
//        activityIndicator.startAnimating()
//
//        loadActiveUserSpots(completionHandler: {
//            self.putSpotsOnMap(completionHandler: {
//                self.calculateFollowers(completionHandler: {
//                    self.calculateFollowing(completionHandler: {
//                        UIApplication.shared.endIgnoringInteractionEvents()
//                        self.activityIndicator.stopAnimating()
//                    })
//                })
//            })
//        })
//        
//    }
    
    
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
        btn.tintColor = UIColor.black
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
        if(clickedSpot.url != "none"){
            let url = URL(string: clickedSpot.url)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            //handle if no url
        }
        
        
    }
    
    
    
    func  mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        for spot in activeUserSpots{
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
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "followingView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "settingsToFollowing", sender: nil)
    
    }


    @IBAction func followersButtonClicked(_ sender: Any) {
        
         //fromBackButton = false;
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "followersView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "settingsToFollowers", sender: nil)
        
    }
   
    @IBAction func searchButtonClicked(_ sender: Any) {
        // fromBackButton = false;
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "searchView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        //performSegue(withIdentifier: "activeMapToSearch", sender: nil)
    
    }
    
    
    
    //--------------------------------------============//
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
        
        if tableView == self.tableView {
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
        
        if tableView == self.locationResultsTable{
            
            tableView.isHidden = true;
            
            let searchRequest = MKLocalSearchRequest(completion: searchResultsArr[indexPath.row])
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                let pl = response?.mapItems[0].placemark
                let addy = "\(pl?.subThoroughfare ?? "") \(pl?.thoroughfare ?? ""), \(pl?.locality ?? "")"
                self.addSpotLocationField.text = addy
            }
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        if tableView == self.tableView{
            count = activeUserSpots.count
        }
        if tableView == self.locationResultsTable{
           count = searchSource?.count ?? 0
        }
        
        return count!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.tableView){
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.spot = activeUserSpots[indexPath.row]
        cell.spotTitle.text = activeUserSpots[indexPath.row].Title
        cell.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        let stime = formatter.string(from: cell.spot.startTime as Date)
        let etime = formatter.string(from: cell.spot.endTime as Date)
        let subtitle = "\(stime)-\(etime)"

            
        cell.spotDateCreated.text = subtitle
        
        return cell;
        }
        
        else if(tableView == self.locationResultsTable){
        let cell = self.locationResultsTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            cell.textLabel?.text = self.searchSource?[indexPath.row]

            //cell.title.text = self.searchSource?[indexPath.row]
        //            + " " + searchResult.subtitle
            //cell.subtitle?.text = self.searchSourceSub?[indexPath.row]
        
            return cell
        }
        return UITableViewCell()
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
        
        activeUserSpots.sort(by: {($0.startTime as Date).compare($1.startTime as Date) == .orderedDescending})
        
    }
    
    func SortMySpotsArray(){
        
        mySpots.sort(by: {($0.created! as Date).compare($1.created! as Date) == .orderedDescending})
        
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
    
    @IBOutlet var TypeSegmentedControl: UISegmentedControl!
    
    
    
    @IBAction func TypeSegmentedControlClicked(_ sender: UISegmentedControl!) {
        
        switch (sender.selectedSegmentIndex) {
            case 0:
                SpotsType = "Past";
                //load spots
                let now: Date = Date()
                let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                var removeCount = 0;
                activeUserSpots.removeAll()
                for (index,s) in allSpots.enumerated(){
                    if ((s.endTime as Date) < now){
                        if ((s.endTime as Date) > yesterday){
                            activeUserSpots.append(s)
                        } else {
                            spotServices.removeSpot(s: s)
                            
                            allSpots.remove(at: index - removeCount)
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
                activeUserSpots.removeAll()
                
                
                for s in allSpots{
                   
                    if ((s.startTime as Date) > now) {
                        activeUserSpots.append(s)
                    }
                }
                putSpotsOnMap(completionHandler: {
                    
                })
                tableView.reloadData()
                break;
            default:
                SpotsType = "Now";
                let now: Date = NSDate() as Date
                activeUserSpots.removeAll()
                for s in allSpots{
                    if ((s.startTime as Date) < now) && ((s.endTime as Date) > now) {
                        activeUserSpots.append(s)
                    }
                }
                putSpotsOnMap(completionHandler: {
                    
                })
                tableView.reloadData()
                break;
            
        }
        
        
    }
    
    
    
    
    
    
    @IBAction func AddSpotTypeSegmentedControlClicked(_ sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex){
            case 0:
                setForNow()
                break;
            
            case 1:
                setForUpcoming()
                break;
            
            default:
                setForNow()
                break;
            
        }
        
        
        
    }
    
    
    
    
    
    func setForNow(){
        
        helper.underlineTextFieldInactive(field: addSpotLocationField)
        addSpotStartTime.isEnabled = false
        addSpotStartTime.setValue(UIColor.gray, forKeyPath: "textColor")
        addSpotStartTime.setDate(NSDate() as Date, animated: true)
        addSpotEndTime.setDate(NSDate.init(timeIntervalSinceNow: 3600) as Date, animated: true)
        
    }
    func setForUpcoming(){
        
        helper.underlineTextField(field: addSpotLocationField)
        addSpotStartTime.isEnabled = true
        addSpotStartTime.setValue(UIColor.black, forKeyPath: "textColor")
        addSpotStartTime.setDate(NSDate.init(timeIntervalSinceNow: 3600) as Date, animated: true)
        addSpotEndTime.setDate(NSDate.init(timeIntervalSinceNow: 7200) as Date, animated: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        clickedSpot = Spot();
    }
    
    
    
    //location search shit
    
    @IBOutlet var locationResultsTable: UITableView!
    
    //create a completer
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC = MKLocalSearchCompleter()
        sC.delegate = self
        return sC
    }()
    
    var searchResultsArr = [MKLocalSearchCompletion]()
    
    var searchSource: [String]?
    var searchSourceSub: [String]?
    var searchSourceAddress: MKMapItem = MKMapItem()
    
    func locationTextFieldDidChange(textField: UITextField){
        
        if(textField.text == ""){
            locationResultsTable.isHidden = true
            
        } else {
            locationResultsTable.isHidden = false
            searchCompleter.queryFragment = textField.text!
        }
       
        
    }
    
    
    @IBAction func myAccountButtonClicked(_ sender: Any) {
        
        clickedUser = activeUser
        
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "clickedUserView")
        self.navigationController?.pushViewController(nextPage!, animated: true)
        
        
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


extension ActiveMapViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        //get result, transform it to our needs and fill our dataSource
        self.searchSource = completer.results.map { $0.title }
        self.searchSourceSub = completer.results.map { $0.subtitle }
        //self.searchSourceAddress = completer.
        searchResultsArr = completer.results
        
        DispatchQueue.main.async {
            self.locationResultsTable.reloadData()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
    }
}


