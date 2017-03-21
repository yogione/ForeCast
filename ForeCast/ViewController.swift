//
//  ViewController.swift
//  ForeCast
//
//  Created by Srini Motheram on 3/18/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

   // two empty objects to be filled later.
  let currLoc = Location(name: "currentLocation", summary: "unknown", icon: "default", lat: 0.0, lon: 0.0, temp: 0.0, humidity: 0.0, wind: 0.0)
  let searchedLoc = Location(name: "searchedLocation", summary: "unknown", icon: "default", lat: 0.0, lon: 0.0, temp: 0.0, humidity: 0.0, wind: 0.0)
    //MARK :- LIFE CYCLE METHODS
    
    let hostName = "api.darksky.net"
    
  //  https://api.darksky.net/forecast/21b2256204277dfbb5f66521c87eb4e2/37.8267,-122.4233
    
    
    var reachability :Reachability?
    
    var skey = "21b2256204277dfbb5f66521c87eb4e2"
    
    @IBOutlet var locationNameLabel    :UILabel!
    @IBOutlet var summaryLabel          :UILabel!
    @IBOutlet var tempLabel             :UILabel!
    @IBOutlet var iconLabel              :UILabel!
    @IBOutlet var humidityLabel          :UILabel!
    @IBOutlet var windspeedLabel         :UILabel!
    @IBOutlet var weatherImageView       :UIImageView!
    var imageToAdd: UIImage?
    
    @IBOutlet var networkStatusLabel    :UILabel!
    @IBOutlet var searchField           :UITextField!
   // @IBOutlet var forecastTableView        :UITableView!
    
    var locationMgr = CLLocationManager()
    
    //MARK:- geo coding methods
    @IBAction func latlonSearch(button: UIButton){
        print(searchField.text!)
        searchField.resignFirstResponder()
        guard let searchText = searchField.text, let loc = locationFrom(string: searchText) else {
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(loc){(placemarks, error) in
            if let err = error {
                print ("Got error \(err.localizedDescription)")
            } else {
               // self.addLocAndPinFor(placemarks: placemarks, title: "From Lat/Lon: \(searchText)")
                // print("lat: \(placemark.location!.coordinate.latitude), lon: \(placemark.location!.coordinate.longitude)")
                
            }
            
        }
    }
    
    @IBAction func detroitSearch(button: UIButton){
        searchField.resignFirstResponder()
        guard let searchText = searchField.text else {
            return
        }
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchText) {(placemarks, error) in
            if let err = error {
                print ("Got error \(err.localizedDescription)")
            } else {
                //self.addLocAndPinFor(placemarks: placemarks, title: "From Address: \(searchText)")
                //print("lat: \(placemarks.location!.coordinate.latitude), lon: \(placemarks.location!.coordinate.longitude)")
                guard let placemark = placemarks?.first else {
                    return
                }
                print("placemarks: \(placemark)")
                 print(" lat: \(placemark.location!.coordinate.latitude), lon: \(placemark.location!.coordinate.longitude)")
                self.searchedLoc.locationName = searchText
                self.searchedLoc.locationLat = placemark.location!.coordinate.latitude
                self.searchedLoc.locationLon = placemark.location!.coordinate.longitude
                self.getFilePressed(location: self.searchedLoc)
            }
        }
    }

    
    
    func locationFrom(string: String) -> CLLocation? {
        let coordItems = string.components(separatedBy: ",")
        if coordItems.count == 2 {
            guard let lat = Double(coordItems[0]), let lon = Double(coordItems[1]) else {
                return nil
            }
            print("lat: \(lat), lon:\(lon)")
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    
    //MARK :- CORE METHODS
    // not using the following func
    func parseJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
           // print("JSON: \(jsonResult)")
            
         //   let currentWeather = jsonResult["currently"] as? [String:Any] ?? nil
            
            if let currentWeatherDict = jsonResult["currently"] as? [String:Any] {
                
            let temp = currentWeatherDict["temperature"] as? Double ?? 0.0
            let humidity = currentWeatherDict["humidity"] as? Double ?? 0.0
            let windspeed = currentWeatherDict["windSpeed"] as? Double ?? 0.0
             let summary = currentWeatherDict["summary"] as? String ?? "no data"
             let icon = currentWeatherDict["icon"] as? String ?? "no data"
             //   print("currently: \(currentWeatherDict)")
                print("summary:\(summary) , temp: \(temp), icon: \(icon)")
                print("humidity: \(humidity), windspeed: \(windspeed)")
            currLoc.weatherSummary = summary
            currLoc.temp = temp
            currLoc.icon = icon
            currLoc.humidity = humidity
            currLoc.windspeed = windspeed
                
                updateUI(loc: currLoc)
                
            }

        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func updateUI(loc: Location){
        locationNameLabel.text = "\(loc.locationName!)"
        summaryLabel.text = "summary: \(loc.weatherSummary!)"
        tempLabel.text = "temp: \(loc.temp!)"
        iconLabel.text = "icon: \(loc.icon!)"
        humidityLabel.text = "humidity: \(loc.humidity!)"
        windspeedLabel.text = "wind: \(loc.windspeed!)"
       // imageToAdd = UIImage(named: "fog.png")
        
        let iconValueToSwitch = "\(loc.icon!)"
        print("in update ui func\(iconValueToSwitch)")
        
        //  clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night
       switch iconValueToSwitch {
        case "rain":
            weatherImageView.image = UIImage(named: "rain")
           // weatherImageView.image = imageToAdd
       case "clear-day", "clear-night":
            weatherImageView.image = UIImage(named: "sunny")
       case "sleet":
            weatherImageView.image = UIImage(named: "sleet")
       case "wind":
            weatherImageView.image = UIImage(named: "wind")
       case "snow":
            weatherImageView.image = UIImage(named: "snow")
       case "fog":
        weatherImageView.image = UIImage(named: "fog")

        default:
            weatherImageView.image = UIImage(named: "cloudy")
        
        }
    }
    
    func getFile(filename: String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "https://\(hostName)\(filename)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print ("no data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                
            }
            if recvData.count > 0 && error == nil {
                
                print("Got Data: \(recvData)")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String: \(dataString)")
                self.parseJason(data: recvData)
                
            } else {
                print("Got data of length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
        }
        task.resume()
    }
    
  //  @IBAction func getFilePressed(button: UIButton){
    func getFilePressed(location: Location){
        guard let reach = reachability else {
            return
        }
        
        if reach .isReachable {
            // getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
            getFile(filename: "/forecast/21b2256204277dfbb5f66521c87eb4e2/" + "\(location.locationLat!)" + "," + "\(location.locationLon!)")
            // getFile(filename: "/forecast/21b2256204277dfbb5f66521c87eb4e2/37.8267,-122.4233")
            // getFile(filename: "/search?term=\(searchTerm)")
            
        } else {
            print("Host Not reachable. Turn on the internet")
        }
        
    }
    
    //MARK :- REACHABILITY METHODS
    
    func setupReachability(hostName: String){
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: true, reachability: reachability)
            }
        }
        reachability!.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: false, reachability: reachability)
            }
        }
    }
    
    func startReachability(){
        do {
            try reachability!.startNotifier()
        } catch {
           // networkStatusLabel.text = "Unable to start notifier"
           // networkStatusLabel.textColor = .red
            print("Unable to start notifier")
            return
        }
    }
    
    func updateLabel(reachable: Bool, reachability: Reachability){
        if reachable {
            if reachability.isReachableViaWiFi {
               // networkStatusLabel.textColor = .green
                print("have wifi")
            } else {
                // networkStatusLabel.textColor = .blue
                print("have wifi")
            }
        } else {
           // networkStatusLabel.textColor = .red
            print("have no wifi")
        }
      //  networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability(hostName: hostName)
        startReachability()
        
        // albumArray = fillArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocationMonitoring()
        getFilePressed(location: currLoc)
        //buildArray()
       // annotateMapLocations()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLoc = locations.last!
        print("Last Loc: \(lastLoc.coordinate.latitude),\(lastLoc.coordinate.longitude), description:\(lastLoc.description)")
        currLoc.locationLat = lastLoc.coordinate.latitude
        currLoc.locationLon = lastLoc.coordinate.longitude
       // currLoc.locationName = lastLoc.description
        
       // zoomToLocation(lat: lastLoc.coordinate.latitude, lon: lastLoc.coordinate.longitude, radius: 500)
        manager.stopUpdatingLocation()
    }
    
    //MARK: - Location Authorization Methods
    
    func turnOnLocationMonitoring() {
        locationMgr.startUpdatingLocation()
       // coffeeMap.showsUserLocation = true
    }
    
    func setupLocationMonitoring() {
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                turnOnLocationMonitoring()
            case .denied, .restricted:
                print("Hey turn us back on in Settings!")
            case .notDetermined:
                if locationMgr.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
                    locationMgr.requestAlwaysAuthorization()
                }
            }
        } else {
            print("Hey Turn Location On in Settings!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationMonitoring()
    }
}

