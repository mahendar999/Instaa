//
//  GNavigation.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController

class GNavigation: NSObject {
    static let shared = GNavigation()
    
    static var navMenuIcon: UIImage? {
        return UIImage(named: "menu")
    }
    
    static var navBackIcon: UIImage? {
        return UIImage(named: "Back")
    }
    
    var MainStoryBoard = UIStoryboard(name: "Main", bundle: .main)
    var NavigationController: UINavigationController!
    var revealController = SWRevealViewController()
    
    func pushWithRC(_ identifier: String, isAnimated: Bool = true) {
        let vc = self.instantiateVC(with: identifier)
        revealController.pushFrontViewController(vc, animated: isAnimated)
    }
    
    func pushWithoutData(_ identifier: String, isAnimated: Bool = true) {
        let vc = self.instantiateVC(with: identifier)
        self.NavigationController.pushViewController(vc, animated: isAnimated)
    }
    
    func push(_ vc: UIViewController, isAnimated: Bool = true) {
        self.NavigationController.pushViewController(vc, animated: isAnimated)
    }
    
    func pop(_ isAnimated: Bool = true) {
        self.NavigationController.popViewController(animated: isAnimated)
    }
    
    func present(_ vc: UIViewController, isAnimated: Bool = false) {
        self.NavigationController.present(vc, animated: isAnimated)
    }
    
    func dismiss(_ isAnimated: Bool = false, completion: @escaping () -> Void = { }) {
        self.NavigationController.dismiss(animated: isAnimated, completion: {
            completion()
        })
    }
    
    
    func popToRoot(_ vcName: AnyClass, isAnimated: Bool = true) {
        let controllers = self.NavigationController.viewControllers
        for vc in controllers {
            if vc.isKind(of: vcName) {
                self.NavigationController.popToViewController(vc, animated: isAnimated)
            }
        }
    }
    
}
