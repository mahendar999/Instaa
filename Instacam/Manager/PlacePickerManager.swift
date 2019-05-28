//
//  PlacePickerManager.swift
//  Instacam
//
//  Created by Apple on 01/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps

class PlacePickerManager: NSObject {
    static let shared = PlacePickerManager()
    
    typealias CompletionHandler = (GMSPlace)->Void
    var completion: CompletionHandler? = nil
    private let placesClient = GMSPlacesClient()
    lazy var geocoder = CLGeocoder()
    
    func placePicker(_ completion: CompletionHandler?) {
        self.completion = completion
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.appDelegate.window?.rootViewController?.present(autocompleteController, animated: true, completion: nil)
    }
    
    func findPlace(_ withCoordinate: CLLocationCoordinate2D, completion: @escaping (GMSAddress)->Void) {
        
//        // Create Location
//        let location = CLLocation(latitude: withCoordinate.latitude, longitude: withCoordinate.longitude)
//
//        // Geocode Location
//        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//            // Process Response
//            self.processResponse(withPlacemarks: placemarks, error: error)
//        }
        
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(withCoordinate) { (response, error) in
            if error == nil {
                if let result = response?.firstResult() {
                    completion(result)
                }
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                print(placemark.postalAddress)
            } else {
                print("No Matching Addresses Found")
            }
        }
    }
    
    enum AddressType {
        case custom
        case full
    }
    
    func getLocation(_ address: GMSAddress, type: AddressType) -> String {
        
        /*
         
        ********* GMSAddress *********
         
        coordinate
        Location, or kLocationCoordinate2DInvalid if unknown.
        
        thoroughfare
        Street number and name.
        
        locality
        Locality or city.
        
        subLocality
        Subdivision of locality, district or park.
        
        administrativeArea
        Region/State/Administrative area.
        
        postalCode
        Postal/Zip code.
        
        country
        The country name.
        */
        
        var strAddress : String = ""
        
        if type == .full {
            if address.thoroughfare != nil {
                strAddress = strAddress + address.thoroughfare! + ", "
            }
            if address.locality != nil {
                strAddress = strAddress + address.locality! + " - "
            }
//            if address.subLocality != nil {
//                strAddress = strAddress + address.subLocality! + " - "
//            }
//            if address.administrativeArea != nil {
//                strAddress = strAddress + address.administrativeArea! + " - "
//            }
//            if address.postalCode != nil {
//                strAddress = strAddress + address.postalCode! + ", "
//            }
            if address.country != nil {
                strAddress = strAddress + address.country!
            }
        }else{
            if address.locality != nil {
                strAddress = strAddress + address.locality! + ", "
            }
            if address.country != nil {
                strAddress = strAddress + address.country!
            }
        }
        
        return strAddress
    }
    
}

extension PlacePickerManager: GMSAutocompleteViewControllerDelegate, UISearchDisplayDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if self.completion != nil {
            self.completion!(place)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

