//
//  VCPendingRequest.swift
//  Instacam
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class VCPendingRequest: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tblView: UITableView!
    
    var objVMPendingRequests = VMPendingRequests()
    var objVMAPIs = VMAPIs()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
        self.mapView.setCameraToCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupPendingRequest(withLoader: true)
        
    }
    
    func setupPendingRequest(withLoader: Bool) {
        let image = UIImage(named: "location_pin")
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id
        objVMPendingRequests.callPendingRequestsApi(requestModel, isLoader: withLoader) {(success) -> Void in
            
            if success {
                self.objVMPendingRequests.arrRequests = self.objVMPendingRequests.arrRequests.filter({ (objModel) -> Bool in
                    if objModel.status == 1 || objModel.status == 6{
                        return false
                    }
                    return true
                })
                
                self.mapView.clear()
                for data in self.objVMPendingRequests.arrRequests {
                    let latitude = (data.lat! as NSString).doubleValue
                    let longitude = (data.lng! as NSString).doubleValue
                    
                    let marker = GMSMarker()
                    marker.icon = image
                    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    marker.userData = data
                    marker.title = data.location!
                    marker.snippet = data.description!
                    marker.map = self.mapView
                }
                
                self.tblView.reloadData()
            }else{
                self.objVMPendingRequests.arrRequests = []
                EmptyDataManager.shared.addView(on: self.tblView, title: "", message: "No Pending request available!")
                self.tblView.reloadData()
            }
            
        }
    }
    
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Pending Requests".localized())
        self.navigationController?.customize()
    }
    

    

}
