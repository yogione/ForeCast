//
//  ViewController.swift
//  ForeCast
//
//  Created by Srini Motheram on 3/18/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
  //  var museumArray = [MuseumItem]()
    
    //MARK :- LIFE CYCLE METHODS
    
    let hostName = "api.darksky.net"
    
  //  https://api.darksky.net/forecast/21b2256204277dfbb5f66521c87eb4e2/37.8267,-122.4233
    
    
    var reachability :Reachability?
    
    var skey = "21b2256204277dfbb5f66521c87eb4e2"
    
    @IBOutlet var networkStatusLabel    :UILabel!
    @IBOutlet var searchField           :UITextField!
    @IBOutlet var forecastTableView        :UITableView!
    
    //MARK :- CORE METHODS
    // not using the following func
    func parseJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary //[String:Any]
           // print("JSON: \(jsonResult)")
            
         //   let currentWeather = jsonResult["currently"] as? [String:Any] ?? nil
            
            if let currentWeatherDict = jsonResult["currently"] as? NSDictionary {
                
            let temp = currentWeatherDict["temperature"] as? String ?? "no data"
            let time = currentWeatherDict["time"] as? String ?? "no data"
                print("currently: \(currentWeatherDict), time:\(time) , temp: \(temp)")
                
            }
            
            
          //  let icon = jsonResult["timezone"] as? String ?? "no data"
            
           /* let flavorsArray = jsonResult["temperature"] as! [[String:Any]]
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict)")
            }
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict["summary"])")
            } */
            
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func parseItunesJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            //   [String:Any]()
            // print("JSON: \(jsonResult)")
            let firstRow = jsonResult[0]
            print("first row: \(firstRow)")
            let museumArray2 = jsonResult as! [[String:Any]]
            
            for museumDict in museumArray2 {
                print("museum:\(museumDict["commonname"])")
                
             /*   let museumName2 = museumDict["commonname"] as? String ?? "no data"
                let street2 = museumDict["location_1_address"] as? String ?? "no street data"
                let city2 = museumDict["location_1_city"] as? String ?? "no city data"
                let state2 = museumDict["location_1_state"] as? String ?? "no state data" */
                
             //   museumArray.append(MuseumItem(museumName: museumName2, street: street2, city: city2,  state: state2))
                
            }
            
            //  print("Museum Array: \(museumArray)")
        }
        catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            self.forecastTableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    //MARK: - setup METHODS -- just for testing
 /*   func fillArray() -> [MuseumItem]{
        let museum3 = MuseumItem(museumName: "Bill Museum", street: "123 oak", city: "ypsi", state: "FL")
        let museum2 = MuseumItem(museumName: "Joe Museum", street: "123 maple", city: "canton", state: "FL")
        return [museum3, museum2]
    } */
    
    
  //  @IBAction func getFilePressed(button: UIButton){
    func getFilePressed(){
        guard let reach = reachability else {
            return
        }
        
        if reach .isReachable {
            // getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
            getFile(filename: "/forecast/21b2256204277dfbb5f66521c87eb4e2/37.8267,-122.4233")
            // getFile(filename: "/search?term=\(searchTerm)")
            
        } else {
            print("Host Not reachable. Turn on the internet")
        }
        
        
    }
    
    //MARK :- Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //  return museumArray.count
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) // as! MuseumTableViewCell
       /* let currentMuseumItem = museumArray[indexPath.row]
        cell.museumNameLabel.text = currentMuseumItem.museumName
        cell.streetLabel.text = currentMuseumItem.street
        cell.cityLabel.text = currentMuseumItem.city
        cell.stateLabel.text = currentMuseumItem.state */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentMuseumItem = museumArray[indexPath.row]
       // print("Row: \(indexPath.row) \(currentMuseumItem.museumName)")
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
        getFilePressed()
        // albumArray = fillArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

