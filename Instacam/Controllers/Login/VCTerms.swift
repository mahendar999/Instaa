//
//  VCTerms.swift
//  Instacam
//
//  Created by Apple on 29/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

class VCTerms: UIViewController {

    @IBOutlet weak var CustomView: UIView!
    @IBOutlet weak var btnAgreeOutlet: UIButton!
    @IBOutlet weak var btnDeclineOutlet: UIButton!
    @IBOutlet weak var btnCheckboxOutlet: UIButton!
    
    private var webView: WKWebView
    var objVMAPIs = VMAPIs()
    var requestModel = UserProfileRequestModel()
    var objVMVerification = VMVerification()
    
    required init?(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
    }
    
    func initMainView() {
        GFunction.shared.removeLoader()
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: "Terms and Conditions".localized())
        
        self.btnAgreeOutlet.roundedCorener()
        self.btnDeclineOutlet.roundedCorener()
        
        CustomView.addSubview(webView)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: CustomView, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: CustomView, attribute: .width, multiplier: 1, constant: 0)
        CustomView.addConstraints([height, width])
        
        objVMAPIs.callGetAppPageContentApi(.terms, isLoading: true) { (webContent) -> Void in
            self.webView.loadHTMLString(webContent, baseURL: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.customize()
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.popToRoot(VCLogin.self)
    }
    
    @IBAction func btnCheckbox(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            sender.isSelected = false
        }else{
            sender.tag = 1
            sender.isSelected = true
        }
    }
    
    @IBAction func btnFullTerms(_ sender: UIButton) {
        
    }
    
    @IBAction func btnAgree(_ sender: UIButton) {
        if btnCheckboxOutlet.isSelected {
            self.objVMVerification.callSignupApi(requestModel, isLoader: true, completion: {
                GNavigation.shared.pushWithoutData(GVCIdentifier.completeProfile)
            })
        }else{
            let alert = GPAlert(title: "Terms and Conditions", message: "Please select Terms and Conditions")
            AlertManager.shared.show(alert)
        }
    }

    @IBAction func btnDecline(_ sender: UIButton) {
        GNavigation.shared.popToRoot(VCLogin.self)
    }
    
}

// MARK:- WKWebView Delegates

extension VCTerms: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let jsCommand = String(format: "document.body.style.zoom = 2.0;")
        self.webView.evaluateJavaScript(jsCommand, completionHandler: { (object, error) in
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    
}
