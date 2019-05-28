//
//  GConstant.swift
//  Trailer2You
//
//  Created by SIERRA on 4/6/18.
//  Copyright © 2018 GsBitLabs. All rights reserved.
//

import UIKit
import KWVerificationCodeView

enum PageContentType {
    case terms
    case faq
    case privacy
    case community
}

struct GConstant {
    static let AppName: String                  = "Instacam"
    static let kHeightAspectRasio: CGFloat      =  1.0
    static var UserData: UserResult!
    static var isSocketQueueActive = true
    static var isCompleteProfilePresent = false
    static var UserRoleRating: RatingModel!
    static var prefferedLanguage: String!
    
    struct Screen {
        static let width        = UIScreen.main.bounds.size.width
        static let height       = UIScreen.main.bounds.size.width
    }
    
    struct AppColor {
        static let primary          = UIColor.white
        static let secondary        = UIColor.white
        static let text             = UIColor.black
        static let font             = UIColor(named: "AppFont")
        static let buttonFont       = UIColor(named: "AppButtonFont")
        static let lightSkyBlue     = UIColor(named: "AppLightSkyBlue")
        static let darkSkyBlue      = UIColor(named: "AppDarkSkyBlue")
        static let darkGray         = UIColor(named: "AppGray")
        static let green            = UIColor(named: "AppGreen")
    }
    
    struct UserDefaults {
        static let kAppLaunch                      : String = "kAppLaunch"
        static let kDeviceToken                    : String = "kDeviceToken"
        static let kDeviceTokenVoip                : String = "kDeviceTokenVoip"
        static let kUserData                       : String = "kLoginUserData"
        static let kStreamTrackData                : String = "kStreamTrackData"
        static let kStreamerTutorial               : String = "kStreamerTutorial"
        static let kViewerTutorial                 : String = "kViewerTutorial"
        static let kViewerVideoTutorial            : String = "kViewerVideoTutorial"
        static let kStreamerVideoTutorial          : String = "kStreamerVideoTutorial"
        static let kRequestStreamData              : String = "kRequestStreamData"
    }
    
    struct Alert {

        static func photoPermission() -> GPAlert {
             let kPermissionMessage = "We need to have access to your photos to select a Photo.\nPlease go to the App Settings and allow Photos."
            return GPAlert(title: "Change your Settings", message: kPermissionMessage)
        }
        
        static func contactPermission() -> GPAlert {
            let kPermissionMessage = "This feature requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?"
            return GPAlert(title: "Change your Settings", message: kPermissionMessage)
        }
        
        static func cameraPermission() -> GPAlert {
            let kPermissionMessage = "We need to have access to your camera to take a New Photo.\nPlease go to the App Settings and allow Camera."
            return GPAlert(title: "Change your Settings", message: kPermissionMessage)
        }
        
        static func locationPermission() -> GPAlert {
            let kPermissionMessage = "We need to have access to your Current Location to show you to nearby Streamers.\nPlease go to the App Settings and allow Location."
            return GPAlert(title: "Change your Settings", message: kPermissionMessage)
        }
        
        static func turnOffLocationPermission() -> GPAlert {
            let kPermissionMessage = "Go to your device settings for Instacam, tap Permissions, then turn off location access"
            return GPAlert(title: "Turn off Location Sharing", message: kPermissionMessage)
        }
        
        static func turnOffNotificationPermission() -> GPAlert {
            let kPermissionMessage = "You'll no longer receive push notifications from Instacam."
            return GPAlert(title: "Turn off Notifications", message: kPermissionMessage)
        }
        
        static func network() -> GPAlert{
            return GPAlert(title: "Network Issue!", message: "\(GConstant.AppName) has failed to retrieve data. Please check your Internet connection and try again")
        }
    }
}


class VerificationView: KWVerificationCodeView {
}
