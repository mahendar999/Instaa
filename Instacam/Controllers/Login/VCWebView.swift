//
//  VCWebView.swift
//  Instacam
//
//  Created by Apple on 03/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

class VCWebView: UIViewController {
    
    var navTitle = String()
    private var webView: WKWebView
    var objVMAPIs = VMAPIs()
    
    required init?(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMainView()
        
    }
   
    
    func initMainView() {
        _ = addBarButtons(btnLeft: BarButton(image: GNavigation.navBackIcon, isLeftMenu: false), btnRight: nil, title: navTitle.localized())
        self.navigationController?.customize()
        
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        var contentType: PageContentType!
        switch navTitle {
        case "FAQ".localized():
            contentType = .faq
            break
        case "Privacy Policy".localized():
            contentType = .privacy
            break
        case "Community Guidelines".localized():
            contentType = .community
            break
        default:
            break
        }
        
        objVMAPIs.callGetAppPageContentApi(contentType, isLoading: true) { (webContent) -> Void in
            self.webView.loadHTMLString(webContent, baseURL: nil)
        }
        
    }
    
    @objc func leftButtonClicked() {
        GNavigation.shared.pop()
    }

}


// MARK:- WKWebView Delegates

extension VCWebView: WKNavigationDelegate {
    
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
