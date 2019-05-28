//
//  VCPopupRateStreaming.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Cosmos

class VCPopupRateStreaming: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var btnDoneOutlet: UIButton!
    @IBOutlet weak var tfComment: UITextView!
    @IBOutlet weak var lblHeading: UILabel!

    var objVMRating = VMRating()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func initMainView() {
        
        lblMessage.text = "Thanks for streaming!\nPlease rate your viewer.".localized()
        lblHeading.text = "Write about streaming experience".localized()
        
        self.btnDoneOutlet.roundedCorener()

        vwRating.rating = 0
        vwRating.settings.fillMode = .full
        vwRating.settings.minTouchRating = 0
        vwRating.didFinishTouchingCosmos = { (rating) -> Void in
            if self.vwRating.rating == 0 {
                self.lblHeading.text = "Write about streaming experience".localized()
            }else{
                switch self.vwRating.rating {
                case 0.5, 1:
                    self.lblHeading.text = "File a complaint".localized()
                    break
                case 1.5, 2:
                    self.lblHeading.text = "File a complaint".localized()
                    break
                case 2.5, 3:
                    self.lblHeading.text = "Give a compliment".localized()
                    break
                case 3.5, 4:
                    self.lblHeading.text = "Give a compliment".localized()
                    break
                case 4.5, 5:
                    self.lblHeading.text = "Give a compliment".localized()
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        if vwRating.rating > 0 {
            let requestModel = RatingRequestModel()
            requestModel.stream_id = CallJoinData.shared.streamId
            requestModel.viewer_rating = "\(vwRating.rating)"
            requestModel.type = "viewer"
            if vwRating.rating > 1 {
                requestModel.viewer_compliment = tfComment.text!
            }else{
                requestModel.viewer_complaint = tfComment.text!
            }
            objVMRating.callStreamerRatingApi(requestModel) {
                GNavigation.shared.popToRoot(VCHome.self)
            }
        }else{
            let alert = GPAlert(title: "Add Rating", message: "Please add rating first")
            AlertManager.shared.show(alert)
        }
        
    }
    
    @IBAction func btnReportUser(_ sender: UIButton) {
        let vcReport = self.instantiateVC(with: GVCIdentifier.reportPicker) as! VCReportPicker
        let navigation = UINavigationController(rootViewController: vcReport)
        GNavigation.shared.present(navigation, isAnimated: true)
    }
    
    
    @IBAction func btnClose(_ sender: UIButton) {
        GNavigation.shared.popToRoot(VCHome.self)
    }

}
