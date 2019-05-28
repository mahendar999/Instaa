//
//  ImagePickerManager.swift
//  Instacam
//
//  Created by Apple on 01/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImagePickerManager: NSObject {
    static let shared = ImagePickerManager()
    
    private var imagePicker = UIImagePickerController()
    typealias CompletionHandler = (UIImage, Data)->Void
    var completion: CompletionHandler? = nil

    
    func compressImage(_ image: UIImage, compressionRatio : Float = 0.1) -> Data? {
        var compressionQuality: Float = compressionRatio
        var imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
        while Float((imageData! as NSData).length)/1024.0/1024.0 > 0.10 && compressionQuality > 0.02 {
            compressionQuality -= 0.05
            imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
        }
        return imageData
    }
    
    func callPickerOptions(_ sender: UIView, completion: CompletionHandler?) {
        sender.endEditing(true)
        self.imagePicker.delegate = self
        self.completion = completion
        
        let alert = UIAlertController(title: "Choose Image".localized(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: { _ in
            self.checkCameraAuth()
        }))
        alert.addAction(UIAlertAction(title: "Gallery".localized(), style: .default, handler: { _ in
            self.checkPhotoAuth()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: nil))
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        DispatchQueue.main.async {
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.allowsEditing = true
                self.appDelegate.window?.rootViewController?.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert  = UIAlertController(title: "Warning".localized(), message: "You don't have camera".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
                self.appDelegate.window?.rootViewController!.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func openGallary()
    {
        DispatchQueue.main.async {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.appDelegate.window?.rootViewController?.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                print("Authorized")
                self.openGallary()
                
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    AlertManager.shared.show(GConstant.Alert.photoPermission(), buttonsArray: ["Close","Go To Settings"], completionBlock: { (index : Int) in
                        
                        switch index{
                        case 0:
                            break
                        case 1:
                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            break
                        default:
                            //print("-:Something Wrong")
                            break
                        }
                        
                    })
                })
            default:
                break
            }
        }
    }
    
    //MARK:- Check the status of authorization for Camera
    func checkCameraAuth() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
            if (videoGranted) {
                //Do Your stuff here
                self.openCamera()
            } else {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    AlertManager.shared.show(GConstant.Alert.cameraPermission(), buttonsArray: ["Close","Go To Settings"], completionBlock: { (index : Int) in
                        
                        switch index{
                        case 0:
                            break
                        case 1:
                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            break
                        default:
                            //print("-:Something Wrong")
                            break
                        }
                        
                    })
                    
                })
                
            }
        })
    }
    
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK:- ImagePicker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            let data = self.compressImage(pickedImage)
            if completion != nil {
                completion!(pickedImage, data!)
            }
        }
        self.appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
