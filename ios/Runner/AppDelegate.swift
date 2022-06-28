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
          
          var args = call.arguments as? Dictionary<String, Any>
          var macid = args?["macid"] as! String
          
          var s = Service.instance;
          s.Setting(macid: macid, interval: 30000)
          s.ServiceRun();
          
      })
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
