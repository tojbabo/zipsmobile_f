//
//  Service.swift
//  Runner
//
//  Created by 탁원준 on 2022/06/21.
//

import Foundation
import CoreLocation
import UserNotifications
import UIKit


import NetworkExtension
import SystemConfiguration.CaptiveNetwork


class Service :NSObject, CLLocationManagerDelegate{
    static let instance = Service();
    private let locationManager = CLLocationManager();
    private let s = Sender()
    
    public var isRun : Bool
    
    private var interval : Int
    private var macid : String
    
    private var timer : Timer?
    
    public var mindist : Double
    public var accuracy : Int
    public var timeInterval : Double
    
    override private init(){
        macid = "999"
        interval = 3
        isRun = false
        timer = nil
        
        mindist = 0.0
        accuracy = 0
        timeInterval = 0.0
        
    }
    
    @objc func f(){
        locationManager.stopUpdatingLocation()
        InitLocationManager(dist: 1000.0)
        locationManager.startUpdatingLocation()
    }
    
    func Setting(macid:String, port:Int, interval:Int){
        self.macid = macid
        self.interval = interval
        s.port = port
        
    }
    

    func ServiceRun() {
        if(isRun){
            print("[Service] already Launch")
            return
        }
        s.Connect()
        let res = s.GetSetting()
        var json : Dictionary<String,Any> = [String:Any]()
        do{
            json = try JSONSerialization.jsonObject(with: Data(res.utf8),options: []) as! [String:Any]
        }catch{
            print("err good")
            return
            
        }
        
        
        mindist = (json["distance"] ?? 0) as! Double
        accuracy = (json["accuracy"] ?? 1000.0) as! Int
        timeInterval = (json["interval"] ?? 60 * 10  * 1000) as! Double
        
        timeInterval = timeInterval / 1000
        
//        print("intervarl \(timeInterval)")
//        print("accuracy \(accuracy)")
//        print("distance \(mindist)")
        
        //print("resutl is \(res)")
        
        InitLocationManager(dist: 1000.0)
        locationManager.startUpdatingLocation()
        //print(timeInterval)
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(f), userInfo: nil, repeats: true)
                
        isRun = true

        print("[Service] Launch")
    }
    
    func ServiceStop(){
        if(isRun){
            locationManager.stopUpdatingLocation()
            timer?.invalidate()
            isRun = false
        }
        print("[Service] Destroy")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let lastLoc = locations.last;
        guard s.Start() else{
            print("it is not ready")
            return
        }
        //var acc = lastLoc?.horizontalAccuracy
        
        print("accuracy: \(lastLoc!.horizontalAccuracy)")
        print("lat is  : \(lastLoc?.coordinate.latitude)")
        print("lng is  : \(lastLoc?.coordinate.longitude)")
        
        
        if(lastLoc!.horizontalAccuracy > Double(accuracy)) {return}
        if((lastLoc?.coordinate.latitude)! < 32.8 || (lastLoc?.coordinate.latitude)! > 38.8 ) {return}
        if((lastLoc?.coordinate.longitude)! < 125.5 || (lastLoc?.coordinate.longitude)! > 131.9) {return}
        
        //print(lastLoc?.horizontalAccuracy)
        s.InputParam(key: "id", val: macid)
        s.InputParam(key: "tag", val: "ios")
        s.InputParam(key: "lat", val: "\((lastLoc?.coordinate.latitude)!)")
        s.InputParam(key: "lng", val: "\((lastLoc?.coordinate.longitude)!)")
        s.InputParam(key: "spd", val: "\((lastLoc?.speed)!)")
        s.InputParam(key: "acc", val: String(format:"%.2f",(lastLoc?.horizontalAccuracy)!))
        s.InputParam(key: "alt", val: "\((lastLoc?.altitude)!)")
        
        s.Send()
        s.End()
    }

    func InitLocationManager(dist:Double){
        locationManager.delegate  = self;
        
        // 백그라운드 로케이션 업데이트를 설정할지
        locationManager.allowsBackgroundLocationUpdates = true;
        // 자동 종료를 허용할지
        locationManager.pausesLocationUpdatesAutomatically = false;
        
        if #available(iOS 11.0, *) {
            // 백그라운드에서 위치수집할때 알람을 띄울지말지
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        // 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.distanceFilter = dist
        
        // 위치 수집 항상 허용 요청
        locationManager.requestAlwaysAuthorization();
                
    }
    
    func setupLocation(){
        if #available(iOS 13.0, *){
            let status = CLLocationManager.authorizationStatus()
            
            if (status == .authorizedWhenInUse || status == .authorizedAlways){
                var res = fetchNetworkInfo()
                res?.forEach({ NetworkInfo in
                    if let ssid = NetworkInfo.ssid{
                        print("SSID is: \(ssid)")
                    }
                })
                
            }else{
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }
        }else{
        }
    }
    
    func fetchNetworkInfo() -> [NetworkInfo]?{
        if let interfaces: NSArray = CNCopySupportedInterfaces(){
            var networkinfos = [NetworkInfo]()
            for interface in interfaces{
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(instance: interfaceName,
                                              success:false,
                                              ssid:nil,
                                              bssid:nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary?{
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkinfos.append(networkInfo)
            }
            return networkinfos
        }
        return nil
    }

        
       struct NetworkInfo{
           var instance: String
           var success:Bool = false
           var ssid : String?
           var bssid: String?
       }
}
