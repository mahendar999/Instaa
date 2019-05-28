//
//  VCVideoTutorials.swift
//  Instacam
//
//  Created by Apple on 03/05/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCVideoTutorials: UIViewController {

    @IBOutlet var imgViewCenter: UIImageView!
    @IBOutlet var imgViewCamera: UIImageView!
    @IBOutlet var imgViewPause: UIImageView!
    @IBOutlet var imgViewWalkie: UIImageView!
    @IBOutlet var imgViewMessage: UIImageView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var videoPauseButton: UIButton!
    @IBOutlet weak var walkieTalkieButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var pageCount = 0
    
    struct TutrialData {
        let image: UIImage!
        let label: String!
    }
    
    var arrStreamerData = [
        TutrialData(image: UIImage(named: "vt1"), label: "Follow the arrows for directions".localized()),
        TutrialData(image: UIImage(named: "vt2"), label: "Tap box to message viewer".localized()),
        TutrialData(image: UIImage(named: "vt3"), label: "Tap to flip camera".localized())
    ]
    
    var arrViewerData = [
        TutrialData(image: UIImage(named: "vt4"), label: "Draw arrows to navigate".localized()),
        TutrialData(image: UIImage(named: "vt2"), label: "Tap box to message streamer".localized()),
        TutrialData(image: UIImage(named: "vt3"), label: "Tap microphone to speak".localized()),
        TutrialData(image: UIImage(named: "vt3"), label: "Tap stop to pause".localized())
    ]
    
    var arrData: [TutrialData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSwipeGesture(self.view)
        initMainView()
        updateComponents()
    }
    
    func initMainView() {
        
        if self.isUserTypeViewer() {
            arrData = arrViewerData
        }else{
            arrData = arrStreamerData
        }
        
        pageControl.numberOfPages = arrData.count
        loadSlideData()
    }
    
    func loadSlideData() {
        imgViewCenter.isHidden = true
        imgViewCamera.isHidden = true
        imgViewPause.isHidden = true
        imgViewWalkie.isHidden = true
        imgViewMessage.isHidden = true
        
        if self.isUserTypeViewer() {
            switch pageCount {
            case 0:
                imgViewCenter.isHidden = false
                imgViewCenter.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            case 1:
                imgViewMessage.isHidden = false
                imgViewMessage.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            case 2:
                imgViewWalkie.isHidden = false
                imgViewWalkie.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            case 3:
                imgViewPause.isHidden = false
                imgViewPause.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            default:
                break
            }
        }else{
            switch pageCount {
            case 0:
                imgViewCenter.isHidden = false
                imgViewCenter.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            case 1:
                imgViewMessage.isHidden = false
                imgViewMessage.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            case 2:
                imgViewCamera.isHidden = false
                imgViewCamera.image = arrData[pageCount].image
                lblDescription.text = arrData[pageCount].label
                break
            default:
                break
            }
        }
    }
    
    func updateComponents() {
        if isUserTypeViewer() {
            videoPauseButton.isHidden = false
            walkieTalkieButton.isHidden = false
            cameraButton.isHidden = true
        }else{
            videoPauseButton.isHidden = true
            walkieTalkieButton.isHidden = true
            cameraButton.isHidden = false
        }
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
                if isUserTypeViewer() {
                    if pageCount == 3 {
                        return
                    }
                }else{
                    if pageCount == 2 {
                        return
                    }
                }
                
                pageCount += 1
                if isUserTypeViewer() {
                    if pageCount == 3 {
                        skipButton.setTitle("Got it!".localized(), for: .normal)
                    }
                }else{
                    if pageCount == 2 {
                        skipButton.setTitle("Got it!".localized(), for: .normal)
                    }
                }
                
                break
            default:
                break
            }
            
            loadSlideData()
            pageControl.currentPage = pageCount
        }
    }
    
    @IBAction func btnDone() {
        let userDefaults = UserDefaults.standard
        if self.isUserTypeViewer() {
            userDefaults.set(true, forKey: GConstant.UserDefaults.kViewerVideoTutorial)
        }else{
            userDefaults.set(true, forKey: GConstant.UserDefaults.kStreamerVideoTutorial)
        }
        UserDefaults.standard.synchronize()
        dismiss(animated: false, completion: nil)
    }

}
