//
//  APICall.swift
//  APIDemo
//
//  Created by hyperlink on 8/31/16.
//  Copyright © 2016 hyperlink. All rights reserved.
//

import UIKit
import Alamofire

class APICall: NSObject {
    static let shared = APICall()
    
    class APIManager {
        class func headers() -> HTTPHeaders {
            let headers: HTTPHeaders = [
                "content-type": "application/json",
//                kHeaderAPIKey           : kHeaderAPIKeyValue
            ]
            
//            if let authToken = UserDefaults.standard.string(forKey: "auth_token") {
//                headers["Authorization"] = "Token" + " " + authToken
//            }
            
            return headers
        }
    }
    
    class APIError {
        class func handleError(response: DataResponse<Any>) -> String {
            var errorDescription, reasonDetail, message: String!
            if let error = response.result.error as? AFError {
                switch error {
                case .invalidURL(let url):
                    errorDescription = ("Invalid URL: \(url) - \(error.localizedDescription)")
                case .parameterEncodingFailed(let reason):
                    errorDescription = ("Parameter encoding failed: \(error.localizedDescription)")
                    reasonDetail = ("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    errorDescription = ("Multipart encoding failed: \(error.localizedDescription)")
                    reasonDetail = ("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    errorDescription = ("Response validation failed: \(error.localizedDescription)")
                    reasonDetail = ("Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                    }
                    
                case .responseSerializationFailed(let reason):
                    errorDescription = ("Response serialization failed: \(error.localizedDescription)")
                    reasonDetail = ("Failure Reason: \(reason)")
                }
                
                let statusCode = error._code
                let underLayingError = ("Underlying error: \(String(describing: error.underlyingError))")
                
                let errorDetail = "\(statusCode) \n \(errorDescription) \n \(reasonDetail) \n \(underLayingError)"
                message = errorDetail
            } else if let error = response.result.error as? URLError {
                message = error.localizedDescription
            } else {
                message = ""
            }
            return message
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - GET
    
    //GET Method
    //Parameter
    //url :- method name of API like user/login
    //parameter : - parameter which is required to pass in API
    //errorAlert : - pass Bool value to decide if any error occcued then display alert or not
    //isLoader : - to decide if Add loader or not
    //completion :- completion block for pass response in class
    
    func GET(strURL url : String
        ,parameter : Dictionary<String,Any>?
        ,withErrorAlert errorAlert : Bool = false
        ,withLoader isLoader : Bool = true
        ,debugInfo isPrint : Bool = true
        ,withBlock completion :@escaping (Data?,Int) -> Void) {
        
        if Connectivity.isConnectedToInternet {
            
            if isPrint {
                print("*****************URL***********************\n")
                print("URL:- \(url)\n")
                print("Parameter:-\(String(describing: parameter))\n")
                print("MethodType:- GET\n")
                print("*****************End***********************\n")
            }
            
            var param = Dictionary<String,Any>()
            if parameter != nil {
                param = parameter!
                param["lang"] = GConstant.prefferedLanguage
            }
            
            // add loader if isLoader is true
            if isLoader {
                GFunction.shared.addLoader(nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
            Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding(), headers: APIManager.headers()).responseJSON(completionHandler: { (response) in
                
                switch(response.result) {
                case .success(let JSON):
                    if isPrint {
                        print(JSON)
                    }
                    
                    // remove loader if isLoader is true
                    if isLoader {
                        GFunction.shared.removeLoader()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    var statusCode = 0
                    //Logout User
                    if let headerResponse = response.response {
                        statusCode = headerResponse.statusCode
                    }
                    
                    self.checkStatus(response: response, completion: { (success) in
                        if success {
                            completion(response.data, statusCode)
                        }
                    })
                    
                // Yeah! Hand response
                case .failure(let error):
                    
                    if isLoader {
                        GFunction.shared.removeLoader()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    var statusCode = 0
                    
                    //Logout User
                    if let headerResponse = response.response {
                        statusCode = headerResponse.statusCode
                        if (headerResponse.statusCode == 404) {
                            //TODO: - Add your logout code here
                            GFunction.shared.userLogOut(self.appDelegate.window)
                        }
                    }
                    
                    //Display error Alert if errorAlert is true
                    if(errorAlert) {
                        let err = error as NSError
                        if statusCode != 401
                            && err.code != NSURLErrorTimedOut
                            && err.code != NSURLErrorNetworkConnectionLost
                            && err.code != NSURLErrorNotConnectedToInternet{
                            
                        } else {
                            print(error.localizedDescription)
                        }
                    }
                    
                    let alert = GPAlert(title: GConstant.AppName, message: APIError.handleError(response: response))
                    AlertManager.shared.show(alert)
                    completion(nil,statusCode)
                    
                }
            })
        }
        
    }
        
    var isAlert = false
    func checkStatus(response: DataResponse<Any>, completion: @escaping (Bool)->Void) {
        
        if isAlert {
            return
        }
        
        let responseModel = try! CommonResponseModel.init(data: response.data!)
        if let statusCode = responseModel.success {
            if statusCode == 333 || statusCode == 403 || statusCode == 404{
                self.isAlert = true
                let alert = GPAlert(title: GConstant.AppName, message: responseModel.message!)
                AlertManager.shared.show(alert, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        self.isAlert = false
                        GFunction.shared.userLogOut(self.appDelegate.window)
                        break
                    default:
                        break
                    }
                }
            completion(false)
                
                return
            }
        }
        
        completion(true)
    }
    
    //------------------------------------------------------

    //MARK: - POST
    
    //POST Method
    //Parameter
    //url :- method name of API like user/login
    //parameter : - parameter which is required to pass in API
    //errorAlert : - pass Bool value to decide if any error occcued then display alert or not
    //isLoader : - to decide if Add loader or not
    //blockFormData : - Pass image or array of image if you have to pass in API
    //completion :- completion block for pass response in class

    
    func POST(strURL url : String
        , parameter :  Dictionary<String, Any>?
        , withErrorAlert errorAlert : Bool = false
        , withLoader isLoader : Bool = true
        , debugInfo isPrint : Bool = true
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , apiHeaders: HTTPHeaders = APIManager.headers()
        , withBlock completion : @escaping (Data?, Int) -> Void){
      
        if Connectivity.isConnectedToInternet {

            if isPrint {
                print("*****************URL***********************\n")
                print("URL:- \(url)\n")
                print("Parameter:-\(String(describing: parameter))\n")
                print("MethodType:- POST\n")
                print("*****************End***********************\n")
            }
            
            var param = Dictionary<String,Any>()
            if parameter != nil {
                param = parameter!
                param["lang"] = GConstant.prefferedLanguage
            }
            
            // add loader if isLoader is true
            if isLoader {
                GFunction.shared.addLoader(nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
            Alamofire.request(url, method: .post, parameters: param, encoding: apiEncoding, headers: apiHeaders).responseJSON(completionHandler: { (response) in
                
                switch(response.result) {
                case .success(let JSON):
                    DispatchQueue.main.async {
                        
                        if isPrint {
                            print(JSON)
                        }
                        
                        // remove loader if isLoader is true
                        if isLoader {
                            GFunction.shared.removeLoader()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                        
                        var statusCode = 0
                        //Logout User
                        if let headerResponse = response.response {
                            statusCode = headerResponse.statusCode
                        }
                        
                        self.checkStatus(response: response, completion: { (success) in
                            if success {
                                completion(response.data, statusCode)
                            }
                        })
                        
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        
                        if isLoader {
                            GFunction.shared.removeLoader()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                        
                        var statusCode = 0
                        
                        //Logout User
                        if let headerResponse = response.response {
                            statusCode = headerResponse.statusCode
                            if (headerResponse.statusCode == 404) {
                                //TODO: - Add your logout code here
                                GFunction.shared.userLogOut(self.appDelegate.window)
                            }
                        }
                        
                        //Display error Alert if errorAlert is true
                        if(errorAlert) {
                            let err = error as NSError
                            if statusCode != 401
                                && err.code != NSURLErrorTimedOut
                                && err.code != NSURLErrorNetworkConnectionLost
                                && err.code != NSURLErrorNotConnectedToInternet{
                                
                            } else {
                                print(error.localizedDescription)
                            }
                        }
                        
                        let alert = GPAlert(title: GConstant.AppName, message: APIError.handleError(response: response))
                        AlertManager.shared.show(alert)
                        
                        completion(nil, statusCode)
                    }
                }
            })
            
        }
    }
    
    func Upload(strURL url : String
        , parameter :  Dictionary<String, Any>?
        ,withErrorAlert errorAlert : Bool = false
        ,withLoader isLoader : Bool = true
        ,debugInfo isPrint : Bool = true
        ,constructingBodyWithBlock blockFormData: ((MultipartFormData?) -> Void)? = nil
        , withBlock completion : @escaping (Data?, Int) -> Void) {

        if Connectivity.isConnectedToInternet {
            
            if isPrint {
                print("*****************URL***********************\n")
                print("URL:- \(url)\n")
                print("Parameter:-\(String(describing: parameter))\n")
                print("MethodType:- POST\n")
                print("*****************End***********************\n")
            }
            
            // add loader if isLoader is true
            if isLoader {
                GFunction.shared.addLoader(nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
            Alamofire.upload(multipartFormData: blockFormData!, usingThreshold: UInt64.init(), to: url, method: .post, headers: APIManager.headers(), encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch(response.result) {
                        case .success(let JSON):
                            DispatchQueue.main.async {
                                if isPrint {
                                    print(JSON)
                                }
                                
                                // remove loader if isLoader is true
                                if isLoader {
                                    GFunction.shared.removeLoader()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                                
                                var statusCode = 0
                                //Logout User
                                if let headerResponse = response.response {
                                    statusCode = headerResponse.statusCode
                                }
                                
                                self.checkStatus(response: response, completion: { (success) in
                                    if success {
                                        completion(response.data, statusCode)
                                    }
                                })
                            }
                            
                        case .failure(let error):
                            DispatchQueue.main.async {
                                
                                if isLoader {
                                    GFunction.shared.removeLoader()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                                
                                var statusCode = 0
                                
                                //Logout User
                                if let headerResponse = response.response {
                                    statusCode = headerResponse.statusCode
                                    if (headerResponse.statusCode == 404) {
                                        //TODO: - Add your logout code here
                                        GFunction.shared.userLogOut(self.appDelegate.window)
                                    }
                                }
                                
                                //Display error Alert if errorAlert is true
                                if(errorAlert) {
                                    let err = error as NSError
                                    if statusCode != 401
                                        && err.code != NSURLErrorTimedOut
                                        && err.code != NSURLErrorNetworkConnectionLost
                                        && err.code != NSURLErrorNotConnectedToInternet{
                                        
                                    } else {
                                        print(error.localizedDescription)
                                    }
                                }
                                

                                let alert = GPAlert(title: GConstant.AppName, message: APIError.handleError(response: response))
                                AlertManager.shared.show(alert)
                                
                                completion(nil, statusCode)
                                
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if isLoader {
                            GFunction.shared.removeLoader()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                        
                        let alert = GPAlert(title: GConstant.AppName, message: error.localizedDescription)
                        AlertManager.shared.show(alert)
                        
                        completion(nil, 0)
                        
                    }
                }
            })
        }
        
    }
    
}
