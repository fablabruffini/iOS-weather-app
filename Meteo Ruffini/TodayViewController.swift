//
//  TodayViewController.swift
//  Meteo Ruffini
//
//  Created by Luca Scutigliani on 16/04/17.
//  Copyright © 2017 Ruffini Fablab. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = data()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    //api reference
    func weather_request(forComune: String) -> Data? {
        let api_key = "daily.json"
        guard let url = URL(string: "http://www.ruffinifablab.it/weewx/\(api_key)") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("[ERROR] There is an unspecified error with the connection")
            return nil
        }
        
        print("[CONNECTION] OK, data correctly downloaded")
        return data
    }
    
    //json parsing function
    func json_parseData(_ data: Data) -> NSDictionary? {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            print("[JSON] OK!")
            print(json)
            return (json as? NSDictionary)
        } catch _ {
            print("[ERROR] An error has happened with parsing of json data")
            return nil
        }
    }
    
    //internet connection check
    func checkWiFi() -> Bool {
        
        let networkStatus = Reachability().connectionStatus()
        switch networkStatus {
        case .Unknown, .Offline:
            print("No connection")
            return false
        case .Online(.WWAN):
            print("Connected via WWAN")
            return true
        case .Online(.WiFi):
            print("Connected via WiFi")
            return true
        }
    }
    
    func data() {
        let connection = checkWiFi()
        tempLabel.text = "--"
        barLabel.text = "--"
        windDirLabel.text = "--"
        windSpeedLabel.text = "--"
        lastUpdateLabel.text = "--"
        if(connection == true){
            let data = weather_request(forComune: "Viterbo")
            _ = json_parseData(data!)
            
            //extraction data
            if let json = json_parseData(data!) {
                let weather_array: NSArray = (json["current"] as? NSArray)!
                let weather: NSDictionary = weather_array[0] as! NSDictionary
                
                
                //UIoutput
                tempLabel.text = weather["outTemp"] as? String
                barLabel.text = weather["barometer"] as? String
                windDirLabel.text = weather["windDirText"] as? String
                windSpeedLabel.text = weather["windSpeed"] as? String
                lastUpdateLabel.text = weather["time"] as? String
            }
        }
    }

    
}
