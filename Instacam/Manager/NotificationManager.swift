//
//  NotificationManager.swift
//  Instacam
//
//  Created by Apple on 11/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import RNNotificationView

enum NotificationTypes: String {
    case acceptCall = "Call Accepted"
    case joinStream = "Join Streaming"
    case endStream = "Call Ended"
    case declineCall = "Call Rejected"
    case streamerExit = "Streamer Exit"
    case streamPause = "Pause Streaming"
    case requestAccepted
    case requestPlaced
    case requestCancelled
}

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    var isCallStarted = false
    func handleNotification(_ userInfo: [AnyHashable : Any], type: TokenType) {
        Payload.shared.modifyPayload(userInfo)
        
        if (UserDefaults.standard.data(forKey: GConstant.UserDefaults.kUserData) != nil)  {
            if type == .voip && (UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive) {
                let content = UNMutableNotificationContent()
                content.title = GConstant.AppName
                content.body = Payload.shared.message
                let soundName = UNNotificationSoundName("\(String(describing: Payload.shared.sound))")
                content.sound = UNNotificationSound(named: soundName)
                content.userInfo = userInfo
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest.init(identifier: Payload.shared.message, content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    print(error?.localizedDescription ?? "error")
                }
            }else{
                //requestAccepted
                if Payload.shared.actionType != nil {
                    NotificationCenter.default.post(name: NSNotification.Name("ReceivedNotification"), object: Payload.shared.actionType)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("ReceivedNotification"), object: Payload.shared.message)
                }
                
            }
            
        }
    }
    
    func handleRedirections(_ type: String, vc: UIViewController) {
        
        switch type {
        case NotificationTypes.acceptCall.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name(NotificationTypes.acceptCall.rawValue), object: Payload.shared.message)
            break
            
        case NotificationTypes.declineCall.rawValue:
            GFunction.shared.removeLoader()
            GNavigation.shared.NavigationController.dismiss(animated: false, completion: nil)
            AlertManager.shared.showPopup(GPAlert(title: "", message: "Viewer Declined"), forTime: 2.0) { (Int) in
                GNavigation.shared.popToRoot(VCHome.self)
            }
            break
            
        case NotificationTypes.streamerExit.rawValue:
            GFunction.shared.removeLoader()
            GNavigation.shared.popToRoot(VCHome.self)
            
            if let controller = GNavigation.shared.NavigationController.topViewController {
                if controller is VCRequest {
                    AlertManager.shared.showPopup(GPAlert(title: "", message: "Unfortunately, Streamer exited because of some reason"), forTime: 2.0) { (Int) in
                    }
                }
            }
            
            break
            
        case NotificationTypes.endStream.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name("StreamingEvents"), object: Payload.shared.message)
            break
            
        case NotificationTypes.joinStream.rawValue:
            if GConstant.UserData.userType == LoginUserType.viewer.rawValue {
                GNavigation.shared.NavigationController.dismiss(animated: false, completion: nil)
                
                if let controller = GNavigation.shared.NavigationController.topViewController {
                    if !(controller is VCRequest) {
                        let vc = vc.instantiateVC(with: "VCRequest") as! VCRequest
                        GNavigation.shared.push(vc, isAnimated: false)
                    }
                }
                
            }else{
                self.switchRole("Streamer is calling you. Please switch back to Viewer to enjoy your requested stream.")
            }
            break
            
        case NotificationTypes.requestAccepted.rawValue:
            if GConstant.UserData.userType == LoginUserType.viewer.rawValue {
                
                if let controller = GNavigation.shared.NavigationController.topViewController {
                    if (controller is VCPopupRequestSent) {
                        GNavigation.shared.NavigationController.dismiss(animated: false, completion: nil)
                    }
                }
                
                let vcAcceptedRequest = vc.instantiateVC(with: "VCPopupAcceptedRequest") as! VCPopupAcceptedRequest
                vcAcceptedRequest.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                GNavigation.shared.present(vcAcceptedRequest, isAnimated: false)
            }else{
                self.switchRole("Your requested Stream has been accepted by the Streamer. Please switch back to Viewer.")
            }
            break
        case NotificationTypes.requestPlaced.rawValue:
            if UIApplication.shared.applicationState == .active {
                RNNotificationView.show(withImage: UIImage(named: "AppIcon"),
                                        title: GConstant.AppName,
                                        message: Payload.shared.message,
                                        duration: 2.5,
                                        iconSize: CGSize(width: 22, height: 22), // Optional setup
                    onTap: {
                        if let controller = GNavigation.shared.NavigationController.topViewController {
                            if !(controller is VCHome) {
                                GFunction.shared.setHomePage(self.appDelegate.window)
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name("TapOnNewStreamNotification"), object: nil)
                            }
                        }
                })
            }
            
            break
        case NotificationTypes.requestCancelled.rawValue:
            if UIApplication.shared.applicationState == .active {
                GNavigation.shared.popToRoot(VCHome.self)
                RNNotificationView.show(withImage: UIImage(named: "AppIcon"),
                                        title: GConstant.AppName,
                                        message: Payload.shared.message,
                                        duration: 2.5,
                                        iconSize: CGSize(width: 22, height: 22), // Optional setup
                    onTap: {
                        print("No Action Added")
                    })
            }
            
            break
        default:
            break
        }
        
    }
    
    var objVMSideMenu = VMSideMenu()
    func switchRole(_ message: String) {
        let alert = GPAlert(title: "Become A Viewer", message: message)
        AlertManager.shared.show(alert, buttonsArray: ["Cancel","Ok"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                break
            case 1:
                //Ok clicked
                let requestModel = UserProfileRequestModel()
                requestModel.user_id = GConstant.UserData.id!
                requestModel.user_type = "V"
                self.objVMSideMenu.callSwitchRoleApi(requestModel, completion: {
                    GFunction.shared.setHomePage(self.appDelegate.window)
                })
                break
            default:
                break
            }
        }
    }
}


class Payload {
    static let shared = Payload()
    
    var title, channel, body, sound, message: String!
    var lat, long, actionType, duration, price, streamId, viewerId, streamerId, userName, userProfile, uid, streamerName, streamerImage: String!
    
    func modifyPayload(_ userInfo: [AnyHashable : Any]) {
        if let aps = userInfo["aps" as String] as? [String:AnyObject] {
            self.message = aps["alert"] as? String
            self.sound = aps["sound"] as? String
        }
        
        self.actionType = userInfo["actionType"] as? String
        self.lat = userInfo["lat"] as? String
        self.long = userInfo["lng"] as? String
        self.duration = userInfo["duration"] as? String
        self.price = userInfo["price"] as? String
        self.streamerId = userInfo["streamer_id"] as? String
        self.streamId = userInfo["stream_id"] as? String
        self.channel = userInfo["channel_name"] as? String
        self.streamerImage = userInfo["streamer_image"] as? String
        self.streamerName = userInfo["streamer_name"] as? String
        self.uid = userInfo["uid"] as? String
    }
}
