//
//  AppDelegate.swift
//  Instacam
//
//  Created by Apple on 04/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift
import UserNotifications
import PushKit
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import Stripe
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let language = NSLocale.preferredLanguages.first
        if language?.range(of: "zh") != nil {
            GConstant.prefferedLanguage = language?.components(separatedBy: "-")[0]
        }else{
            GConstant.prefferedLanguage = "en"
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    
        self.basicKeyBoardSetUp()
        self.registerForPush()
        
        Thread.sleep(forTimeInterval: 2)
        
        LocationManager.shared.locationSetup()
        
        // Google Maps Setup
        let googleKey = KeyManager.google
        GMSServices.provideAPIKey(googleKey)
        GMSPlacesClient.provideAPIKey("")
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        
        // Stripe Setup
        STPPaymentConfiguration.shared().publishableKey = KeyManager.stripeTestKey
        
        // Check for Authentication
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if (UserDefaults.standard.data(forKey: GConstant.UserDefaults.kUserData) != nil)  {
            GFunction.shared.userLogin(window)
        }else{
            GFunction.shared.userLogOut(window)
        }
        
        // Check if launched from the remote notification and application is close
        if let remoteNotification = launchOptions?[.remoteNotification] as?  [AnyHashable : Any] {
            if GConstant.UserData != nil {
                NotificationManager.shared.handleNotification(remoteNotification, type: .standard)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if(SocketIOManager.shared.socket.status == .connected){
            SocketIOManager.shared.closeConnection()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if(SocketIOManager.shared.socket.status != .connected){
            SocketIOManager.shared.establishConnection()
        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func basicKeyBoardSetUp(_ value: Bool = true) {
        IQKeyboardManager.shared.enable = value
        IQKeyboardManager.shared.enableAutoToolbar = value
        IQKeyboardManager.shared.shouldResignOnTouchOutside = value
    }
}

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

// MARK:- Push Registery Setup and its delegates methods

extension AppDelegate: PKPushRegistryDelegate {
    
    func registerForVoip() {
        let mainQueue = DispatchQueue.main
        let voipReistery: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipReistery.delegate = self
        voipReistery.desiredPushTypes = [PKPushType.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        GFunction.shared.saveDataIntoUserDefault(object: deviceToken as AnyObject, key: GConstant.UserDefaults.kDeviceTokenVoip)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("Invalid Push Token")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if GConstant.UserData != nil {
            NotificationManager.shared.handleNotification(payload.dictionaryPayload, type: .voip)
        }
    }
    
}

// MARK:- Notifications Setup and its delegates methhods

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPush() {
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization.
        })
        UIApplication.shared.registerForRemoteNotifications()
        self.registerForVoip()
    }
    
    //MARK: - Device Token
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        GFunction.shared.saveDataIntoUserDefault(object: deviceToken  as AnyObject, key: GConstant.UserDefaults.kDeviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if GConstant.UserData != nil {
            NotificationManager.shared.handleNotification(userInfo, type: .standard)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle push from Foreground/Active
        self.application(UIApplication.shared, didReceiveRemoteNotification: notification.request.content.userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle push from background or closed
        self.application(UIApplication.shared, didReceiveRemoteNotification: response.notification.request.content.userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.application(UIApplication.shared, didReceiveRemoteNotification: userInfo)
    }
    
}

// MARK:- Check Network Connection

class Connectivity {
    class var isConnectedToInternet:Bool {
        if NetworkReachabilityManager()!.isReachable {
            return true
        }else{
            GFunction.shared.removeLoader()
            AlertManager.shared.show(GConstant.Alert.network())
            return false
        }
    }
}
