//
//  VCProfile.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Photos

class VCCompleteProfile: UIViewController {
    
    @IBOutlet weak var btnSubmitOutlet: UIButton!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var vwImageView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    var objVMCompleteProfile = VMCompleteProfile()
    var isProfileCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        if isProfileCompleted {
            _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Complete Profile".localized())
        }else{
            _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Skip".localized()), title: "Complete Profile".localized())
        }
        
        let _color = GConstant.AppColor.lightSkyBlue!
        self.tfName.addRightWithText(string: "NAME".localized())
        self.tfName.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfEmail.addRightWithText(string: "EMAIL".localized())
        self.tfEmail.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.tfPassword.addRightWithText(string: "PASSWORD".localized())
        self.tfPassword.addLine(position: LINE_POSITION.LINE_POSITION_BOTTOM, color: _color, width: 1.0)
        
        self.btnSubmitOutlet.roundedCorener()
        self.vwImageView.roundedCorener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        GConstant.isCompleteProfilePresent = false
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }
    
    @objc func rightButtonClicked() {
        GFunction.shared.storeLoginData(GConstant.UserData)
        GFunction.shared.setHomePage(self.appDelegate.window)
    }
    
    @IBAction func btnAddImage(_ sender: UIButton) {
        ImagePickerManager.shared.callPickerOptions(sender) { (pickedImage, imageData) in
            self.objVMCompleteProfile.mainImage = pickedImage
            self.objVMCompleteProfile.isProfileSelected = true
            self.imgView.image = pickedImage
            
            let requestModel = UserProfileRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.user_type = GConstant.UserData.userType
            
            self.objVMCompleteProfile.callUploadImageApi(requestModel, imageData: imageData)
        }
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        self.view.endEditing(true)
        let validationAlert = validateView()
        if validationAlert == nil {
            let requestModel = UserProfileRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.full_name = tfName.text!
            requestModel.email = tfEmail.text!
            requestModel.password = tfPassword.text!
            requestModel.device = UIDevice.modelName
            requestModel.is_profile_created = "Y"
            requestModel.user_type = GConstant.UserData.userType
            requestModel.device_type = "iOS"
            requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
            requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
            
            let objLocationManager = LocationManager.shared.currentLocation
            if objLocationManager != nil {
                requestModel.lat = "\(objLocationManager!.coordinate.latitude)"
                requestModel.lng = "\(objLocationManager!.coordinate.longitude)"
            }
            
            self.objVMCompleteProfile.callCompleteProfileApi(requestModel) { (identifier) -> Void in
                DispatchQueue.main.async {
                    if self.isUserTypeViewer() {
                        if self.isProfileCompleted {
                            GNavigation.shared.pop()
                        }else{
                            GFunction.shared.storeLoginData(GConstant.UserData)
                            GFunction.shared.setHomePage(self.appDelegate.window)
                        }
                    }else{
                        GNavigation.shared.pop()
                    }
                }
            }
        }else{
            AlertManager.shared.show(validationAlert!)
        }
        
    }
    
    func validateView() -> GPAlert?{
        var alert: GPAlert? = nil
        if tfName.text!.isEmpty {
            alert = GPAlert(title: "Name", message: "Please enter a Name")
        }else if tfEmail.text!.isEmpty {
            alert = GPAlert(title: "Email", message: "Please enter an Email")
        }else if !tfEmail.text!.isValidEmail() {
            alert = GPAlert(title: "Email", message: "Please enter valid Email")
        }else if tfPassword.text!.isEmpty {
            alert = GPAlert(title: "Password", message: "Please enter a Password")
        }else if tfPassword.text!.count < 8 {
            alert = GPAlert(title: "Password", message: "Password should be at least 8 characters")
        }
        return alert
    }

}

enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UITextField {
    func addRightWithText(string:String){
        var labelWidth = string.width(withConstrainedHeight: self.frame.size.height, font: self.font!)
        
        labelWidth = labelWidth + 12;
        
        let labelView = UILabel.init(frame: CGRect.init(x: self.frame.size.height-(labelWidth+5), y: 0, width: labelWidth, height: self.frame.size.height))
        labelView.text = string
        labelView.textColor = GConstant.AppColor.darkSkyBlue
        
        self.rightView = labelView
        self.rightViewMode = .always
    }
    
    func addLeftViewWithText(string:String){
        var labelWidth = string.width(withConstrainedHeight: self.frame.size.height, font: self.font!)
        
        labelWidth = labelWidth + 12;
        
        let labelView = UILabel.init(frame: CGRect.init(x: self.frame.size.height-(labelWidth+5), y: 0, width: labelWidth, height: self.frame.size.height))
        labelView.text = string
        
        self.leftView = labelView
        self.leftViewMode = .always
    }
    
    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        default:
            break
        }
    }
}
