import UIKit
import Flutter
import OrderedSet
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var locationManager = CLLocationManager();
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
      let channel = FlutterMethodChannel(name: "zipsai", binaryMessenger: controller.binaryMessenger);
      
      channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult)-> Void in
          print(call.method)
          var s = Service.instance;
          if(call.method == "servStart"){
              var args = call.arguments as? Dictionary<String, Any>
              var macid = args?["macid"] as! String
            
              s.Setting(macid: macid,port: 12009, interval: 30000)
              s.ServiceRun();
              result("good")
          }
          else if(call.method == "servStop"){
              s.ServiceStop()
          }
          else if(call.method == "isrun"){
              print(s.isRun)
              result(s.isRun)
          }
          else if(call.method == " getLoca"){
              
          }
      })
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
