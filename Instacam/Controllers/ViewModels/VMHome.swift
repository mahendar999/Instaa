//
//  VMHome.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import AgoraRtcEngineKit
import GoogleMaps
import GooglePlaces
import Alamofire

class VMHome: NSObject {
    
    var arrRequests: [StreamRequestsResult] = []
    var arrFeaturedLocations: [FeaturedLocationResult] = []
    var arrFeaturedEvents: [FeaturedLocationResult] = []
    var isComingAfterPresentView = false
    var activeStreamRequest: StreamRequestsResult!
    
    func callGetStreamRequestApi(_ requestModel: StreamRequestModel, isLoader: Bool, completion: @escaping (Bool)->Void) {
        
        /*
         Api name: getStreamRequests
         Parameters: streamer_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.getStreamRequests(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! StreamRequestsResponseModel.init(data: data)
                self.arrRequests = []
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrRequests = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
    func callGetFeturedLocationApi(_ requestModel: StreamRequestModel, completion: @escaping (Bool)->Void) {
        
        /*
         Api name: getFeaturedLocations
         Parameters: user_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.getFeaturedLocations(), parameter: requestModel.toDictionary()) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! FeaturedLocationResponseModel.init(data: data)
                self.arrFeaturedLocations = []
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrFeaturedLocations = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
    func callGetFeturedEventsApi(_ requestModel: StreamRequestModel, isLoader: Bool, completion: @escaping (Bool)->Void) {
        
        /*
         Api name: getFeaturedEvents
         Parameters: user_id
         Method: POST
        */
        
        APICall.shared.POST(strURL: GAPIConstant.getFeaturedEvents(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! FeaturedLocationResponseModel.init(data: data)
                self.arrFeaturedEvents = []
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        self.arrFeaturedEvents = responseModel.result!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
}

// MARK:- Setup streamer and viewer

extension VCHome {
    
    func setupForStreamer(withLoader: Bool = true) {
        _ = addBarButtons(btnLeft: BarButton(image: UIImage(named: "menu")), btnRight: nil, title: "Instacam Streamer".localized())
        self.nearbyRequestsView.delegate = self
        
        // setup Swipe view
        self.nearbyRequestsView.hide()
        
        let image = UIImage(named: "location_pin")
        let requestModel = StreamRequestModel()
        requestModel.streamer_id = GConstant.UserData.id
        objVMHome.callGetStreamRequestApi(requestModel, isLoader: withLoader) { (success) -> Void in
            
            var arrRequests: [StreamRequestsResult] = []
            if success {
                
                arrRequests = self.objVMHome.arrRequests.filter({ (objModel) -> Bool in
                    if arrRequests.count == 0 && (objModel.status == 1 || objModel.status == 6) {
                        arrRequests.append(objModel)
                        return true
                    }
                    return false
                })
                
                if arrRequests.count > 0 {
                    self.nearbyRequestsView.arrRequests = arrRequests
                    self.nearbyRequestsView.sectionName = "Accepted".localized()
                }else{
                    arrRequests = self.objVMHome.arrRequests.filter({ (objModel) -> Bool in
                        if objModel.status == 0 {
                            return true
                        }
                        return false
                    })
                    self.nearbyRequestsView.arrRequests = arrRequests
                    self.nearbyRequestsView.sectionName = "New".localized()
                }
                
            }else{
                self.nearbyRequestsView.sectionName = ""
                self.nearbyRequestsView.arrRequests = []
            }
            
            EmptyDataManager.shared.addView(on: self.nearbyRequestsView.vwTable, title: "", message: "No Nearby request available!")
            self.nearbyRequestsView.vwTable.reloadData()
            self.mapView.clear()
            
            // setup Swipe view
            self.nearbyRequestsView.hide()
            
            self.mapView.isHidden = false
            self.mapView.setCameraToCurrentLocation()
            self.mapView.delegate = self
            
            for data in arrRequests {
                let latitude = (data.lat! as NSString).doubleValue
                let longitude = (data.lng! as NSString).doubleValue
                
                let markerView = GFunction.shared.viewFromNibName(name: "CustomMarkerView") as! CustomMarkerView
                markerView.lblPrice.text = "$\(data.price!)"
                
                let marker = GMSMarker()
                marker.iconView = markerView
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                marker.userData = data
                marker.title = data.location!
                marker.snippet = data.description!
                marker.map = self.mapView
            }
            
        }
    }
    
    func setupForViewer() {
        self.mapView.clear()
        
        if self.objVMHome.isComingAfterPresentView {
            self.objVMHome.isComingAfterPresentView = false
            return
        }
        
        _ = addBarButtons(btnLeft: BarButton(image: UIImage(named: "menu")), btnRight: nil, title: "Instacam Viewer".localized())
        // setup Swipe view
        self.requestStreamView.delegate = self
        self.featuredLocationsView.delegate = self
        
        let shimmerView = self.btnInProgressOutlet.applyShimmering()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnInProgress(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        shimmerView.addGestureRecognizer(tapGesture)
        
        self.constHeightRequestProgress.constant = 0
        self.vwRequestProgress.isHidden = true
        self.view.layoutIfNeeded()
        
        self.requestStreamView.hide()
        
        self.loadPendingRequests()
        self.loadFeaturedLocations()
        
    }
    
    @objc func btnInProgress(_ sender: UIButton) {
        if let data = self.objVMHome.activeStreamRequest {
            Payload.shared.channel = data.channelName
            Payload.shared.lat = data.lat
            Payload.shared.long = data.lng
            Payload.shared.streamId = data.id
            if let streamerId = data.streamerID{
                Payload.shared.streamerId = streamerId.count > 0 ? streamerId[0] : ""
            }
        }
        
        let vcTrackingDrawPath = self.instantiateVC(with: GVCIdentifier.trackingDrawhPath) as! VCTrackingDrawPath
        GNavigation.shared.push(vcTrackingDrawPath)
    }
    
    func loadPendingRequests(_ withLoader: Bool = false) {
        // Load Pending Requests on the map.
        let objVMPendingRequests = VMPendingRequests()
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id
        
        objVMPendingRequests.callPendingRequestsApi(requestModel, isLoader: withLoader) {_ in
            let image = UIImage(named: "location_pin")
            
            for data in objVMPendingRequests.arrRequests {
                let latitude = (data.lat! as NSString).doubleValue
                let longitude = (data.lng! as NSString).doubleValue
                
                let marker = GMSMarker()
                marker.icon = image
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                marker.userData = data
                marker.title = data.location
                marker.snippet = data.description!
                marker.map = self.mapView
            }
            
            let isExist = objVMPendingRequests.arrRequests.contains(where: { (objModel) -> Bool in
                if objModel.status == 1 || objModel.status == 6 {
                    self.objVMHome.activeStreamRequest = objModel
                    return true
                }
                return false
            })
            
            if isExist {
                self.constHeightRequestProgress.constant = 40
                self.vwRequestProgress.isHidden = false
            }
        }
        
    }
    
    func loadPendingRequestStream() {
        let userDefaults = UserDefaults.standard
        if let requestModelData = userDefaults.data(forKey: GConstant.UserDefaults.kRequestStreamData) {
            let requestModel = try! JSONDecoder().decode(StreamRequestCodableModel.self, from: requestModelData)
            
            let latitude = (requestModel.lat! as NSString).doubleValue
            let longitude = (requestModel.lng! as NSString).doubleValue
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let currentMarker = self.loadLocationToCenter(coordinates: coordinates)
            self.requestStreamView.isHidden = false
            self.requestStreamView.contentView.isHidden = false
            self.requestStreamView.lblName.text = requestModel.placeName
            self.requestStreamView.lblAddress.text = requestModel.placeAddress
            self.requestStreamView.location = requestModel.location
            self.requestStreamView.latitude = requestModel.lat
            self.requestStreamView.longitude = requestModel.lng
            self.requestStreamView.tfMessage.text = requestModel.desc
            self.requestStreamView.selectedIndex = requestModel.selectedIndex
            self.requestStreamView.marker = currentMarker
            self.requestStreamView.show()
            
            currentMarker.map = self.mapView
            
        }else{
            self.featuredLocationsView.show()
            self.requestStreamView.hide()
        }
    }
    
    func loadFeaturedLocations() {
        // Load Fetured Locations on the map.
        let requestModel = StreamRequestModel()
        requestModel.streamer_id = GConstant.UserData.id
        objVMHome.callGetFeturedLocationApi(requestModel) { (success) -> Void in
            if success {
                self.featuredLocationsView.arrFeaturedLocations = self.objVMHome.arrFeaturedLocations
                self.featuredLocationsView.vwTable.reloadData()
                
                self.mapView.setCameraToCurrentLocation()
                self.mapView.delegate = self
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                    self.loadPendingRequestStream()
                }
                
                let image = UIImage(named: "location_star")
                
                for data in self.objVMHome.arrFeaturedLocations {
                    let latitude = (data.lat! as NSString).doubleValue
                    let longitude = (data.lng! as NSString).doubleValue
                    
                    let marker = GMSMarker()
                    marker.icon = image
                    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    marker.userData = data
                    marker.title = data.name
                    marker.snippet = data.address!
                    marker.map = self.mapView
                }
            }else{
                // setup Swipe view
                self.featuredLocationsView.hide()
            }
        }
        
        let requestEventsModel = StreamRequestModel()
        requestEventsModel.streamer_id = GConstant.UserData.id
        objVMHome.callGetFeturedEventsApi(requestEventsModel, isLoader: false) { (success) -> Void in
            if success {
                self.featuredLocationsView.arrFeaturedEvents = self.objVMHome.arrFeaturedEvents
                self.featuredLocationsView.vwTable.reloadData()
                
                let image = UIImage(named: "location_star")
                
                for data in self.objVMHome.arrFeaturedEvents {
                    let latitude = (data.lat! as NSString).doubleValue
                    let longitude = (data.lng! as NSString).doubleValue
                    
                    let marker = GMSMarker()
                    marker.icon = image
                    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    marker.userData = data
                    marker.title = data.name
                    marker.snippet = data.address!
                    marker.map = self.mapView
                }
            }
        }
    }
    
}

// MARK:- Textfields Delegates

extension VCHome: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfSearch {
            PlacePickerManager.shared.placePicker { (place) in
                self.objVMHome.isComingAfterPresentView = true
                let currentMarker = self.loadLocationToCenter(coordinates: place.coordinate)

                PlacePickerManager.shared.findPlace(place.coordinate) { (result) in
                    self.requestStreamView.isHidden = false
                    self.requestStreamView.loadRequestStreamView()
                    
                    self.tfSearch.text = PlacePickerManager.shared.getLocation(result, type: .full)
                    let placeName = PlacePickerManager.shared.getLocation(result, type: .full).components(separatedBy: ",")
                    self.requestStreamView.lblName.text = placeName.count > 0 ? placeName[0] : "Unnamed"
                    self.requestStreamView.lblAddress.text = PlacePickerManager.shared.getLocation(result, type: .full)
                    self.requestStreamView.location = PlacePickerManager.shared.getLocation(result, type: .full)
                    self.requestStreamView.latitude = "\(place.coordinate.latitude)"
                    self.requestStreamView.longitude = "\(place.coordinate.longitude)"
                    self.requestStreamView.marker = currentMarker
                    
                    self.dismiss(animated: true, completion: {
                        self.requestStreamView.show()
                        currentMarker.map = self.mapView
                    })
                }
            }
        }
    }
}

// MARK:- Google Map Delegates

extension VCHome: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let isStreamer = !isUserTypeViewer() ? true : false
        if isStreamer {
            let infoWindow = GFunction.shared.viewFromNibName(name: "MarkerInfoView") as! MarkerInfoView
            if let data = marker.userData as? StreamRequestsResult {
                infoWindow.lblLocation.text = data.location
                infoWindow.lblDescription.text = data.description
                infoWindow.lblTimePrice.text = "Estimated Time".localized() + ": \(data.duration!) " + "min".localized() + "  |  "   + "Estimated Price".localized() +  ": $\(data.price!)"
                
                let serverTimeStamp = Int64(data.created!)
                let date = Date(millis: serverTimeStamp!)
                let differnce = Date().offset(from: date)
                infoWindow.lblTime.text = differnce
            }
            
            return infoWindow
        }else{
            
            if let data = marker.userData as? StreamRequestsResult {
                let infoWindow = GFunction.shared.viewFromNibName(name: "MarkerInfoView") as! MarkerInfoView

                infoWindow.lblLocation.text = data.location
                infoWindow.lblDescription.text = data.description
                infoWindow.lblTimePrice.text = "Estimated Time".localized() + ": \(data.duration!) " + "min".localized() + "  |  "   + "Estimated Price".localized() +  ": $\(data.price!)"
                
                let serverTimeStamp = Int64(data.created!)
                let date = Date(millis: serverTimeStamp!)
                let differnce = Date().offset(from: date)
                infoWindow.lblTime.text = differnce
                
                return infoWindow
            }else{
                
                let infoWindow = GFunction.shared.viewFromNibName(name: "MarkerFeaturedInfoWindow") as! MarkerFeaturedInfoWindow
                
                if let data = marker.userData as? FeaturedLocationResult {
                    infoWindow.lblName.text = data.name
                    infoWindow.lblAddress.text = data.address
                    
                    if let imageUrl = data.image {
                        infoWindow.imgView.setImageWithDownload(imageUrl.url())
                    }
                }
                
                return infoWindow
            }
            
        }
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
       
        if isUserTypeViewer() {
            if let data = marker.userData as? StreamRequestsResult {
                print(data)
            }else{
                if let data = marker.userData as? FeaturedLocationResult {
                    self.showRequestStreamView(data)
                }
            }
        }else{
            if let userData = marker.userData as? StreamRequestsResult {
                CallJoinData.shared.handleData(userData)
                if userData.status == 1 || userData.status == 6 {
                    let vcTrackingDrawPath = self.instantiateVC(with: GVCIdentifier.streamerTrackingDrawhPath) as! VCStreamerTrackingDrawPath
                    GNavigation.shared.push(vcTrackingDrawPath)
                }else{
                    let vcAcceptedRequest = self.instantiateVC(with: "VCPopupStreamerAcceptRequest") as! VCPopupStreamerAcceptRequest
                    vcAcceptedRequest.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    vcAcceptedRequest.objVMStreamerRequestAccept.reloadMapCompletion = {
                        self.setupForStreamer()
                    }
                    GNavigation.shared.present(vcAcceptedRequest, isAnimated: false)
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let isStreamer = !isUserTypeViewer() ? true : false
        if isStreamer {
            self.nearbyRequestsView.hide()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let isStreamer = !isUserTypeViewer() ? true : false
        if isStreamer {
            self.nearbyRequestsView.hide()
        }else{
            self.tfSearch.text = ""
            let currentMarker = self.loadLocationToCenter(coordinates: coordinate)
            PlacePickerManager.shared.findPlace(coordinate) { (result) in
                self.requestStreamView.isHidden = false
                
                self.requestStreamView.loadRequestStreamView()
                let placeName = PlacePickerManager.shared.getLocation(result, type: .full).components(separatedBy: ",")
                self.requestStreamView.lblName.text = placeName.count > 0 ? placeName[0] : "Unnamed"
                self.requestStreamView.lblAddress.text = PlacePickerManager.shared.getLocation(result, type: .full)
                self.requestStreamView.location = PlacePickerManager.shared.getLocation(result, type: .full)
                self.requestStreamView.latitude = "\(coordinate.latitude)"
                self.requestStreamView.longitude = "\(coordinate.longitude)"
                self.requestStreamView.marker = currentMarker
                
                self.requestStreamView.show()
            }
        }
    }
    
    func loadLocationToCenter(coordinates: CLLocationCoordinate2D) -> GMSMarker{
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 16)
        mapView.camera = camera
        
        if requestMarker != nil {
            requestMarker!.map = nil
        }
        
        let image = UIImage(named: "location_pin")
        requestMarker = GMSMarker()
        requestMarker!.icon = image
        requestMarker!.position = coordinates
        requestMarker!.map = self.mapView
        
        return requestMarker!
    }
    
}

// MARK:- Bottom Swipe View Delegates

extension VCHome: SwipeViewDelegate {
    
    func clearSearchbarText() {
        self.tfSearch.text = ""
    }
    
    func reloadMap() {
        if isUserTypeViewer() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.loadPendingRequests(true)
            }
        }else{
            self.setupForStreamer(withLoader: false)
        }
    }
    
    func showRequestStreamView(_ data: FeaturedLocationResult) {
        self.requestStreamView.loadRequestStreamView()
        self.requestStreamView.isHidden = false
        self.requestStreamView.lblName.text = data.name!
        self.requestStreamView.lblAddress.text = data.address!
        self.requestStreamView.location = data.address!
        self.requestStreamView.latitude = data.lat!
        self.requestStreamView.longitude = data.lng!
        
        self.requestStreamView.show()
    }
    
    func didPressedOnStrip(_ isSelected: Bool, visible viewHeight: CGFloat, completion: @escaping () -> Void) {
        let animateDuration = 0.4
        
        if GConstant.UserData.userType == LoginUserType.viewer.rawValue {
            if isSelected {
                self.featuredLocationsView.isHidden = true
            }else{
                self.featuredLocationsView.isHidden = false
            }
        }
        
        UIView.animate(withDuration: animateDuration, animations: {
            self.constantYSwipeView.constant = viewHeight
            self.view.layoutIfNeeded()
        }) { (_) in
            completion()
        }
    }
    
    func didPressedOnFeaturedStrip(_ isSelected: Bool, visible viewHeight: CGFloat, completion: @escaping () -> Void) {
        let animateDuration = 0.4
        
        if isSelected {
            self.mapView.isUserInteractionEnabled = false
        }else{
            self.mapView.isUserInteractionEnabled = true
        }
        
        UIView.animate(withDuration: animateDuration, animations: {
            self.constFeaturedYSwipeView.constant = viewHeight
            self.view.layoutIfNeeded()
        }) { (_) in
            completion()
        }
    }
    
}



