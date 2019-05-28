//
//  VCStreamerPayment.swift
//  Instacam
//
//  Created by Apple on 29/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

class VCStreamerAddAcc: UIViewController {

    var navTitle = String()
    var isPresent = false
    var objVMAPIs = VMAPIs()
    private var webView: WKWebView
    
    required init?(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
        
    }
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Add Account".localized())
        self.navigationController?.customize()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        let strURL = GAPIConstant.createStripeAccount() + "/\(GConstant.UserData.id!)"
        let url = URL(string: strURL)
        let request = URLRequest(url:url!)
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }

}

// MARK:- WKWebView Delegates

extension VCStreamerAddAcc: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        GFunction.shared.addLoader(nil)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (object, error) -> Void in
            
            if error == nil {
                
//                let htmlString = String(htmlEncodedString: (object as! String)).replacingOccurrences(of: "\n", with: "}")
//                let json = htmlString.parseJSONString
//
//                var isExit = false
//                if let dict = json as? NSDictionary {
//                    if let success = dict["success"] as? Int {
//                        let alert = GPAlert(title: "Payment Status", message: dict["message"] as! String)
//                        isExit = true
//                        AlertManager.shared.showPopup(alert, forTime: 3.0, completionBlock: { (INT) in
//                            GNavigation.shared.pop()
//                        })
//                    }
//                }
                
                let requestModel = UserProfileRequestModel()
                requestModel.user_id = GConstant.UserData.id
                requestModel.user_type = GConstant.UserData.userType
                self.objVMAPIs.callGetProfileApi(requestModel)
                
                GNavigation.shared.pop()
                
            }
            
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        GFunction.shared.removeLoader()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        GFunction.shared.removeLoader()
    }
    
    
}


extension String {
    
    init(htmlEncodedString: String) {
        self.init()
        guard let encodedData = htmlEncodedString.data(using: .utf8) else {
            self = htmlEncodedString
            return
        }
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = htmlEncodedString
        }
    }
}
