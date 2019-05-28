//
//  VMCredits.swift
//  Instacam
//
//  Created by Apple on 19/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import VeeContactPicker
import MessageUI

class VMCredits: NSObject {
    
    var shareText = "Hi, I'm sending you $5 in free credit on Instacam. Instacam lets you request a personalized live video stream by location or event. You can also become a streamer and earn up to $30/hour with just your phone! Download the app and use code".localized() + " '\(GConstant.UserData.inviteCode!)' " + "to sign up. Link:".localized() +  " http://onelink.to/"
    
    func shareTextViaMessage(_ recipientsArray: [String]) {
        if (MFMessageComposeViewController.canSendText())
        {
            let controller = MFMessageComposeViewController()
            controller.body = shareText
            controller.recipients = recipientsArray
            controller.messageComposeDelegate = self
            GNavigation.shared.present(controller, isAnimated: true)
        }
        else
        {
            print("Error")
        }
    }
    
}

extension VMCredits: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension VCCredits: VeeContactPickerDelegate {
    func didSelectContact(_ veeContact: VeeContactProt) {
        // Handle Single Contact Here
    }
    
    func didSelectContacts(_ veeContacts: [VeeContactProt]) {
        var arrSelection: [String] = []
        for number in veeContacts {
            for contact in number.phoneNumbers {
                arrSelection.append(contact)
            }
        }
        
        dismiss(animated: true, completion: {
            self.objVMCredits.shareTextViaMessage(arrSelection)
        })
        
    }
    
    func didCancelContactSelection() {
        dismiss(animated: true, completion: nil)
    }
    
    func didFailToAccessAddressBook() {
        // Handle Fail Case Here
    }
    
    
}
