//
//  VMHistory.swift
//  Instacam
//
//  Created by Apple on 16/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SDWebImage

class VMHistory: NSObject {
    
    var arrHistoryData: [HistoryResult] = []
    
    func callHistoryApi(_ requestModel: UserProfileRequestModel, completion: @escaping (Bool)->Void) {
        
        /*
         Api name: getStreamRequestsHistory
         Parameters: user_id
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getStreamRequestsHistory(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                self.arrHistoryData = []
                let responseModel = try! HistoryResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrHistoryData = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
    func callStreamerHistoryApi(_ requestModel: UserProfileRequestModel, completion: @escaping (Bool)->Void) {
        
        /*
         Api name: getStreamerStreamRequestsHistory
         Parameters: user_id
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.getStreamerStreamRequestsHistory(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                self.arrHistoryData = []
                let responseModel = try! HistoryResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrHistoryData = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
}

extension VCHistory: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objVMHistory.arrHistoryData.count
    }
    
    func configureCell() {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = objVMHistory.arrHistoryData[indexPath.row]
        var cell: CellHistory!
        if objAtIndex.status == 3 || objAtIndex.status == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: "CellCancelledHistory", for: indexPath) as? CellHistory
            
            if objAtIndex.status == 3 {
                cell.lblEstimatedTimePrice.text = "Stream duration".localized() + ": 00:00 " + "min".localized() + "  |  "   + "Stream price".localized() +  ": $\(objAtIndex.price!)"
            }else{
                cell.lblEstimatedTimePrice.text = "Estimated Time".localized() + ": \(objAtIndex.duration!) " + "min".localized() + "  |  "   + "Estimated Price".localized() +  ": $\(objAtIndex.price!)"
            }
            
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "CellHistory", for: indexPath) as? CellHistory
            
            if GConstant.UserData.userType == LoginUserType.viewer.rawValue {
                if let userData = objAtIndex.streamerID {
                    if userData.count > 0 {
                        cell.lblMessage.text = userData[0].fullName
                        let imageUrl = userData[0].profileImage!
                        cell.imgView.setImageWithDownload(imageUrl.url())
                    }
                    if let rating = objAtIndex.viewerRating {
                        cell.vwRating.rating = rating != "" ? Double(Float(rating)!) : 0
                    }else{
                        cell.vwRating.rating = 0
                    }
                }
            }else{
                if let userData = objAtIndex.userID {
                    if userData.count > 0 {
                        cell.lblMessage.text = userData[0].fullName
                        let imageUrl = userData[0].profileImage!
                        cell.imgView.setImageWithDownload(imageUrl.url())
                    }
                    
                    if let rating = objAtIndex.streamerRating {
                        cell.vwRating.rating = rating != "" ? Double(Float(rating)!) : 0
                    }else{
                        cell.vwRating.rating = 0
                    }
                    
                }
            }
            cell.lblEstimatedTimePrice.text = "Stream duration".localized() + ": \(objAtIndex.finalDuration!) " + "min".localized() + "  |  "   + "Stream price".localized() +  ": $\(objAtIndex.finalPrice!)"
        }
        
        cell.lblStatus.applyRotateAngle(status: StreamingStatus(rawValue: "\(objAtIndex.status!)")!)
        
        let apiKey = KeyManager.google
        let location = "\(objAtIndex.lat!),\(objAtIndex.lng!)"
        let imageSize = cell.imgMapView.frame.size
        let marker = "markers=icon:http://35.180.243.63:9000/images/location_pin.png"
        let mapUrl = "https://maps.googleapis.com/maps/api/staticmap?center=\(location)&zoom=16&size=\(Int(imageSize.width))x\(Int(imageSize.height))&style=visibility:on&\(marker)&key=\(apiKey)"
        
        if cell.imgMapView.image == nil {
            Alamofire.request(mapUrl).responseJSON { response in
                cell.imgMapView.image = UIImage(data: response.data!)
            }
        }
        
        cell.lblLocation.text = objAtIndex.location
        cell.lblDescription.text = objAtIndex.description
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        let nsdate = dateFormatter.date(from: objAtIndex.updatedAt!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


extension UILabel {
    
    func applyRotateAngle(_ angle: CGFloat = -40, status: StreamingStatus) {
        let radian = angle * (.pi / 180)
        self.transform = CGAffineTransform(rotationAngle: radian)
        
        switch status {
        case .cancel:
            self.textColor = .red
            self.text = "Cancelled".localized()
            break
            
        case .complete:
            self.textColor = UIColor.init(red: 0/255, green: 128/255, blue: 0/255, alpha: 1.0)
            self.text = "Completed".localized()
            break
            
        case .notConnected:
            self.textColor = .red
            self.text = "Missed Stream".localized()
            break
            
        default:
            break
        }
    }

}
