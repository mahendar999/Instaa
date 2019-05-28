//
//  VCReportPicker.swift
//  Instacam
//
//  Created by Apple on 09/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCReportPicker: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var arr = ["Sexual Contents", "Physical/Verbal Violence", "Drugs", "Invading Privacy", "Others"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Report User".localized())
        self.navigationController?.customize()
    }
    
    @objc func leftButtonClicked() {
        dismiss(animated: true, completion: nil)
    }

}

extension VCReportPicker: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReportPicker", for: indexPath) as! CellReportPicker
        cell.lblName.text = arr[indexPath.row].localized()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcReport = self.instantiateVC(with: GVCIdentifier.reportUser) as! VCReportUser
        vcReport.navTitle = arr[indexPath.row]
        navigationController?.pushViewController(vcReport, animated: true)
    }
    
}

