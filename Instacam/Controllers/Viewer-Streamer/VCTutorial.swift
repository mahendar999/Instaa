//
//  VCTutorial.swift
//  Instacam
//
//  Created by Apple on 02/05/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCTutorial: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    var pageCount = 0
    
    struct TutrialData {
        let image: UIImage!
        let label: String!
    }
    
    var arrStreamerData = [
        TutrialData(image: UIImage(named: "t1"), label: "Accept Stream Requests".localized()),
        TutrialData(image: UIImage(named: "t5"), label: "Please hold your phone steady while streaming".localized()),
        TutrialData(image: UIImage(named: "t3"), label: "Earn real money!".localized())
    ]
    
    var arrViewerData = [
        TutrialData(image: UIImage(named: "t1"), label: "Request what you want to see".localized()),
        TutrialData(image: UIImage(named: "t4"), label: "Discover featured location and events".localized()),
        TutrialData(image: UIImage(named: "t2"), label: "Become a streamer".localized())
    ]
    
    var arrData: [TutrialData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSwipeGesture(self.view)
        initMainView()
        
    }
    
    func initMainView() {
        
        if self.isUserTypeViewer() {
            arrData = arrViewerData
        }else{
            arrData = arrStreamerData
        }
        
        imgView.image = arrData[pageCount].image
        lblDescription.text = arrData[pageCount].label
    }
    
    func addSwipeGesture(_ vw: UIView) {
        let _action = #selector(respondToSwipeGesture(_:))
        
        vw.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: _action)
        swipeRight.direction = .right
        vw.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: _action)
        swipeLeft.direction = .left
        vw.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case .right:
                if pageCount == 0{
                    return
                }
                pageCount -= 1
                break
            case .left:
                if pageCount == 2 {
                    return
                }
                pageCount += 1
                
                if pageCount == 2 {
                    skipButton.setTitle("Got it!".localized(), for: .normal)
                }
                
                break
            default:
                break
            }
            
            imgView.image = arrData[pageCount].image
            lblDescription.text = arrData[pageCount].label
            pageControl.currentPage = pageCount
        }
    }
    
    @IBAction func btnSkip() {
        let userDefaults = UserDefaults.standard
        if self.isUserTypeViewer() {
            userDefaults.set(true, forKey: GConstant.UserDefaults.kViewerTutorial)
        }else{
            userDefaults.set(true, forKey: GConstant.UserDefaults.kStreamerTutorial)
        }
        UserDefaults.standard.synchronize()
        dismiss(animated: false, completion: nil)
    }

}
