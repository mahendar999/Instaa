//
//  NearbyRequestsView.swift
//  Instacam
//
//  Created by Apple on 26/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

//
//  FeaturedLocationsView.swift
//  Instacam
//
//  Created by Apple on 25/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol SwipeViewDelegate {
    func didPressedOnStrip(_ isSelected: Bool, visible viewHeight: CGFloat, completion: @escaping () -> Void)
    func didPressedOnFeaturedStrip(_ isSelected: Bool, visible viewHeight: CGFloat, completion: @escaping () -> Void)
    func clearSearchbarText()
    func reloadMap()
    func showRequestStreamView(_ data: FeaturedLocationResult)
}

class NearbyRequestsView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var componentsView: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var vwTable: UITableView!
    @IBOutlet weak var btnStripOutlet: UIButton!
    
    var arrRequests: [StreamRequestsResult] = []
    var sectionName: String = ""
    
    var delegate: SwipeViewDelegate!
    var vwHeight = CGFloat()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NearbyRequestsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        vwTable.delegate = self
        vwTable.dataSource = self
        
        vwTable.register(UINib(nibName: "CellNearbyRequestsView", bundle: nil), forCellReuseIdentifier: "CellNearbyRequestsView")
        
        self.isHidden = true
        self.vwHeight = self.frame.size.height
        
        let _action = #selector(respondToSwipeGesture(_:))
        let swipeTop = UISwipeGestureRecognizer(target: self, action: _action)
        swipeTop.direction = .up
        self.btnStripOutlet.addGestureRecognizer(swipeTop)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: _action)
        swipeDown.direction = .down
        self.btnStripOutlet.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                self.hide()
            case .up:
                self.show()
            default:
                break
            }
        }
    }
    
    func hide() {
        btnStripOutlet.tag = 0
        delegate.didPressedOnStrip(false, visible: -self.frame.size.height+50, completion: {
            self.isHidden = false
            self.btnStripOutlet.isUserInteractionEnabled = true
            self.componentsView.isHidden = true
        })
    }
    
    func show() {
        btnStripOutlet.tag = 1
        self.componentsView.isHidden = false
        delegate.didPressedOnStrip(true, visible: 0, completion: {
            self.btnStripOutlet.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func btnPressedOnStrip() {
        btnStripOutlet.isUserInteractionEnabled = false
        if btnStripOutlet.tag == 1 {
            self.hide()
        }else{
            self.show()
        }
    }
    
}

extension NearbyRequestsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName == "" ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrRequests.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionName == "" {
            return UIView()
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.vwTable.frame.size.width, height: 40))
        headerView.backgroundColor = .white
        let innerView = UIView(frame: CGRect(x: 0, y: 0, width: self.vwTable.frame.size.width, height: 30))
        innerView.backgroundColor = GConstant.AppColor.lightSkyBlue
        headerView.addSubview(innerView)
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.size.width-30, height: 30))
        label.textColor = .white
        label.font = UIFont(name: "Arial", size: 13.0)
        label.text = sectionName
        innerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellNearbyRequestsView", for: indexPath) as! CellNearbyRequestsView
        cell.selectionStyle = .none
        
        let objAtIndex = self.arrRequests[indexPath.row]
        
        let serverTimeStamp = Int64(objAtIndex.created!)
        let date = Date(millis: serverTimeStamp!)
        let diifernce = Date().offset(from: date)
        cell.lblName.text = objAtIndex.location
        cell.lblDistance.text = diifernce
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hide()
        let objAtIndex = self.arrRequests[indexPath.row]
        CallJoinData.shared.handleData(objAtIndex)
        
        if objAtIndex.status == 1 || objAtIndex.status == 6{
            let vcTrackingDrawPath = self.instantiateVC(with: GVCIdentifier.streamerTrackingDrawhPath) as! VCStreamerTrackingDrawPath
            GNavigation.shared.push(vcTrackingDrawPath)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                let vcAcceptedRequest = self.instantiateVC(with: "VCPopupStreamerAcceptRequest") as! VCPopupStreamerAcceptRequest
                vcAcceptedRequest.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vcAcceptedRequest.objVMStreamerRequestAccept.reloadMapCompletion = {
                    self.delegate.reloadMap()
                }
                GNavigation.shared.present(vcAcceptedRequest, isAnimated: false)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
