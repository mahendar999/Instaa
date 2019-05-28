//
//  PullToRefresh.swift
//  E-Commerce
//
//  Created by GS Bit Labs on 7/2/18.
//  Copyright © 2018 GS Bit Labs. All rights reserved.
//

import Foundation
import UIKit
import INSPullToRefresh

class PTRDataManager {
    static let shared = PTRDataManager()
    typealias CompletionHandler = () -> Void
    
    func setupWithDelay(for tableView: UITableView) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.0) {
            self.setup(for: tableView, autoPerform: true)
        }
    }
    
    func setupWithDelay(for collectionView: UICollectionView) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.0) {
            self.setup(for: collectionView, autoPerform: true)
        }
    }
    
    func setup(for tableView: UITableView, autoPerform: Bool? = false) {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate?
        tableView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        if let bool = autoPerform {
            if bool {
                tableView.ins_beginPullToRefresh()
            }
        }
    }
    
    func setup(for collectionView: UICollectionView, autoPerform: Bool? = false) {
        let pullToRefresh: INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate?
        collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        if let bool = autoPerform {
            if bool {
                collectionView.ins_beginPullToRefresh()
            }
        }
    }
    
    func addPullToRefresh(on tableView: UITableView, addPullToRefresh: @escaping CompletionHandler, addInfnityScroll: @escaping CompletionHandler) {
        tableView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            addPullToRefresh()
        }
        
        tableView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            addInfnityScroll()
        }
    }
    
    func addPullToRefresh(on collectionView: UICollectionView, addPullToRefresh: @escaping CompletionHandler, addInfnityScroll: @escaping CompletionHandler) {
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            addPullToRefresh()
        }
        
        collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            addInfnityScroll()
        }
    }
}
