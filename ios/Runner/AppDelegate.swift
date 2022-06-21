import UIKit
import Flutter
import OrderedSet

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let batteryChannel = FlutterMethodChannel(name: "app.zips.ai/channel", binaryMessenger: controller.binaryMessenger)
      
      BatteryChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult)-> Void in
      })
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
