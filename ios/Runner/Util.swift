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

class Util{
    
    let options:[String:NSObject] = [kNEHotspotHelperOptionDisplayName: "zipsai" as NSString]
    let queue: DispatchQueue = DispatchQueue(label: "com.hansung")
    
    func fff(){
        print("sex good")
        
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray?{
            for interface in interfaces{
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        print("SSID is : \(ssid)")
        
        
        setupLocation()
        
        if #available(iOS 11.0, *) {
            var d = NEHotspotConfigurationManager()
            var f = NEHotspotConfiguration()
            //d.apply(NEHotspotConfiguration())
            d.getConfiguredSSIDs { data in
                print("\(data.count)")
                print("\(data)")
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        let isAvailable = NEHotspotHelper.register(options:options, queue:queue){ (command) in
            print("cmd is: \(command.commandType)")
            switch command.commandType {
            case .evaluate,
                    .filterScanList:
                let originalNetworklist = command.networkList ?? []
            @unknown case _:
                print("fuck you fuck")
                
            }
        }
    }
    
    
    
    
    
    struct NetworkInfo{
        var interface : String
        var success : Bool = false
        var ssid : String?
        var bssid: String?
    }
    var currentNetworkInfos: Array<NetworkInfo>?{
        get{
            return SSID.fetchNetworkInfo()
        }
    }
    public class SSID{
        class func fetchNetworkInfo() -> [NetworkInfo]?{
            if let interfaces: NSArray = CNCopySupportedInterfaces(){
                var networkInfos = [NetworkInfo]()
                for interface in interfaces{
                    let interfaceName = interface as! String
                    var networkInfo = NetworkInfo(interface:interfaceName,
                                                  success: false,
                                                  ssid: nil,
                                                  bssid: nil)
                    if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary?{
                        networkInfo.success = true
                        networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                        networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                    }
                    networkInfos.append(networkInfo)
                }
                return networkInfos
            }
            return nil
        }
    }
    func updateWIFI(){
        print("Show wifi -- \(currentNetworkInfos?.count)")
        
        currentNetworkInfos?.forEach({(networkInfo) in
            if let ssid = networkInfo.ssid{
                print("SSID: \(ssid)")
            }
        })
    }
    func setupLocation(){
        if #available(IOS 13.0, *){
            let status = CLLocationManager.authorizationStatus()
            
            print("status is: \(status)")
            if(status == .authorizedWhenInUse || status == .authorizedAlways){
                updateWIFI()
            }
        }
    }
}
