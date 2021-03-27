//
//  SecondViewController.swift
//  ProjectMap1
//
//  Created by english on 2021-02-03.
//  Copyright © 2021 Chris. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class SecondViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    var choosenPlaceName = ""
    var choosenPlaceId :UUID?
    var latString: String = ""
    var longString: String = ""
    @IBOutlet weak var namelbl: UITextField!
    //MARK:Connection
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLbl: UITextField!
    @IBOutlet weak var latitudeTxt: UITextField!
    @IBOutlet weak var longtitudeTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func savePressed(_ sender: UIButton) {
        if namelbl.text! != ""{
            if descriptionLbl.text! != ""{
                    //when all the textfield are not empty
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appdelegate.persistentContainer.viewContext
                    
                    let newMap = NSEntityDescription.insertNewObject(forEntityName: "Map", into: context)
                    
                    newMap.setValue(namelbl.text!, forKey: "name")
                    newMap.setValue(descriptionLbl.text!, forKey: "nameDescription")
                    if latString != ""{
                        newMap.setValue(Float(latString), forKey: "latitude")
                    }
                    if longString != ""{
                        newMap.setValue(Float(longString), forKey: "longtitude")
                    }
                    
                    newMap.setValue(UUID(), forKey: "id")
                    
                    do{
                        try context.save()
                        print("Success")
                    }catch{
                        print("Error")
                    }
                    
                    //sending notifications
                    NotificationCenter.default.post(name: NSNotification.Name("newMap"), object: nil)
                    //pop the top view controller
                    navigationController?.popViewController(animated: true)

            }
            else{
                namelbl.placeholder = "You must enter name"
            }
        }else{
            descriptionLbl.placeholder = "You must enter desciption"
            }
    }
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataById()
        
        //create 2 textfield to sava latitude and longtitude when user click on tableview to see 1 place
        latitudeTxt.isHidden = true
        longtitudeTxt.isHidden = true
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //set request when app is open
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        //to start fetching the location
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
        namelbl.delegate = self
        descriptionLbl.delegate = self
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location  = CLLocationCoordinate2D()
        if latitudeTxt.text != ""{
            location = CLLocationCoordinate2D(latitude: Double(latitudeTxt.text!)!, longitude: Double(longtitudeTxt.text!)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
            //set pin for location
            let pin = MKPointAnnotation()
            pin.coordinate = location
            mapView.addAnnotation(pin)
        }
        else{
            location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        }
        
        
        //now we can set how much zoom in the map we want by using mkcoordinateSpan
        //we can create a region on map by using mkcoordinateRegion
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        
        let LongPress = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_gestureReconizer:)))
        LongPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(LongPress)
        
        mapView.setRegion(region, animated: true)
        
        //set pin for location
        //let pin = MKPointAnnotation()
        //pin.coordinate = location
        //mapView.addAnnotation(pin)
    }
    @objc func handlePress(_gestureReconizer: UILongPressGestureRecognizer){
        let location = _gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        latString = String(format: "%0.02f", Float(annotation.coordinate.latitude))
        longString = String(format: "%0.02f", Float(annotation.coordinate.longitude))
        print(latString)
        print(longString)
        
        
    }
    
    func getDataById(){
        if choosenPlaceName != "" {
        saveBtn.isHidden = true
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
        let idString = choosenPlaceId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let placeName = result.value(forKey: "name") as? String{
                        namelbl.text = placeName
                    }
                    if let description = result.value(forKey: "nameDescription") as? String{
                        descriptionLbl.text = description
                    }
                    if let latitudePlace = result.value(forKey: "latitude") as? Float{
                        //latString = String(latitudePlace)
                        latitudeTxt.text = String(latitudePlace)
                    }
                    if let longtitudePlace = result.value(forKey: "longtitude") as? Float{
                        //longString = String(longtitudePlace)
                        longtitudeTxt.text = String(longtitudePlace)
                    }
                    
                    
                    
                }
            }
        }catch{
            print("Error")
        }
    
    }else{
        saveBtn.isHidden = false
    }

    }
 
}

