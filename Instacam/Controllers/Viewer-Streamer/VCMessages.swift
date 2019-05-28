//
//  VCMessages.swift
//  Instacam
//
//  Created by Apple on 08/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCMessages: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initMainView()
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navMenuIcon), btnRight: nil, title: "Messages".localized())
        self.navigationController?.customize()
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
