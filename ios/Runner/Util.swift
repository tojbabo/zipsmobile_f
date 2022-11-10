//
//  Util.swift
//  Runner
//
//  Created by 탁원준 on 2022/09/29.
//

import Foundation

import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class Util : NSObject, CLLocationManagerDelegate{
    private let locationManager = CLLocationManager();
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status:CLAuthorizationStatus){
        if status == .authorizedWhenInUse{
            updateWifi()
        }
    }
 
struct NetworkInfo{
    var instance: String
    var success:Bool = false
    var ssid : String?
    var bssid: String?
}
var currentNetworkInfos:Array<NetworkInfo>?{
    get{
        return SSID.fetchNetworkInfo()
    }
}
public class SSID{
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces(){
            var networkInfos = [NetworkInfo]()
            for interface in interfaces{
                let interfaceName = interface as! String
                var networkinfo = NetworkInfo(instance: interfaceName,
                                              success:false,
                                              ssid:nil,
                                              bssid:nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary?{
                    networkinfo.success = true
                    networkinfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkinfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkinfo)
            }
            return networkInfos
        }
        return nil
    }
    
}
func updateWifi(){
    print("show all wifi")
    currentNetworkInfos?.forEach({ (NetworkInfo) in
        if let ssid = NetworkInfo.ssid {
            print("ssid : \(ssid)")
        }
    })
}


}
