//
//  VMProfile.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import Photos
import GooglePlaces

class VMProfile: NSObject {
    
    var address: String = ""
    var country: String = ""
    var city: String = ""
    var postalCode: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var state: String = ""
    
    func callGetProfileApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void) {
        
        /*
         Api name: getProfile
         Parameters: user_id
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getProfile(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let loginResult = responseModel.result {
                            GConstant.UserData = loginResult
                            completion()
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
}

extension VCProfile: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfLocation {
            PlacePickerManager.shared.placePicker { (place) in
                PlacePickerManager.shared.findPlace(place.coordinate, completion: { (address) in
                    self.tfLocation.text = PlacePickerManager.shared.getLocation(address, type: .custom)
                    
                    self.objVMProfile.address = PlacePickerManager.shared.getLocation(address, type: .full)
                    self.objVMProfile.latitude = "\(place.coordinate.latitude)"
                    self.objVMProfile.longitude = "\(place.coordinate.longitude)"
                    
                    if address.locality != nil {
                        self.objVMProfile.city = address.locality!
                    }
                    if address.administrativeArea != nil {
                        self.objVMProfile.state = address.administrativeArea!
                    }
                    if address.postalCode != nil {
                        self.objVMProfile.postalCode = address.postalCode!
                    }
                    if address.country != nil {
                        self.objVMProfile.country = address.country!
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        if textField == tfLanguages {
            let vcPicker = self.instantiateVC(with: GVCIdentifier.languagePicker) as! VCLanguagePicker
            vcPicker.completion = { (languages) -> Void in
                self.tfLanguages.text = languages
            }
            
            if let data = GConstant.UserData {
                var arrLanguages: [String] = []
                if let _languages = data.languages {
                    for lang in _languages {
                        let trimmedString = lang.language!.trimmingCharacters(in: .whitespaces)
                        arrLanguages.append(trimmedString)
                    }
                    vcPicker.arrSelectedValues = arrLanguages
                }
                
            }
            
            let navigation = UINavigationController(rootViewController: vcPicker)
            GNavigation.shared.present(navigation, isAnimated: true)
        }
    }
}
