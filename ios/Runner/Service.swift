//
//  Service.swift
//  Runner
//
//  Created by 탁원준 on 2022/06/21.
//

import Foundation
import CoreLocation

class Service :NSObject, CLLocationManagerDelegate{
    static let instance = Service();
    private let locationManager = CLLocationManager();
    private let s = Sender()
    
    private var isRun : Bool
    
    private var interval : Int
    private var macid : String
    
    override private init(){
        macid = "999"
        interval = 3
        isRun = false
    }
    
    func Setting(macid:String, interval:Int){
        self.macid = macid
        self.interval = interval
        
    }
    
    func ServiceRun(){
        
        
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
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
        // 위치 수집 항상 허용 요청
        locationManager.requestAlwaysAuthorization();
        
        
        if(isRun){
            return
        }
        
        s.Connect()
        
        isRun = true
        locationManager.startUpdatingLocation();
    }
    
    func ServiceStop(){
        if(isRun){
            locationManager.stopUpdatingLocation()
            isRun = false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let lastLoc = locations.last;
        guard s.Start() else{
            return
        }
        //var acc = lastLoc?.horizontalAccuracy
        //if(acc! > 30) {return}
        
        //print(lastLoc?.horizontalAccuracy)
        s.InputParam(key: "id", val: macid)
        s.InputParam(key: "tag", val: "ios")
        s.InputParam(key: "lat", val: "\((lastLoc?.coordinate.latitude)!)")
        s.InputParam(key: "lng", val: "\((lastLoc?.coordinate.longitude)!)")
        s.InputParam(key: "spd", val: "\((lastLoc?.speed)!)")
        s.InputParam(key: "acc", val: "\((lastLoc?.horizontalAccuracy)!)")
        s.InputParam(key: "alt", val: "\((lastLoc?.altitude)!)")
        
        s.Send()
        s.End()
    }
}
