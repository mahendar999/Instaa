//
//  VCWelcome.swift
//  Instacam
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCWelcome: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GNavigation.shared.NavigationController.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GNavigation.shared.NavigationController.isNavigationBarHidden = false
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.login)
    }
    
    @IBAction func btnSignup(_ sender: UIButton) {
        GNavigation.shared.pushWithoutData(GVCIdentifier.signup)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
