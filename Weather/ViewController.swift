//
//  ViewController.swift
//  Weather
//
//  Created by Chandarong Nuon on 6/10/18.
//  Copyright © 2018 App Elegant. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var SearchTextField: UITextField!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
   
    let gradientLayer = CAGradientLayer()
    var city : String = ""
    var language : String = "en"
    let apiKey = "7f52731b3d69462eaef8bb34c32b8155"
    var lat = 38.4127
    var lon = 27.1384
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var cityPicker: UIPickerView!
    
    var pickerData : [String] = ["San Francisco"]
    
    
    @IBAction func searchButton(_ sender: UIButton) {
        city = SearchTextField.text!
        if city != "" {
            request(City: city)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.cityPicker.delegate = self
        self.cityPicker.dataSource = self
        
        let data = UserDefaults.standard.stringArray(forKey: "cities")
        if let cities = data {
            pickerData.append(contentsOf: cities)
            pickerData = Array(Set(pickerData))
        }
        
        temperatureLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        temperatureLabel.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.setGreyGradientBackground()
                }else{
                    self.setBlueGradientBackground()
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground(){
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        city = pickerData[row]
        request(City: city)
        
    }
    
    @IBAction func languageButton(_ sender: UIButton) {
        if language == "en"{
            language = "tr"
            if dayLabel.text! == "Sunday"{
                dayLabel.text! = "Pazar"
            }
            else if dayLabel.text! == "Monday"{
                dayLabel.text! = "Pazartesi"
            }
            else if dayLabel.text! == "Tuesday"{
                dayLabel.text! = "Salı"
            }
            else if dayLabel.text! == "Wednesday"{
                dayLabel.text! = "Çarşamba"
            }
            else if dayLabel.text! == "Thursday"{
                dayLabel.text! = "Perşembe"
            }
            else if dayLabel.text! == "Friday"{
                dayLabel.text! = "Cuma"
            }
            else if dayLabel.text! == "Saturday"{
                dayLabel.text! = "Cumartesi"
            }
            
            if conditionLabel.text! == "Clouds"{
                conditionLabel.text! = "Bulutlu"
            }
            else if conditionLabel.text! == "Clear"{
                conditionLabel.text! = "Açık"
            }
            else if conditionLabel.text! == "Snow"{
                conditionLabel.text! = "Karlı"
            }
            else if conditionLabel.text! == "Atmosphere"{
                conditionLabel.text! = "Atmosfer"
            }
            else if conditionLabel.text! == "Rain"{
                conditionLabel.text! = "Yağmurlu"
            }
            else if conditionLabel.text! == "Drizzle"{
                conditionLabel.text! = "Çişeleme"
            }
            else if conditionLabel.text! == "Thunderstorm"{
                conditionLabel.text! = "Fırtına"
            }
            else if conditionLabel.text! == "Mist"{
                conditionLabel.text! = "Sisli"
            }
        }
        else if language == "tr"{
            language = "en"
            
            if dayLabel.text! == "Pazar"{
                dayLabel.text! = "Sunday"
            }
            else if dayLabel.text! == "Pazartesi"{
                dayLabel.text! = "Monday"
            }
            else if dayLabel.text! == "Salı"{
                dayLabel.text! = "Tuesday"
            }
            else if dayLabel.text! == "Çarşamba"{
                dayLabel.text! = "Wednesday"
            }
            else if dayLabel.text! == "Perşembe"{
                dayLabel.text! = "Thursday"
            }
            else if dayLabel.text! == "Cuma"{
                dayLabel.text! = "Friday"
            }
            else if dayLabel.text! == "Cumartesi"{
                dayLabel.text! = "Saturday"
            }
            
            if conditionLabel.text! == "Bulutlu"{
                conditionLabel.text! = "Clouds"
            }
            else if conditionLabel.text! == "Açık"{
                conditionLabel.text! = "Clear"
            }
            else if conditionLabel.text! == "Karlı"{
                conditionLabel.text! = "Snow"
            }
            else if conditionLabel.text! == "Atmosfer"{
                conditionLabel.text! = "Atmosphere"
            }
            else if conditionLabel.text! == "Yağmurlu"{
                conditionLabel.text! = "Rain"
            }
            else if conditionLabel.text! == "Çişeleme"{
                conditionLabel.text! = "Drizzle"
            }
            else if conditionLabel.text! == "Fırtına"{
                conditionLabel.text! = "Thunderstorm"
            }
            else if conditionLabel.text! == "Sisli"{
                conditionLabel.text! = "Mist"
            }
        }
        
    }
    
    
    
    func request(City : String){
        city = City
        //let language = language
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                self.pickerData.append(self.city)
                
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.setGreyGradientBackground()
                }else{
                    self.setBlueGradientBackground()
                }
            }
        }
        UserDefaults.standard.set(self.pickerData, forKey: "cities")
        pickerData = Array(Set(pickerData))
        self.cityPicker.reloadAllComponents()
    }
    var weatherItem: Int = 0
    @objc func handleTap(sender: UITapGestureRecognizer) {
        weatherItem = Int(temperatureLabel.text!)!
        if sender.state == .ended {
            // handling code
            print("tap başlangıç")
            if self.degreeLabel.text == "℃" {
                self.degreeLabel.text = "℉"
                weatherItem = (weatherItem * 9 / 5) + 32
                
                temperatureLabel.text = String(weatherItem)
                print(self.weatherItem)
                //temperatureLabel.text = "\(Int(Double(temperatureLabel.text)! - 273.14))"
            }
            else if self.degreeLabel.text == "℉" {
                self.degreeLabel.text = "℃"
                weatherItem = (weatherItem - 32) * 5 / 9
                
                temperatureLabel.text = String(weatherItem)
                print(self.weatherItem)
                
            }
            print("tap working")
        }
}

}
