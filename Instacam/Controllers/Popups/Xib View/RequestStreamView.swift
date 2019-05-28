//
//  RequestStreamView.swift
//  Instacam
//
//  Created by Apple on 25/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class RequestStreamView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var componentsView: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var lblEstimatedPrice: UILabel!
    @IBOutlet weak var btnRequestStreamOutlet: UIButton!
    @IBOutlet weak var vwCollection: UICollectionView!
    
    struct TimeSlots {
        let value: String!
        let minValue: Int!
        let maxValue: Int!
    }

    var arrTimeSlots = [
        TimeSlots(value: "< 5 min", minValue: 1, maxValue: 5),
        TimeSlots(value: "5-10 min", minValue: 5, maxValue: 10),
        TimeSlots(value: "10-15 min", minValue: 10, maxValue: 15),
        TimeSlots(value: "15 min +", minValue: 15, maxValue: 60)
    ]
    
    var selectedIndex = 0
    
    var marker = GMSMarker()
    var latitude = String()
    var longitude = String()
    var location = String()
    
    var delegate: SwipeViewDelegate!
    var vwHeight = CGFloat()
    
    var objVMRequestStream = VMRequestStream()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RequestStreamView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        vwCollection.delegate = self
        vwCollection.dataSource = self
        vwCollection.register(UINib(nibName: "CellTimeSlots", bundle: nil), forCellWithReuseIdentifier: "CellTimeSlots")
        
        self.btnRequestStreamOutlet.layer.cornerRadius = self.btnRequestStreamOutlet.bounds.midY
        self.btnRequestStreamOutlet.clipsToBounds = true

        self.loadRequestStreamView()
        self.vwHeight = self.frame.size.height
        self.isHidden = true
    }
    
    func loadRequestStreamView() {
        tfMessage.text = ""
        self.calculateEstimateTime()
    }
    
    func storeDataLocally() {
        var model = StreamRequestCodableModel()
        model.desc = self.tfMessage.text!
        model.lat = latitude
        model.lng = longitude
        model.location = location
        model.selectedIndex = self.selectedIndex
        model.placeName = self.lblName.text!
        model.placeAddress = self.lblAddress.text!
        
        let data = try! JSONEncoder().encode(model)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: GConstant.UserDefaults.kRequestStreamData)
        userDefaults.synchronize()
    }
    
    @IBAction func btnRequestStream(_ sender: UIButton) {
        self.endEditing(true)
        let validationAlert = validateView()
        
        if validationAlert == nil {
            let requestModel = StreamRequestModel()
            requestModel.desc = self.tfMessage.text!
            requestModel.duration = self.objVMRequestStream.selectedDuration
            requestModel.price = self.objVMRequestStream.selectedPrice?.replacingOccurrences(of: "$", with: "")
            requestModel.user_id = GConstant.UserData.id
            requestModel.lat = latitude
            requestModel.lng = longitude
            requestModel.location = location
            requestModel.selectedIndex = self.selectedIndex
            requestModel.placeName = self.lblName.text!
            requestModel.placeAddress = self.lblAddress.text!
            
            self.storeDataLocally()
            
            guard !GFunction.shared.checkForProfileCompletePresent() else { return }
            guard !GFunction.shared.checkForPaymentGatewayPresent() else { return }

            objVMRequestStream.callRequestStreamApi(requestModel, completion: {
                self.delegate.clearSearchbarText()
                self.delegate.reloadMap()
                self.hide()
                GFunction.shared.removeUserDefaults(key: GConstant.UserDefaults.kRequestStreamData)
            })
        }else{
            AlertManager.shared.show(validationAlert!)
        }
        
    }
    
    @IBAction func btnPriceInfo(_ sender: UIButton) {
        
    }
    
    func hide() {
        GNavigation.shared.revealController.panGestureRecognizer()?.isEnabled = true
        self.isHidden = false
        self.delegate.clearSearchbarText()
        
        delegate.didPressedOnStrip(false, visible: -self.frame.size.height+50, completion: {
            self.componentsView.isHidden = true
        })
    }
    
    func show() {
        self.componentsView.isHidden = false
        GNavigation.shared.revealController.panGestureRecognizer()?.isEnabled = false
        delegate.didPressedOnStrip(true, visible: 0, completion: {
        })
    }
    
    @IBAction func btnPressedOnStrip(_ sender: UIButton) {
        GFunction.shared.removeUserDefaults(key: GConstant.UserDefaults.kRequestStreamData)
        marker.map = nil
        self.hide()
    }
    
    func validateView() -> GPAlert?{
        var alert: GPAlert? = nil
        if tfMessage.text!.isEmpty {
            alert = GPAlert(title: "Description", message: "Please enter Description")
        }else if lblEstimatedPrice.text!.isEmpty {
            alert = GPAlert(title: "Estimated Price", message: "Please enter an Estimated Price")
        }
        return alert
    }
    
}

