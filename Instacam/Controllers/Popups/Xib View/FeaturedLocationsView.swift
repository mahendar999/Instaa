//
//  FeaturedLocationsView.swift
//  Instacam
//
//  Created by Apple on 25/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class FeaturedLocationsView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var componentsView: UIView!
    @IBOutlet weak var lblHeading: UIView!
    @IBOutlet weak var vwTable: UITableView!
    @IBOutlet weak var btnStripOutlet: UIButton!
    @IBOutlet weak var btnSegmentOutlet: UISegmentedControl!
    
    var arrFeaturedLocations: [FeaturedLocationResult] = []
    var arrFeaturedEvents: [FeaturedLocationResult] = []
    var arrData: [FeaturedLocationResult] = []
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
    
     func commonInit() {
        Bundle.main.loadNibNamed("FeaturedLocationsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        vwTable.delegate = self
        vwTable.dataSource = self
        vwTable.register(UINib(nibName: "CellFeaturedLocations", bundle: nil), forCellReuseIdentifier: "CellFeaturedLocations")
       
        self.vwHeight = self.frame.size.height
        self.isHidden = true
        
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
        delegate.didPressedOnFeaturedStrip(false, visible: -self.frame.size.height+50, completion: {
            self.isHidden = false
            self.btnStripOutlet.isUserInteractionEnabled = true
            self.componentsView.isHidden = true
        })
    }
    
    func show() {
        self.arrData = btnSegmentOutlet.selectedSegmentIndex == 0 ? self.arrFeaturedLocations : self.arrFeaturedEvents
        
        if arrData.count == 0 {
            EmptyDataManager.shared.addView(on: self.vwTable, title: "", message: "No featured location available!")
            self.vwTable.reloadData()
        }
        
        self.vwTable.reloadData()
        
        btnStripOutlet.tag = 1
        self.componentsView.isHidden = false
        delegate.didPressedOnFeaturedStrip(true, visible: 0, completion: {
            self.btnStripOutlet.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func btnPressedOnStrip(_ sender: UIButton) {
        btnStripOutlet.isUserInteractionEnabled = false
        if sender.tag == 1 {
           self.hide()
        }else{
            self.show()
        }
    }
    
    @IBAction func btnSegment(_ sender: UISegmentedControl) {
        if btnSegmentOutlet.selectedSegmentIndex == 0 {
            self.arrData = self.arrFeaturedLocations
            
            if arrData.count == 0 {
                EmptyDataManager.shared.addView(on: self.vwTable, title: "", message: "No featured location available!")
                self.vwTable.reloadData()
            }
            
        }else{
            self.arrData = self.arrFeaturedEvents
            
            if arrData.count == 0 {
                EmptyDataManager.shared.addView(on: self.vwTable, title: "", message: "No featured events available!")
                self.vwTable.reloadData()
            }
            
        }
        
        self.vwTable.reloadData()
    }

}

extension FeaturedLocationsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFeaturedLocations", for: indexPath) as! CellFeaturedLocations
        cell.selectionStyle = .none
        
        let objAtIndex = self.arrData[indexPath.row]
        cell.lblName.text = objAtIndex.name
        cell.lblAddress.text = objAtIndex.address
        
        if let imageUrl = objAtIndex.image {
            cell.imgView.setImageWithDownload(imageUrl.url())
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hide()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            let objAtIndex = self.arrData[indexPath.row]
            self.delegate.showRequestStreamView(objAtIndex)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
