//
//  VMRequestStream.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class VMRequestStream: NSObject {
    
    var selectedPrice: String!
    var selectedDuration: String!
    
    func callRequestStreamApi(_ requestModel: StreamRequestModel, completion: @escaping ()->Void) {
        
        /*
         Api name: streamRequest
         Parameters: "user_id, location, lat, lng, duration, price
         Optional: description"
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.streamRequest(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! RequestStreamResponseModel.init(data: data)
                if let status = responseModel.success {
                    if status == 200 {
                        
                        let vc = self.instantiateVC(with: GVCIdentifier.popupRequestSent) as! VCPopupRequestSent
                        vc.modalPresentationStyle = .overCurrentContext
                        GNavigation.shared.present(vc)
                        
//                        let alert = GPAlert(title: "Hey \(GConstant.UserData.fullName!)", message: "Request submitted, Trying to find a streamer.")
//                        AlertManager.shared.show(alert)
                        completion()
                    }else{
                        let alert = GPAlert(title: "", message: responseModel.message ?? "")
                        AlertManager.shared.show(alert)
                    }
                }
                
            }
            
        }
        
    }
    
}

extension RequestStreamView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTimeSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellTimeSlots", for: indexPath) as! CellTimeSlots
        cell.vwBackground.layer.borderColor = GConstant.AppColor.darkSkyBlue?.cgColor
        cell.vwBackground.layer.borderWidth = 1
        
        cell.vwBackground.layer.cornerRadius = cell.vwBackground.bounds.midY
        cell.vwBackground.clipsToBounds = true
        
        if selectedIndex == indexPath.row {
            cell.vwBackground.backgroundColor = GConstant.AppColor.darkSkyBlue
            cell.lblValue.textColor = .white
        }else{
            cell.vwBackground.backgroundColor = .white
            cell.lblValue.textColor = GConstant.AppColor.darkSkyBlue
        }
        
        cell.lblValue.text = arrTimeSlots[indexPath.row].value.localized()
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
        
        self.calculateEstimateTime()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 40)
    }
    
    func calculateEstimateTime() {
        let selectedValue = arrTimeSlots[selectedIndex].value
        
        if (selectedValue?.range(of: "<") != nil) {
            let duration = Int(arrTimeSlots[selectedIndex].maxValue)*60
            let calcuatedPrice = (Float(duration-60) * 0.01) + 1.00
            self.lblEstimatedPrice.text = "< \(String(format:"$%.2f", calcuatedPrice))"
            
            objVMRequestStream.selectedPrice = String(format:"$%.2f", calcuatedPrice)
            objVMRequestStream.selectedDuration = "\(arrTimeSlots[selectedIndex].maxValue!)"
        }
        
        if (selectedValue?.range(of: "-") != nil) {
            let minDuration = Int(arrTimeSlots[selectedIndex].minValue)*60
            let maxDuration = Int(arrTimeSlots[selectedIndex].maxValue)*60
            let minCalcuatedPrice = (Float(minDuration-60) * 0.01) + 1.00
            let maxCalcuatedPrice = (Float(maxDuration-60) * 0.01) + 1.00
            self.lblEstimatedPrice.text = "\(String(format:"$%.2f", minCalcuatedPrice)) - \(String(format:"$%.2f", maxCalcuatedPrice))"
            
            objVMRequestStream.selectedPrice = String(format:"$%.2f", maxCalcuatedPrice)
            objVMRequestStream.selectedDuration = "\(arrTimeSlots[selectedIndex].maxValue!)"
        }
        
        if (selectedValue?.range(of: "+") != nil) {
            let duration = Int(arrTimeSlots[selectedIndex].minValue)*60
            let calcuatedPrice = (Float(duration-60) * 0.01) + 1.00
            self.lblEstimatedPrice.text = "\(String(format:"$%.2f", calcuatedPrice)) +"
            
            objVMRequestStream.selectedPrice = String(format:"$%.2f", calcuatedPrice)
            objVMRequestStream.selectedDuration = "\(arrTimeSlots[selectedIndex].minValue!)"
        }
        
    }
    
}
