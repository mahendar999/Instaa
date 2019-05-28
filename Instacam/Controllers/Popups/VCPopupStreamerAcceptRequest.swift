//
//  VCStreamerAcceptRequest.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class VCPopupStreamerAcceptRequest: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblEstimatedTimePrice: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var objVMStreamerRequestAccept = VMStreamerRequestAccept()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMainView()
    }
    
    func initMainView() {
        if let data = CallJoinData.shared.objStreamRequest {
            
            // load Map
            let latitude = (data.lat! as NSString).doubleValue
            let longitude = (data.lng! as NSString).doubleValue
            
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
            self.mapView.camera = camera
            self.mapView.isUserInteractionEnabled = false
            
            let image = UIImage(named: "location_pin")
            let marker = GMSMarker()
            marker.icon = image
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.map = self.mapView
            
            // Show Viewer Request Data
            lblMessage.text = "\(data.viewerName!) " + "want to see this Location".localized()
            lblLocation.text = data.location
            lblDescription.text = data.description
            lblEstimatedTimePrice.text = "Estimated Time".localized() + ": \(data.duration!) " + "min".localized() + "  |  "   + "Estimated Price".localized() +  ": $\(data.price!)"
        
        }
        
    }
    
    @IBAction func btnCross(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnAccept(_ sender: UIButton) {
        
        guard !GFunction.shared.checkForProfileCompletePresent() else { return }
        guard !GFunction.shared.checkForStreamerPaymentGatewayPresent() else { return }
        
        let requestModel = StreamRequestModel()
        requestModel.streamer_id = GConstant.UserData.id
        requestModel.stream_id = CallJoinData.shared.streamId
        
        requestModel.source_lat = "\(LocationManager.shared.currentLocation.coordinate.latitude)"
        requestModel.source_lng = "\(LocationManager.shared.currentLocation.coordinate.longitude)"
        requestModel.dest_lat = "\(CallJoinData.shared.viewerCoordinate.latitude)"
        requestModel.dest_lng = "\(CallJoinData.shared.viewerCoordinate.longitude)"
        
        objVMStreamerRequestAccept.callAcceptRequest(requestModel) {
            GNavigation.shared.dismiss(false) {
                let vcTrackingDrawPath = self.instantiateVC(with: GVCIdentifier.streamerTrackingDrawhPath) as! VCStreamerTrackingDrawPath
                GNavigation.shared.push(vcTrackingDrawPath)
            }
        }
    }
    
}


