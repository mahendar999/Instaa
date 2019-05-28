//
//  LocationManager.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    private var locationManager = CLLocationManager()
    private var islocationEnabled: Bool!
    typealias CompletionHandler = (Bool)->Void
    var currentLocation: CLLocation!
    var PermisionHandler: CompletionHandler?
    var timer: Timer!
    var objVMCompleteProfile = VMCompleteProfile()

    // MARK:- Current Location Setup
    
    func locationSetup(_ permissionStatus: CompletionHandler? = {_ in}) {
        
        self.PermisionHandler = permissionStatus
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
}

// MARK:- Current Location Delegates

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
        
        if !self.isUserTypeViewer() {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(shareLocatioAction), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func shareLocatioAction() {
        NotificationCenter.default.post(name: NSNotification.Name("ShareLocationNotification"), object: nil)
        
        if self.timer == nil {
            let requestModel = UserProfileRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.is_profile_created = "Y"
            requestModel.device_type = "iOS"
            requestModel.user_type = GConstant.UserData.userType
            requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
            requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
            
            requestModel.lat = "\(self.currentLocation.coordinate.latitude)"
            requestModel.lng = "\(self.currentLocation.coordinate.longitude)"
            
            self.objVMCompleteProfile.callCompleteProfileApi(requestModel, isLoader: false) { (identifier) -> Void in
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted, .denied:
            if self.PermisionHandler != nil {
                PermisionHandler!(false)
            }
            // Disable your app's location features
            AlertManager.shared.show(GConstant.Alert.locationPermission(), buttonsArray: ["Close","Go To Settings"], completionBlock: { (index : Int) in
                switch index{
                case 0:
                    break
                case 1:
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    break
                default:
                    //print("-:Something Wrong")
                    break
                }
            })
            break
            
        case .authorizedWhenInUse:
            // Enable only your app's when-in-use features.
            if self.PermisionHandler != nil {
                PermisionHandler!(true)
            }
            break
            
        case .notDetermined:
            if self.PermisionHandler != nil {
                PermisionHandler!(false)
            }
            locationManager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
        
    }
    
}
