//
//  ViewController.swift
//  locationMonitoringSupportSystemSwift
//
//  Created by Kubota Naoyuki on 2017/05/03.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate,MKMapViewDelegate {
    

    @IBOutlet var mapViewJ: MKMapView!
    
    var locationManager = CLLocationManager();
    var markerArray : [NSManagedObject] = [];
    
    var markerArrayWithMyAnnotationObjects : [MyAnnotation] = [];
    var timerForNotifications : Timer!;
    
    //For the notification to send
    let myNotification = Notification.Name(rawValue: "MyNotification");

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Remove all annotations
        for item in mapViewJ.annotations {
            mapViewJ.removeAnnotation(item);
        }
        
        let annotationNumber = mapViewJ.annotations.count;
        print("\(annotationNumber)");
        
        markerArray.removeAll();
        markerArrayWithMyAnnotationObjects.removeAll();
        
        //Request permission to authorization in order to zoom to the user's location
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        //Test
        let annotationObject = MyAnnotation(title: "Hello", comment: "This is a test", latitude: 34.5, longtitude: 34.5);
        
        self.displaYNotifiction(marker: annotationObject);
        
        //Check if we have allowed authorization
        var userLocation : CLLocation!
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.delegate = self;
            
            userLocation = locationManager.location;
            
            print("The Latitude is:\(userLocation.coordinate.latitude)");
            print("The longtitude is:\(userLocation.coordinate.longitude)");
            
            let usrLatitude = userLocation.coordinate.latitude;
            let usrLongtitude = userLocation.coordinate.longitude;
            let latLongDelta : CLLocationDegrees = 0.5;
            let span = MKCoordinateSpanMake(latLongDelta, latLongDelta);
            let location = CLLocationCoordinate2DMake(usrLatitude, usrLongtitude);
            let region = MKCoordinateRegionMake(location, span);
            mapViewJ.setRegion(region, animated: true);
        }
        
        //Add timer to the application so it can send notification to the phone
        timerForNotifications = Timer.scheduledTimer(timeInterval: 9.0, target: self, selector: #selector(self.sendNotification), userInfo: nil, repeats: true);
        
        //Add gesture recognizer to the map
        let gestureRecognizer = UILongPressGestureRecognizer(target:self , action:#selector(self.addPinToMap(gestureRecognizer:)));
        gestureRecognizer.minimumPressDuration = 1.0;
        //let gg = UILongPressGestureRecognizer
        gestureRecognizer.delegate = self;
        mapViewJ.addGestureRecognizer(gestureRecognizer);
        
        //Load the markers to the map from the coreData
        self.fetchData();
        self.getElementsFromArrayAsAnObject();
        self.displayMarkersOnTheMap();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("We are updating location");
        
        let userLocationValue:CLLocationCoordinate2D = (manager.location?.coordinate)!;
        let usrLocation = CLLocation(latitude: userLocationValue.latitude, longitude: userLocationValue.longitude);
        
        //Calculate the distance between the coordinates
        for pins in markerArrayWithMyAnnotationObjects {
            
            let markerLocation = CLLocation(latitude: pins.pinLat, longitude: pins.pinLong);
            let distanceBetWeenLoc = self.distanceBetweenTwoLocations(sourceLoc: usrLocation, destinationLocation: markerLocation);
            
            //Check if we have inseide the range of the point
            if distanceBetWeenLoc <= 50 {
                pins.beingInRange = true;
                self.displaYNotifiction(marker: pins);
            }
            else{
                pins.beingInRange = false;
            }
            
        }
    }
    
    func sendNotification(timer: Timer) {
        for marker in markerArrayWithMyAnnotationObjects {
            if marker.beingInRange {
                //Send notification
                self.displaYNotifiction(marker: marker);
            }
        }
    }
    
    func displaYNotifiction(marker:MyAnnotation){
        
        let nc = NotificationCenter.default;
        nc.post(name: myNotification, object: nil, userInfo: ["Title:\(marker.pinTitle)": "Message:\(marker.pinComment)"]);
        
    }
    
    
    func distanceBetweenTwoLocations(sourceLoc:CLLocation,destinationLocation:CLLocation) -> Double{
        let distanceMeters = sourceLoc.distance(from: destinationLocation);
        return distanceMeters;
        
    }
    
    func addPinToMap(gestureRecognizer: UITapGestureRecognizer){
        let location = gestureRecognizer.location(in: mapViewJ);
        let coordinate = mapViewJ.convert(location, toCoordinateFrom: mapViewJ);
        
        //add the annotation
        let myAnnotation = MKPointAnnotation();
        myAnnotation.coordinate = coordinate;
        
        //Clear the map from annotiona
        //Remove all annotations
        for item in mapViewJ.annotations {
            mapViewJ.removeAnnotation(item);
        }
        
        //Open the new viewcontroller for adding title
        let titleViewController : ViewControllerAddNotes = ViewControllerAddNotes();
        titleViewController.gottenLat = coordinate.latitude as Double;
        titleViewController.gottenLong = coordinate.longitude as Double;
        self.present(titleViewController, animated: true, completion: nil);
        
        //mapViewJ.addAnnotation(myAnnotation);
    }
    
    //Add button to the annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MyAnnotation) {
            
            //If the annotation is not the user annotation we set our view otherwise return
            let userAnnotation = annotation;
            let userAnnotationTitle = userAnnotation.title! as String!;
            
            if userAnnotationTitle != "My Location" {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash));
                
                
                
                let deleteButton = UIButton();
                //TODO add bin icon to the button as a picture
                deleteButton.setTitle("消", for: UIControlState.normal);
                deleteButton.setTitleColor(UIColor.blue, for: UIControlState.normal);
                deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
                deleteButton.tag = annotation.hash;
                
                pinView.animatesDrop = true;
                pinView.canShowCallout = true;
                pinView.rightCalloutAccessoryView = deleteButton;
                
                return pinView;
            }
            else{
                return nil;
            }
            
        }
        else{
            return nil;
        }
        
    }
    
    //Add action to the button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let marker = view.annotation //as! MyAnnotation!;
        let lat = marker?.coordinate.latitude;
        let long = marker?.coordinate.longitude;
        
        let alertCobtrollerForDeletingObject = UIAlertController(title: "Deleting marker", message: "Are you sure you want to delete the following marker? \(((marker?.title)!)! as String))", preferredStyle: .alert);
        let alertActionOkay = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            self.deleteItemFromCoreData(title: ((marker?.title)!)!, comment: ((marker?.subtitle)!)!, latitude: lat!, longtitude: long!);
            self.reloadPinsOnTheMap(annotation: marker!);
            
            alertCobtrollerForDeletingObject.dismiss(animated: true, completion: nil);
        }
        let alertActionNo = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
            alertCobtrollerForDeletingObject.dismiss(animated: true, completion: nil);
        }
        
        alertCobtrollerForDeletingObject.addAction(alertActionOkay);
        alertCobtrollerForDeletingObject.addAction(alertActionNo);
        
        self.present(alertCobtrollerForDeletingObject, animated: true, completion: nil);
        
        
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        print("The root view just vanished");
        //Make the view equal to nil in order to call the ViewDidLoad again
        self.view = nil;
        markerArray.removeAll();
        markerArrayWithMyAnnotationObjects.removeAll();
        
        //Remove all annotations
        for item in mapViewJ.annotations {
            mapViewJ.removeAnnotation(item);
        }
    }
    
    //Core data functions
    
    func fetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext;
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Marker");
        do {
            markerArray = try managedContext.fetch(fetchRequest);
            print("Marker array count \(markerArray.count)");
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)");
        }
        
    }
    
    func deleteItemFromCoreData(title:String, comment:String, latitude:Double, longtitude: Double){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext;
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Marker");
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        
        for marker in resultData {
            //managedContext.delete(object)
            let markerTitle = marker.value(forKey: "title") as! String?;
            let markerComment = marker.value(forKey: "comment") as! String?;
            let markerLongtitude = marker.value(forKey: "longtitude") as! Double?;
            let markerLatitude = marker.value(forKey: "latitude") as! Double?;
            
            
            //Check every data to see if we want to delete the same object
            if markerTitle == title {
                if markerComment == comment {
                    if markerLatitude == latitude {
                        if markerLongtitude == longtitude {
                            //TODO delete item from everywhere
                            managedContext.delete(marker);
                            markerArray.remove(at: resultData.index(of: marker)!);
                            print(markerArray.count);
                            //reloadPinsOnTheMap(annotation: <#T##MKAnnotation#>)
                            print("Marker has been deleted from Core data");
                        }
                    }
                }
            }
        }
        
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }

    }
    
    func getElementsFromArrayAsAnObject(){
        
        for marker in markerArray {
            let mTitle = marker.value(forKey: "title");
            let mComment = marker.value(forKey: "comment");
            let mLat = marker.value(forKey: "latitude");
            let mLong = marker.value(forKey: "longtitude");
            
            let myAnnotation = MyAnnotation(title: mTitle as! String, comment: mComment as! String, latitude: mLat as! Double, longtitude: mLong as! Double);
            markerArrayWithMyAnnotationObjects.append(myAnnotation);
        }
        
        print("Array with real objects count \(markerArrayWithMyAnnotationObjects.count)");
    }
    
    func displayMarkersOnTheMap(){
        
        for marker in markerArrayWithMyAnnotationObjects {
            
            let myAnnotation = MKPointAnnotation();
            myAnnotation.coordinate.latitude = marker.pinLat;
            myAnnotation.coordinate.longitude = marker.pinLong;
            myAnnotation.title = marker.pinTitle;
            myAnnotation.subtitle = marker.pinComment;
            
            mapViewJ.addAnnotation(myAnnotation);
            
        }
        
    }
    
    func reloadPinsOnTheMap(annotation : MKAnnotation)
    {
        mapViewJ.removeAnnotation(annotation);
        let mapviewAnnotionaCount = mapViewJ.annotations.count;
        print("We have this many markers \(mapviewAnnotionaCount)");
        
        //Check if we still have the annotation
        for marker in mapViewJ.annotations {
            if marker.title! == annotation.title! {
                if marker.coordinate.latitude == annotation.coordinate.latitude {
                    if marker.coordinate.longitude == annotation.coordinate.longitude {
                        print("We still have the same element")
                        mapViewJ.removeAnnotation(marker);
                    }
                    else{
                        print("Marker has been removed");
                    }
                }
            }
        }
        print("\(markerArrayWithMyAnnotationObjects.count)");
        print("We have this many markers \(mapviewAnnotionaCount)");
    }
    
    

}

