//
//  DrawPathManager.swift
//  Instacam
//
//  Created by Apple on 27/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

struct MapInfo{
    let distance: String!
    let time: String!
}

extension GMSMapView {
    func setCameraToCurrentLocation() {
        if let location = LocationManager.shared.currentLocation {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
            self.camera = camera
            self.isMyLocationEnabled = true
            self.settings.myLocationButton = true
            self.settings.compassButton = true
        }else{
            let camera = GMSCameraPosition.camera(withLatitude: 42.360308, longitude: -71.094661, zoom: 16)
            self.camera = camera
            self.isMyLocationEnabled = true
            self.settings.myLocationButton = true
            self.settings.compassButton = true
        }
    }
}

class DrawPathManager: NSObject, GMSMapViewDelegate {
    static let shared = DrawPathManager()
    
    func drawPath(_ mapView: GMSMapView, viewerCoord: CLLocationCoordinate2D, streamerCoord: CLLocationCoordinate2D, isUpdating: Bool, completion: @escaping (MapInfo)->Void = {_ in }) {
        
        let originCoordinates = GConstant.UserData.userType == "S" ? streamerCoord : viewerCoord
        let destinationCoordinates = GConstant.UserData.userType == "S" ? viewerCoord : streamerCoord
        
        let originMarkerImage = GConstant.UserData.userType == "S" ? UIImage(named: "location_pin") : UIImage(named: "mobile")
        let destinationMarkerImage = GConstant.UserData.userType == "S" ? UIImage(named: "mobile") : UIImage(named: "location_pin")
        
        mapView.clear()
        
        let camera = GMSCameraPosition.camera(withLatitude: originCoordinates.latitude,
                                                  longitude: originCoordinates.longitude,
                                                  zoom: 10.0,
                                                  bearing: 30,
                                                  viewingAngle: 40)
        mapView.camera = camera
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.animate(to: camera)
        
        //Setting the start and end location
        let origin = "\(originCoordinates.latitude),\(originCoordinates.longitude)"
        let destination = "\(destinationCoordinates.latitude),\(destinationCoordinates.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=caution&key=\(KeyManager.google)"
        
        //Rrequesting Alamofire and SwiftyJSON
        Alamofire.request(url).responseJSON { response in
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let legs = route["legs"].arrayValue
                for value in legs {
                    let dicDistance = value["distance"].dictionary
                    let dicDuration = value["duration"].dictionary
                    
                    completion(MapInfo(distance: dicDistance?["text"]?.stringValue, time: dicDuration?["text"]?.stringValue))
                }
                
                
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor.blue
                polyline.strokeWidth = 5
                
//                let strokeStyles = [GMSStrokeStyle.solidColor(.blue)]
//                let strokeLengths = [NSNumber(value: 10), NSNumber(value: 10)]
//                polyline.spans = GMSStyleSpans(path!, strokeStyles, strokeLengths, .rhumb)
                
                let bounds = GMSCoordinateBounds(path: path!)
                let edges = UIEdgeInsets(top: 150, left: 20, bottom: 150, right: 20)
                mapView.animate(with: GMSCameraUpdate.fit(bounds, with: edges))
                
                polyline.map = mapView
                
            }
        }
        
        // Creates a marker in the center of the map.
        let originMarker = GMSMarker()
        originMarker.map = nil
        originMarker.icon = originMarkerImage
        originMarker.position = originCoordinates
        originMarker.map = mapView
        
        let destinationMarker = GMSMarker()
        destinationMarker.map = nil
        destinationMarker.icon = destinationMarkerImage
        destinationMarker.position = destinationCoordinates
        destinationMarker.map = mapView
    }
    
}
