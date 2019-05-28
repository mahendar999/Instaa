//
//  VMSideMenu.swift
//  Instacam
//
//  Created by Apple on 01/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

enum SideMenuActions: String {
    case home                   = "Home"
    case viewerHistory          = "Viewer History"
    case pendingRequest         = "Pending Requests"
    case becomeStreamer         = "Become A Streamer"
    case messages               = "Messages"
    case payment                = "Payment"
    case freeCredits            = "Free Credits"
    case settings               = "Settings"
    case becomeViewer           = "Become A Viewer"
    case streamerHistory        = "Streamer History"
    case rate                   = "Rate This App"
}

extension UIImage {
    enum AssetIdentifier: String {
        case home                   = "home-hover"
        case viewerHistory          = "Path_hover"
        case streamerHistory        = "history-hover"
        case pendingRequest         = "pending-hover"
        case becomeStreamer         = "streamer_hover"
        case becomeViewer           = "viewer_hover"
        case messages               = "messages-hover"
        case payment                = "payment_hover"
        case freeCredits            = "freecredits-hover"
        case settings               = "settings-hover"
        case rate                   = "rate_blue"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

struct SideMenu {
    let name: String!
    var image: UIImage!
    let actionType: SideMenuActions!
}

class VMSideMenu: NSObject {
    let arrViewerSideMenu: [SideMenu] = [
        SideMenu(name: SideMenuActions.home.rawValue, image: UIImage(assetIdentifier: .home), actionType: .home),
        SideMenu(name: SideMenuActions.viewerHistory.rawValue, image: UIImage(assetIdentifier: .viewerHistory), actionType: .viewerHistory),
        SideMenu(name: SideMenuActions.pendingRequest.rawValue, image: UIImage(assetIdentifier: .pendingRequest), actionType: .pendingRequest),
        SideMenu(name: SideMenuActions.becomeStreamer.rawValue, image: UIImage(assetIdentifier: .becomeStreamer), actionType: .becomeStreamer),
//        SideMenu(name: SideMenuActions.messages.rawValue, image: UIImage(assetIdentifier: .messages), actionType: .messages),
        SideMenu(name: SideMenuActions.payment.rawValue, image: UIImage(assetIdentifier: .payment), actionType: .payment),
        SideMenu(name: SideMenuActions.freeCredits.rawValue, image: UIImage(assetIdentifier: .freeCredits), actionType: .freeCredits),
        SideMenu(name: SideMenuActions.settings.rawValue, image: UIImage(assetIdentifier: .settings), actionType: .settings),
        SideMenu(name: SideMenuActions.rate.rawValue, image: UIImage(assetIdentifier: .rate), actionType: .rate)
    ]
    
    let arrStreamerSideMenu: [SideMenu] = [
        SideMenu(name: SideMenuActions.home.rawValue, image: UIImage(assetIdentifier: .home), actionType: .home),
        SideMenu(name: SideMenuActions.streamerHistory.rawValue, image: UIImage(assetIdentifier: .streamerHistory), actionType: .streamerHistory),
        SideMenu(name: SideMenuActions.becomeViewer.rawValue, image: UIImage(assetIdentifier: .becomeStreamer), actionType: .becomeViewer),
//        SideMenu(name: SideMenuActions.messages.rawValue, image: UIImage(assetIdentifier: .messages), actionType: .messages),
        SideMenu(name: SideMenuActions.payment.rawValue, image: UIImage(assetIdentifier: .payment), actionType: .payment),
        SideMenu(name: SideMenuActions.freeCredits.rawValue, image: UIImage(assetIdentifier: .freeCredits), actionType: .freeCredits),
        SideMenu(name: SideMenuActions.settings.rawValue, image: UIImage(assetIdentifier: .settings), actionType: .settings),
        SideMenu(name: SideMenuActions.rate.rawValue, image: UIImage(assetIdentifier: .rate), actionType: .rate)
    ]
    
    func getSideMenuArray() -> [SideMenu] {
        return GConstant.UserData.userType == "S" ? self.arrStreamerSideMenu : self.arrViewerSideMenu
    }
    
    func callSwitchRoleApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void) {
        
        /*
         Api name: switchUserRole
         Parameters: user_id, user_type('V', 'S')
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.switchUserRole(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                            completion()
                        }
                        
                        if SocketIOManager.shared.socket.status != .connected {
                            SocketIOManager.shared.establishConnection()
                        }
                        
                    }else{
                        AlertManager.shared.show(GPAlert(title: "Error", message: responseModel.message ?? ""))
                    }
                    
                }
            }
        }
        
    }
    
}

extension VCSideMenu: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objVMSideMenu.getSideMenuArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSideMenu", for: indexPath) as! CellSideMenu
        
        let objAtIndex = (self.objVMSideMenu.getSideMenuArray())[indexPath.row]
        cell.lblMenuName.text = objAtIndex.name.localized()
        cell.imgView.image = objAtIndex.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func clearNavigationStackForSideMenu() {
        // NOTE: Keep only root view controller and rest controllers will be clear from stack before push
        let arrControllers = GNavigation.shared.NavigationController.viewControllers
        for controller in arrControllers {
            if !controller.isKind(of: VCHome.self) {
                GNavigation.shared.pop(false)
            }
        }
    }
    
    func moveTOVC(_ identifier: String) {
        clearNavigationStackForSideMenu()
        GNavigation.shared.pushWithoutData(identifier, isAnimated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objAtIndex = (self.objVMSideMenu.getSideMenuArray())[indexPath.row]
        
        self.revealViewController()?.revealToggle(self)
        switch objAtIndex.actionType! {
        case .home:
            GNavigation.shared.popToRoot(VCHome.self, isAnimated: false)
            break
        case .viewerHistory:
            self.moveTOVC(GVCIdentifier.history)
            break
        case .pendingRequest:
            self.moveTOVC(GVCIdentifier.viewerPendingRequests)
            break
        case .becomeStreamer:
            let alert = GPAlert(title: "Become A Streamer", message: "Become a streamer to earn money!")
            AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    break
                case 1:
                    //Ok clicked
                    let requestModel = UserProfileRequestModel()
                    requestModel.user_id = GConstant.UserData.id!
                    requestModel.user_type = "S"
                    self.objVMSideMenu.callSwitchRoleApi(requestModel, completion: {
                        GFunction.shared.setHomePage(self.appDelegate.window)
                    })
                    break
                default:
                    break
                }
            }
            break
        case .messages:
            self.moveTOVC(GVCIdentifier.messages)
            break
        case .payment:
            if self.isUserTypeViewer() {
                self.moveTOVC(GVCIdentifier.payment)
            }else{
                self.moveTOVC(GVCIdentifier.streamerPayments)
            }
            break
        case .freeCredits:
            self.moveTOVC(GVCIdentifier.freeCredits)
            break
        case .settings:
            self.moveTOVC(GVCIdentifier.settings)
            break
        case .becomeViewer:
            let alert = GPAlert(title: "Become A Viewer", message: "Want to become a viewer?")
            AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
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
            
            break
        case .streamerHistory:
            self.moveTOVC(GVCIdentifier.history)
            break
        case .rate:
            SKStoreReviewController.requestReview()
            break
            
        }
    }
    
}


