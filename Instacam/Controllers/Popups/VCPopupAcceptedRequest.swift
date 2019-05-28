//
//  VCAcceptedRequest.swift
//  Instacam
//
//  Created by Apple on 25/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class VCPopupAcceptedRequest: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tfEstimatedTime: UITextField!
    @IBOutlet weak var tfEstimatedPrice: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnNextOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
        
    }
    
    func initMainView() {

        let data = Payload.shared
        if data.actionType != nil {
            
            // load Map
            let latitude = (data.lat! as NSString).doubleValue
            let longitude = (data.long! as NSString).doubleValue
            
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
            self.mapView.camera = camera
            self.mapView.isUserInteractionEnabled = false
            
            let image = UIImage(named: "location_pin")
            let marker = GMSMarker()
            marker.icon = image
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.map = self.mapView
            
            // Show Viewer Request Data
            lblMessage.text = data.message
            tfEstimatedTime.text = "\(data.duration!) min"
            tfEstimatedPrice.text = "$\(data.price!)"
            
        }

        btnNextOutlet.layer.cornerRadius = btnNextOutlet.bounds.midY
        btnNextOutlet.clipsToBounds = true
        
        
    }
    
    @IBAction func btnCross(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        GNavigation.shared.dismiss(false) {
            let vcTrackingDrawPath = self.instantiateVC(with: GVCIdentifier.trackingDrawhPath) as! VCTrackingDrawPath
            GNavigation.shared.push(vcTrackingDrawPath)
        }
    }
    
    @IBAction func btnInfo(_ sender: UIButton) {
        
    }
    

}
