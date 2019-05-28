//
//  VCSideMenu.swift
//  Instacam
//
//  Created by Apple on 01/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Cosmos

class VCSideMenu: UIViewController {

    @IBOutlet weak var vwImgBg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var constPlaceYConstraint: NSLayoutConstraint!
    @IBOutlet weak var constPlaceHeightConstraint: NSLayoutConstraint!
    
    var objVMSideMenu = VMSideMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initMainView()
        
        let frontView = self.revealViewController()?.frontViewController.view
        let vw = UIView(frame: (frontView?.bounds)!)
        vw.isUserInteractionEnabled = true
        vw.backgroundColor = .clear
        vw.tag = 999
        frontView?.addSubview(vw)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        vw.addGestureRecognizer(tapGesture)
        vw.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
    }
    
    @objc func tapOnView() {
        self.revealViewController()?.revealToggle(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let frontView = self.revealViewController()?.frontViewController.view
        if let vw = frontView!.viewWithTag(999) {
            vw.removeFromSuperview()
        }
    }
    
    func initMainView() {
        vwImgBg.roundedCorener()
        imgView.roundedCorener()
        
        if  let data = GConstant.UserData {
            lblName.text = data.fullName
            
            var strAdress = String()
            if let city = data.city {
                strAdress = city == "" ? "" : strAdress + city + ", "
            }
            
            if let country = data.country {
                strAdress = country == "" ? "" : strAdress + country
            }
            
            if strAdress == "" {
                constPlaceYConstraint.constant = 0
            }
            
            lblLocation.text = strAdress
            
            let imageUrl = data.profileImage?.url()
            imgView.setImageWithDownload(imageUrl!)
            
            if GConstant.UserRoleRating != nil {
                lblRating.text = GConstant.UserRoleRating.rating == "0" ? " 0.0" : " \(GConstant.UserRoleRating.rating!)"
                let amount = GConstant.UserRoleRating.amount == "0" ? "0.0" : "\(GConstant.UserRoleRating.amount!)"
                lblPrice.text = "$\(amount)"
            }
        }
    }
    
    @IBAction func btnViewProfile() {
        self.revealViewController()?.revealToggle(self)
        guard !GFunction.shared.checkForProfileCompletePresent() else { return }
        self.moveTOVC(GVCIdentifier.profile)
    }
    
    @IBAction func btnInsta() {
        let url = URL(string: "https://www.instagram.com/instacamapp/")
        UIApplication.shared.open(url!)
    }
    
    @IBAction func btnTwitter() {
        let url = URL(string: "https://twitter.com/instacamapp/")
        UIApplication.shared.open(url!)
    }
    
    @IBAction func btnFacebook() {
        let url = URL(string: "https://www.facebook.com/instacamapp/")
        UIApplication.shared.open(url!)
    }

}


