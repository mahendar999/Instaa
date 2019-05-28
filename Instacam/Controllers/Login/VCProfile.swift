//
//  VCProfile.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCProfile: UIViewController {
    
    @IBOutlet weak var btnSubmitOutlet: UIButton!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfLocation: UITextField!
    @IBOutlet weak var tfDevice: UITextField!
    @IBOutlet weak var tfLanguages: UITextField!
    @IBOutlet weak var tfBio: UITextField!
    @IBOutlet weak var vwImageView: UIView!
    @IBOutlet weak var imgView: UIImageView!

    var objVMCompleteProfile = VMCompleteProfile()
    var objVMProfile = VMProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
        
        if  let data = GConstant.UserData {
            tfName.text = data.fullName
            tfEmail.text = data.email
            tfBio.text = data.bio
            
            if data.device != nil{
                tfDevice.text = data.device! == "" ? UIDevice.modelName : data.device!
            }else{
                tfDevice.text = UIDevice.modelName
            }
            
            var strAdress = String()
            if let city = data.city {
                strAdress = city == "" ? "" : strAdress + city + ", "
            }
            if let country = data.country {
                strAdress = country == "" ? "" : strAdress + country
            }
            
            tfLocation.text = strAdress
            
            var arrLanguages: [String] = []
            if let _languages = data.languages {
                for lang in _languages {
                    let trimmedString = lang.language!.trimmingCharacters(in: .whitespaces)
                    arrLanguages.append(trimmedString)
                }
                
                tfLanguages.text = arrLanguages.count > 0 ? arrLanguages.joined(separator: ", ") : ""
            }
            
            let imageUrl = data.profileImage?.url()
            imgView.setImageWithDownload(imageUrl!)
            
            self.objVMProfile.address = data.address!
            self.objVMProfile.latitude = data.lat!
            self.objVMProfile.longitude = data.lng!
            self.objVMProfile.city = data.city!
            self.objVMProfile.state = data.state!
            self.objVMProfile.postalCode = data.postalCode!
            self.objVMProfile.country = data.country!
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: UIImage(named: "menu")), btnRight: nil, title: "Profile".localized())
        self.navigationController?.customize()
        
        let _color = GConstant.AppColor.lightSkyBlue!
        self.tfName.addRightWithText(string: "NAME".localized())
        self.tfName.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfEmail.addRightWithText(string: "EMAIL".localized())
        self.tfEmail.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfLocation.addRightWithText(string: "LOCATION".localized())
        self.tfLocation.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfDevice.addRightWithText(string: "DEVICE".localized())
        self.tfDevice.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfLanguages.addRightWithText(string: "LANGUAGES".localized())
        self.tfLanguages.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfBio.addRightWithText(string: "BIO".localized())
        self.tfBio.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfLocation.delegate = self
        self.tfDevice.isUserInteractionEnabled = false
        self.tfLanguages.delegate = self
        
        self.btnSubmitOutlet.roundedCorener()
        self.vwImageView.roundedCorener()
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    @IBAction func btnAddImage(_ sender: UIButton) {
        ImagePickerManager.shared.callPickerOptions(sender) { (pickedImage, imageData) in
            self.objVMCompleteProfile.mainImage = pickedImage
            self.objVMCompleteProfile.isProfileSelected = true
            self.imgView.image = pickedImage
            
            let requestModel = UserProfileRequestModel()
            requestModel.user_id = GConstant.UserData.id
            
            self.objVMCompleteProfile.callUploadImageApi(requestModel, imageData: imageData)
        }
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        self.view.endEditing(true)
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id
        requestModel.full_name = tfName.text!
        requestModel.email = tfEmail.text!
        requestModel.device = tfDevice.text!
        requestModel.device_type = "iOS"
        requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
        requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
        
        let trimmedString = tfLanguages.text!.trimmingCharacters(in: .whitespaces)
        requestModel.languages = trimmedString
        
        requestModel.address = self.objVMProfile.address
        requestModel.lat = self.objVMProfile.latitude
        requestModel.lng = self.objVMProfile.longitude
        requestModel.city = self.objVMProfile.city
        requestModel.state = self.objVMProfile.state
        requestModel.postal_code = self.objVMProfile.postalCode
        requestModel.country = self.objVMProfile.country
        
        requestModel.bio = tfBio.text!
        self.objVMCompleteProfile.callCompleteProfileApi(requestModel) { (identifier) -> Void in
            DispatchQueue.main.async {
                let alert = GPAlert(title: "", message: "Profile updated successfully")
                AlertManager.shared.showPopup(alert, forTime: 2.0, completionBlock: { (INT) in
                    //GNavigation.shared.pop()
                })
            }
        }
    }
    

    

}
