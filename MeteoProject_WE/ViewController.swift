//
//  ViewController.swift
//  MeteoProject
//
//  Created by Luca on 19/01/2017.
//
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var refreshButton: UIButton!
    
    @IBOutlet var barometerLabel: UILabel!
    @IBOutlet var outTemp: UILabel!
    @IBOutlet var windChill: UILabel!
    @IBOutlet var windDirection: UILabel!
    @IBOutlet var windSpeed: UILabel!
    @IBOutlet var lastData: UILabel!
    @IBOutlet var Statuslabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshButton.isEnabled = false
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            _ = self.data()
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
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
        barometerLabel.text = "--"
        outTemp.text = "--"
        windChill.text = "--"
        windDirection.text = "--"
        windSpeed.text = "--"
        lastData.text = "Connessione Assente."
        Statuslabel.text = "N/A"
        if(connection == true){
            let data = weather_request(forComune: "Viterbo")
            _ = json_parseData(data!)
            
            //extraction data
            if let json = json_parseData(data!) {
                let weather_array: NSArray = (json["current"] as? NSArray)!
                let weather: NSDictionary = weather_array[0] as! NSDictionary
                
                
                //UIoutput
                barometerLabel.text = weather["barometer"] as? String
                outTemp.text = weather["outTemp"] as? String
                windChill.text = weather["windchill"] as? String
                windDirection.text = weather["windDirText"] as? String
                windSpeed.text = weather["windSpeed"] as? String
                lastData.text = weather["time"] as? String
                Statuslabel.text = weather["isonline"] as? String
            }
        }
        
        self.loadingView.isHidden = true
        self.refreshButton.isEnabled = true
    }
    
    @IBAction func refresh(_ sender: Any) {
        //invoke data function
        
        self.loadingView.isHidden = false
        self.refreshButton.isEnabled = false
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            _ = self.data()
            
        }
    }
}
