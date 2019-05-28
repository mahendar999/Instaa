//
//  VMViewerPayments.swift
//  Instacam
//
//  Created by Apple on 26/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import Stripe

class VMViewerPayments: NSObject {
    var arrNumberOfCard: [Card] = []
    var tableView = UITableView()
    var defaultCard = Int()
    
    func callCompleteProfileApi(_ requestModel: UserProfileRequestModel, isLoader: Bool = true, completion: @escaping ()->Void) {
        
        /*
         Api name: updateProfile
         Parameters: "Required: user_id
         Optional: device_type, device_token
         full_name, address, email, lat, lng, city, state, country, postal_code, is_profile_created, password, device, languages(comma separated)", default_card
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.updateProfile(), parameter: requestModel.toDictionary(), withLoader: isLoader) { (responseData, statusCode) in
            
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        
                        if let loginResult = responseModel.result {
                            GFunction.shared.storeLoginData(loginResult)
                            completion()
                        }
                        
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                    
                }
                
            }
        }
    }
    
    func callCreateCustomerIdApi(_ requestModel: UserProfileRequestModel, completion: @escaping ()->Void = {}) {
        
        /*
         Api name: createStripeCustomer
         Parameters: user_id, token
         Method: POST
         */
        
        APICall.shared.POST(strURL: GAPIConstant.createStripeCustomer(), parameter: requestModel.toDictionary(), withLoader: false) { (responseData, statusCode) in
            if let data = responseData {
                let responseModel = try! UserResponseModel.init(data: data)
                if let statusCode = responseModel.success {
                    if statusCode == 200 {
                        if let userResult = responseModel.result {
                            GFunction.shared.storeLoginData(userResult)
                            completion()
                        }
                    }else{
                        AlertManager.shared.show(GPAlert(title: "", message: responseModel.message ?? ""))
                    }
                }
            }
        }
    }
    
    func presentStripeAddCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        STPTheme.default().accentColor = GConstant.AppColor.darkSkyBlue
        
        
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        navigationController.customize()
        GNavigation.shared.present(navigationController, isAnimated: true)
    }
    
}

// MARK: TableView Delegates

extension VCPayments: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSection") as! CellCardList
        let action = #selector(tapOnAddCard(_:))
        cell.btnAddCard.addTarget(self, action: action, for: .touchUpInside)
        cell.btnAddCard.tag = section
        return cell
    }
    
    @objc func tapOnAddCard(_ sender: UIButton) {
        objVMViewerPayments.presentStripeAddCard()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objVMViewerPayments.arrNumberOfCard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCardList") as! CellCardList
        
        let objAtIndex = objVMViewerPayments.arrNumberOfCard[indexPath.row]
        cell.lblCardNumber.text = "**** \(objAtIndex.cardLastFourDigit)"
        cell.imgView.image = STPImageLibrary.brandImage(for: STPCard.brand(from: objAtIndex.cardBrand))
        
        cell.btnDeleteCard.addTarget(self, action: #selector(tapOnDeleteButton(_:)), for: .touchUpInside)
        cell.btnDeleteCard.tag = indexPath.row
        
        if objVMViewerPayments.arrNumberOfCard.count == 1 {
            objVMViewerPayments.callCompleteProfileApi(updateCardRequest(indexPath.row), isLoader: false, completion: {
            
            })
        }
        
        if GConstant.UserData.defaultCard == "" || GConstant.UserData.defaultCard == objAtIndex.cardID {
            cell.imgCheckbox.image = UIImage(named: "checkbox_sel")
        }else{
            cell.imgCheckbox.image = UIImage(named: "checkbox")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        objVMViewerPayments.callCompleteProfileApi(updateCardRequest(indexPath.row)) {
            self.objVMViewerPayments.defaultCard = indexPath.row
            tableView.reloadData()
        }
        
    }
    
    func updateCardRequest(_ index: Int) -> UserProfileRequestModel{
        let objAtIndex = objVMViewerPayments.arrNumberOfCard[index]
        
        let requestModel = UserProfileRequestModel()
        requestModel.user_id = GConstant.UserData.id
        requestModel.default_card = objAtIndex.cardID
        requestModel.is_profile_created = "Y"
        requestModel.user_type = GConstant.UserData.userType
        requestModel.device_type = "iOS"
        requestModel.device_token = GFunction.shared.getDeviceToken(.standard)
        requestModel.voip_device_token = GFunction.shared.getDeviceToken(.voip)
        
        return requestModel
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @objc func tapOnDeleteButton(_ sender: UIButton) {
        
        let objAtIndex = objVMViewerPayments.arrNumberOfCard[sender.tag]
        let card = "**** \(objAtIndex.cardLastFourDigit)"
        
        let title = "Card Number".localized()
        if GConstant.UserData.defaultCard == objAtIndex.cardID {
            let alert = GPAlert(title: "\(title) \(card)", message: "You can't delete default card.".localized())
            AlertManager.shared.showWithoutLocalize(alert)
            return
        }

        let alert = GPAlert(title: "\(title) \(card)", message: "Are you sure you want to delete this card?".localized())
        AlertManager.shared.showWithoutLocalize(alert, buttonsArray: ["No","Yes"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                break
            case 1:
                //Ok clicked
                GFunction.shared.addLoader(nil)
                StripeUtil.shared.deleteCard(objAtIndex.cardID, completion: { (objDict) in
                    DispatchQueue.main.async {
                        GFunction.shared.removeLoader()
                        if objDict != nil {
                            self.objVMViewerPayments.arrNumberOfCard.remove(at: sender.tag)
                            self.tblView.reloadData()
                        }
                    }
                    
                })
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

// MARK: Stripe Delegates

extension VMViewerPayments: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        GNavigation.shared.dismiss(true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        if GConstant.UserData.stripeCustomerId == nil || GConstant.UserData.stripeCustomerId!.count == 0 || GConstant.UserData.stripeCustomerId! == "0"{
            
            let requestModel = UserProfileRequestModel()
            requestModel.user_id = GConstant.UserData.id
            requestModel.token = token.tokenId
            self.callCreateCustomerIdApi(requestModel) {
                self.getAllCards()
            }
            
        }else{
            GFunction.shared.addLoader(nil)
            StripeUtil.shared.createCard(stripeId: GConstant.UserData.stripeCustomerId!, token: token) { (success) in
                DispatchQueue.main.async{
                    GFunction.shared.removeLoader()
                }
                if success == true {
                    DispatchQueue.main.async{
                        self.getAllCards()
                    }
                }
            }
        }
                    
        GNavigation.shared.dismiss(true)
    }
    
    func getAllCards(_ completion: @escaping ()->Void = {}) {
        GFunction.shared.addLoader(nil)
        StripeUtil.shared.getCardsList { (result) in
            DispatchQueue.main.async{
                GFunction.shared.removeLoader()
                if result != nil {
                    self.arrNumberOfCard.removeAll()
                    for obj in result! {
                        let card = Card.init(objData: obj)
                        self.arrNumberOfCard.append(card)
                        completion()
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
    }
}


