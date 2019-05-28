//
//  VCTrackingDrawPath.swift
//  Instacam
//
//  Created by Apple on 27/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class VCTrackingDrawPath: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    var objVMPendingRequests = VMPendingRequests()
    var objVMAPIs = VMAPIs()
    var streamRequestData: StreamTrackDataManager!
    var UpdateLocationTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewerCoordinates = CLLocationCoordinate2D()
        var streamerCoordinates = CLLocationCoordinate2D()
        
        let data = Payload.shared
        let latitude = (data.lat! as NSString).doubleValue
        let longitude = (data.long! as NSString).doubleValue
        viewerCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let dataModel = StreamTrackDataManager()
        dataModel.handleData()
        streamRequestData = dataModel
        
        if streamRequestData.dataExist {
            lblMessage.text = streamRequestData.message
            let latitude = (streamRequestData.latitude as NSString).doubleValue
            let longitude = (streamRequestData.longitude as NSString).doubleValue
            streamerCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            DrawPathManager.shared.drawPath(mapView, viewerCoord: viewerCoordinates, streamerCoord: streamerCoordinates, isUpdating: false) { (mapData) in
                self.lblTime.text = mapData.time
                self.lblDistance.text = mapData.distance
            }
        }else{
            lblMessage.text = ""
            let camera = GMSCameraPosition.camera(withTarget: viewerCoordinates, zoom: 16)
            mapView.camera = camera
            mapView.isMyLocationEnabled = false
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            
            let image = UIImage(named: "location_pin")
            let marker = GMSMarker()
            marker.icon = image
            marker.position = viewerCoordinates
            marker.map = self.mapView
            
            self.lblTime.text = ""
            self.lblDistance.text = ""
        }
        
        if UpdateLocationTimer == nil {
            UpdateLocationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateDrawPath), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UpdateLocationTimer.invalidate()
    }
    
    @objc func updateDrawPath() {
        var viewerCoordinates = CLLocationCoordinate2D()
        var streamerCoordinates = CLLocationCoordinate2D()
        
        let data = Payload.shared
        let latitude = (data.lat! as NSString).doubleValue
        let longitude = (data.long! as NSString).doubleValue
        viewerCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let dataModel = StreamTrackDataManager()
        dataModel.handleData()
        streamRequestData = dataModel
        
        if streamRequestData.dataExist {
            lblMessage.text = streamRequestData.message
            let latitude = (streamRequestData.latitude as NSString).doubleValue
            let longitude = (streamRequestData.longitude as NSString).doubleValue
            streamerCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            DrawPathManager.shared.drawPath(mapView, viewerCoord: viewerCoordinates, streamerCoord: streamerCoordinates, isUpdating: true) { (mapData) in
                self.lblTime.text = mapData.time
                self.lblDistance.text = mapData.distance
            }
        }else{
            lblMessage.text = ""
            let camera = GMSCameraPosition.camera(withTarget: viewerCoordinates, zoom: 16)
            mapView.camera = camera
            mapView.isMyLocationEnabled = false
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            
            let image = UIImage(named: "location_pin")
            let marker = GMSMarker()
            marker.icon = image
            marker.position = viewerCoordinates
            marker.map = self.mapView
            
            self.lblTime.text = ""
            self.lblDistance.text = ""
        }
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        GNavigation.shared.pop()
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        
        var serverDate = Date()
        var alert:GPAlert!

        if streamRequestData.dataExist && !streamRequestData.timestamp.isEmpty {
            let serverTimestamp = Int64(streamRequestData.timestamp)
            serverDate = Date(millis: serverTimestamp!)
            
            if serverDate > Date() {
                alert = GPAlert(title: "Are you certain you want to cancel?", message: "You will be charged a $1.00 cancellation fee.")
            }else{
                alert = GPAlert(title: "Cancel", message: "Are you certain you want to cancel?")
            }
        }else{
            alert = GPAlert(title: "Are you certain you want to cancel?", message: "You will be charged a $1.00 cancellation fee.")
        }
        
        AlertManager.shared.show(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                // No
                break
            case 1:
               
                let requestModel = NotificationRequestModel()
                requestModel.user_id = GConstant.UserData.id
                requestModel.isAccepted = "1"
                requestModel.stream_id = Payload.shared.streamId
                requestModel.status = StreamingStatus.cancel.rawValue
                GFunction.shared.addLoader(nil)
                self.objVMAPIs.callupdateStreamStatusApi(requestModel) {
                    GFunction.shared.removeLoader()
                    GNavigation.shared.popToRoot(VCHome.self)
                }
                
                break
            default:
                break
            }
        }
        
    }

}

class StreamTrackDataManager {
    var latitude, longitude, timestamp, message: String!
    var dataExist: Bool = false
    
    func handleData() {
        if UserDefaults.standard.value(forKey: GConstant.UserDefaults.kStreamTrackData) != nil {
            let dict = UserDefaults.standard.value(forKey: GConstant.UserDefaults.kStreamTrackData) as! [String:String]

            latitude = dict["latitude"]
            
            if latitude == "" {
                dataExist = false
            }else{
                dataExist = true
                longitude = dict["longitude"]
                timestamp = dict["timestamp"]
                message = dict["message"]
            }
            
        }else{
            dataExist = false
        }
    }
}

