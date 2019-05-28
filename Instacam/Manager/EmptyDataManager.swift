//
//  EmptyDataManager.swift
//  E-Commerce
//
//  Created by GS Bit Labs on 6/18/18.
//  Copyright © 2018 GS Bit Labs. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class EmptyDataManager {
    static let shared = EmptyDataManager()
    
    func addView(on tableView: UITableView, title: String, message: String) {
        tableView.emptyDataSetView { view in
        view.titleLabelString(NSAttributedString(string: title.localized()))
            .detailLabelString(NSAttributedString(string: message.localized()))
            .dataSetBackgroundColor(.white)
            .shouldDisplay(true)
            .verticalSpace(15)
            .shouldFadeIn(true)
            .isTouchAllowed(true)
            .isScrollAllowed(true)
        }
    }
    
    func addView(on collectionView: UICollectionView, title: String, message: String) {
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: title.localized()))
                .detailLabelString(NSAttributedString(string: message.localized()))
                .dataSetBackgroundColor(.white)
                .shouldDisplay(true)
                .verticalSpace(15)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
    }
    
    func addViewWithButton(on collectionView: UICollectionView, title: String, message: String, buttonTitle: String, completion: @escaping () -> Void) {
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: title.localized()))
                .detailLabelString(NSAttributedString(string: message.localized()))
                .buttonTitle(NSAttributedString(string: buttonTitle.localized(), attributes: [NSAttributedString.Key.foregroundColor: GConstant.AppColor.darkSkyBlue, NSAttributedString.Key.font: UIFont.applyArialBold(fontSize: 16)]   ), for: .normal)
                .dataSetBackgroundColor(.white)
                .shouldDisplay(true)
                .verticalSpace(15)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
                .didTapDataButton {
                    completion()
                }
        }
    }
    
    func addViewWithButton(on tableView: UITableView, title: String, message: String, buttonTitle: String, completion: @escaping () -> Void) {
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: title.localized()))
                .detailLabelString(NSAttributedString(string: message.localized()))
                .buttonTitle(NSAttributedString(string: buttonTitle.localized(), attributes: [NSAttributedString.Key.foregroundColor: GConstant.AppColor.darkSkyBlue, NSAttributedString.Key.font: UIFont.applyArialBold(fontSize: 16)]   ), for: .normal)
                .dataSetBackgroundColor(.white)
                .shouldDisplay(true)
                .verticalSpace(15)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
                .didTapDataButton {
                    completion()
            }
        }
    }
    
    
}
