//
//  VCLanguagePicker.swift
//  Instacam
//
//  Created by Apple on 02/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VCLanguagePicker: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var arr = ["English", "Spanish", "Hindi", "Japenese"]
    typealias CompletionHandler = (String)->Void
    var completion: CompletionHandler?
    
    var arrSelectedValues: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
        
        self.tblView.allowsMultipleSelection = true
        self.tblView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: BarButton(title: "Done".localized()), title: "Select Languages".localized())
        self.navigationController?.customize()
    }
    
    func initMainView() {
    }
    
    // MARK:- Navigation Button Actions
    
    @objc func leftButtonClicked() {
        GNavigation.shared.dismiss(true)
    }
    
    @objc func rightButtonClicked() {
        if arrSelectedValues.count > 0 {
            if arrSelectedValues.count > 3 {
                AlertManager.shared.addToast(self.view, message: "You only can select max 3 languages")
            }else{
                if completion != nil {
                    let strSelectedValues = arrSelectedValues.joined(separator: ", ")
                    completion!(strSelectedValues)
                }
                GNavigation.shared.dismiss(true)
            }
        }else{
            AlertManager.shared.addToast(self.view, message: "Please select any language first")
        }
        
    }

}

extension VCLanguagePicker: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellLanguagePicker", for: indexPath) as! CellLanguagePicker
        cell.lblName.text = arr[indexPath.row]
        
//        if arrSelectedValues.contains(arr[indexPath.row]) {
//            cell.isSelected = true
//        }else{
//            cell.isSelected = false
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = arr[indexPath.row]
        arrSelectedValues.append(value)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let value = arr[indexPath.row]
        if arrSelectedValues.contains(value) {
            if let index = arrSelectedValues.index(of: value) {
                arrSelectedValues.remove(at: index)
            }
        }
    }
    
}
