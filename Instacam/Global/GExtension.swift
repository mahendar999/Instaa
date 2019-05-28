//
//  GExtension.swift
//  Trailer2You
//
//  Created by SIERRA on 4/6/18.
//  Copyright © 2018 GsBitLabs. All rights reserved.
//

import UIKit
import SDWebImage
import Shimmer

//MARK:- UIColor

extension UIColor {
    class func colorFromHex(hex: Int) -> UIColor {
        return UIColor(red: (CGFloat((hex & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((hex & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(hex & 0xFF)) / 255.0, alpha: 1.0)
    }
}

extension NSObject {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func isUserTypeViewer() -> Bool {
        if GConstant.UserData != nil && GConstant.UserData.userType == LoginUserType.viewer.rawValue {
            return true
        }else{
            return false
        }
    }
    
    func instantiateVC(with identifier: String) -> UIViewController {
        return GNavigation.shared.MainStoryBoard.instantiateViewController(withIdentifier: identifier)
    }
}

extension UILabel {
    
    func timerString(_ interval: TimeInterval) {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            self.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }else{
            self.text = String(format:"%02i:%02i", minutes, seconds)
        }
    }
    
    func priceString(_ interval: TimeInterval) {
        var priceStr = "0.00"
        if interval == 60 {
            priceStr = "1.00"
        }

        if interval > 60 {
            let price = 1.00 +  Double(interval) * 0.01
            priceStr = String(format:"%.2f", price)
        }
        
        self.text = "$\(priceStr)"
    }
}

extension Data {
    func toString() -> String{
        return String(data: self, encoding: .utf8) ?? ""
    }
}

//MARK:- UIFont

extension UIFont {
    
    class func applyRegular(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "Helvetica" , size: fontSize * GConstant.kHeightAspectRasio)!
        } else {
            return UIFont.init(name: "Helvetica" , size: fontSize)!
        }
    }
    
    class func applyBold(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "Helvetica-Bold" , size: fontSize * GConstant.kHeightAspectRasio)!
        }else {
            return UIFont.init(name: "Helvetica-Bold" , size: fontSize)!
        }
    }
    
    class func applyMedium(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "HelveticaNeue-Medium" , size: fontSize * GConstant.kHeightAspectRasio)!
        }else {
            return UIFont.init(name: "HelveticaNeue-Medium" , size: fontSize)!
        }
    }
    
    class func applyArialBold(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "ArialRoundedMTBold" , size: fontSize * GConstant.kHeightAspectRasio)!
        }else {
            return UIFont.init(name: "ArialRoundedMTBold" , size: fontSize)!
        }
    }
    
    class func applyArialRegular(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "ArialMT" , size: fontSize * GConstant.kHeightAspectRasio)!
        }else {
            return UIFont.init(name: "ArialMT" , size: fontSize)!
        }
    }
    
}

//MARK:- UIView

extension UIView {
    
//    func applyShimmering() {
//        let shimmeringView = FBShimmeringView(frame: self.bounds)
//        self.addSubview(shimmeringView)
//
//        let label = UILabel(frame: shimmerView.bounds)
//        label.textAlignment = .center
//        label.text = NSLocalizedString("Shimmer", comment: "")
//        shimmeringView.contentView = label
//
//        shimmeringView.shimmeringSpeed = 150
//        shimmeringView.tintColor = .white
//    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundedCorener() {
        self.layer.cornerRadius = self.bounds.midY
        self.clipsToBounds = true
    }
    
    func applyViewShadow(shadowOffset : CGSize? = nil
        , shadowColor : UIColor? = nil
        , shadowOpacity : Float? = nil
        , cornerRadius      : CGFloat? = nil
        , backgroundColor : UIColor? = nil
        , backgroundOpacity : Float? = nil)
    {
        
        if shadowOffset != nil {
            self.layer.shadowOffset = shadowOffset!
        }
        else {
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        
        if shadowColor != nil {
            self.layer.shadowColor = shadowColor?.cgColor
        } else {
            self.layer.shadowColor = UIColor.clear.cgColor
        }
        
        //For button border width
        if shadowOpacity != nil {
            self.layer.shadowOpacity = shadowOpacity!
        }
        else {
            self.layer.shadowOpacity = 0
        }
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor!
        }
        else {
            self.backgroundColor = UIColor.clear
        }
        
        if backgroundOpacity != nil {
            self.alpha = CGFloat(backgroundOpacity!)
        }
        else {
            self.layer.opacity = 1
        }
        
        self.layer.masksToBounds = false
    }
    
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func addBottomBorderWithColor(color: UIColor,origin : CGPoint, width : CGFloat , height : CGFloat) -> CALayer {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:origin.x, y:self.frame.size.height - height, width:width, height:height)
        self.layer.addSublayer(border)
        return border
    }
    
    func scaleAnimation(_ duration : Double! , scale : CGFloat!) {
        
        UIView.animate(withDuration: duration, animations: {
            
            self.superview?.isUserInteractionEnabled = false
            self.transform = CGAffineTransform(scaleX: 1 + scale, y: 1 + scale)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 1 - scale, y: 1 - scale)
                
            }, completion: { (isComplete : Bool) in
                self.superview?.isUserInteractionEnabled = true
            })
        }
    }
}

//MARK:- UIButton

extension UIButton {
    
    func applyShimmering() -> FBShimmeringView {
        
        self.titleLabel?.removeFromSuperview()
        let shimmeringView = FBShimmeringView(frame: self.bounds)
        shimmeringView.contentView = self.titleLabel
        shimmeringView.isShimmering = true
        shimmeringView.tintColor = .black
        shimmeringView.isUserInteractionEnabled = true
        
        self.addSubview(shimmeringView)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(.white, for: .normal)
        self.isUserInteractionEnabled = true
        
        return shimmeringView
    }

    func applyStyle(
         titleLabelFont     : UIFont?  = nil
        , titleLabelColor   : UIColor? = nil
        , cornerRadius      : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = 1.5
        , state             : UIControl.State = UIControl.State.normal
        , backgroundColor   : UIColor? = nil
        , backgroundOpacity : Float? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }

        if titleLabelFont != nil {
            self.titleLabel?.font = titleLabelFont
        }else {
            self.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if titleLabelColor != nil {
            self.setTitleColor(titleLabelColor, for: state)
        } else {
            self.setTitleColor(UIColor.black, for: state)
        }
        
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor!
        }
        else {
            self.backgroundColor = UIColor.clear
        }
        
        if backgroundOpacity != nil {
            self.layer.opacity = backgroundOpacity!
        }
        else {
            self.layer.opacity = 1
        }
        
    }
    
}

//MARK:- UILabel

extension UILabel {
    
    func applyStyle(
          labelFont      : UIFont?  = nil
        , labelColor     : UIColor? = nil
        , cornerRadius   : CGFloat? = nil
        , borderColor    : UIColor? = nil
        , borderWidth    : CGFloat? = nil
        , labelShadow    : CGSize? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if labelFont != nil {
            self.font = labelFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if labelColor != nil {
            self.textColor = labelColor
        } else {
            self.textColor = UIColor.black
        }
        
    }
    
    func addCharacterSpacing(value: CGFloat) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
    
    ///Find the index of character (in the attributedText) at point
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
      
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
    
}

//MARK:- UITextField

extension UITextField {
    
    func applyStyle(
          textFont    : UIFont?  = nil
        , textColor   : UIColor? = nil
        , cornerRadius       : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if textFont != nil {
            self.font = textFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if textColor != nil {
            self.textColor = textColor
        } else {
             self.textColor = UIColor.black
        }
        
    }
    
    func setAttributedPlaceHolder(placeHolderText : String , color : UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    

   
}
//MARK:- UITextView

extension UITextView {
    
    
    func applyStyle(
        textFont    : UIFont?  = nil
        , textColor   : UIColor? = nil
        , cornerRadius       : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if textFont != nil {
            self.font = textFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if textColor != nil {
            self.textColor = textColor
        } else {
            self.textColor = UIColor.black
        }
        
    }
    
}

//MARK: - UIImageView Extension

extension UIImageView {
    
    func applyStype(cornerRadius : CGFloat? = nil
        , borderColor : UIColor? = nil
        , borderWidth : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
            self.clipsToBounds = true
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
    }
    
    func setImageWithDownload(_ url : URL, withIndicator isIndicator: Bool = true) {
        if isIndicator {
            self.sd_setShowActivityIndicatorView(true)
            self.sd_setIndicatorStyle(.gray)
        }
        
        self.sd_setImage(with: url, placeholderImage: UIImage(), completed: {(image, error, cacheType, imageURL) -> Void in
            // Perform operation.
            if error != nil {
                print(" ============= ERROR ===============\n\n\(error!.localizedDescription)\n\n\(imageURL!)")
            }
            
            self.contentMode = .scaleAspectFill
            self.clipsToBounds = true
            
        })
        
    }
    
}

//MARK:- Image Extension
extension UIImage {
    
    func isEqualToImage(_ image: UIImage) -> Bool {
        
        guard self.pngData() != nil else {
            return false
        }
        
        guard image.pngData() != nil else {
            return false
        }
        
        let data1: NSData = self.pngData()! as NSData
        let data2: NSData = image.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
    func imageScale(scaledToWidth i_width: CGFloat) -> UIImage {
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat = i_width / oldWidth
        let newHeight: CGFloat = self.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(newWidth), height: CGFloat(newHeight)), true, 0)
        self.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newWidth), height: CGFloat(newHeight)))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getPostImageScaleFactor(_ i_width: CGFloat) -> CGFloat {
        
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat = oldWidth / i_width 
        return scaleFactor
    }
    
    func getDeviceWiseImageScaleFactor(_ i_width: CGFloat) -> CGFloat {
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat =  i_width / oldWidth
        return scaleFactor
    }
    
}

//MARK:- String

extension String {
    
    func changeDateFormat(dateFormat: String, formatChange: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: self)!
        dateFormatter.dateFormat = formatChange
        return dateFormatter.string(from: date)
    }
    
    func isEmptyValue() -> Bool {
        if self.range(of: "-- ") != nil && self.range(of: " --") != nil {
            return true
        }else{
            return false
        }
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func findHeightForText(text: String, havingWidth widthValue: CGFloat, havingHeight heightValue: CGFloat, andFont font: UIFont) -> CGSize {
        let result: CGFloat = font.pointSize + 4
        var size: CGSize = CGSize()
        if text.count > 0 {
            
            let textSize: CGSize = CGSize(width: widthValue, height: (heightValue > 0.0) ? heightValue : heightValue)
            //Width and height of text area
            if #available(iOS 7, *) {
                //iOS 7
                let frame: CGRect = text.boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
                
                size = CGSize(width: frame.size.width, height: frame.size.height + 1)
            }
            size.height = max(size.height, result)
            //At least one row
        }
        return size
    }
    
    func sizeOfString (font : UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude),
                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                   attributes: [NSAttributedString.Key.font: font],
                                   context: nil).size
    }
    
    func getHeight(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func getWidth(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func url() -> URL {
        guard let url = URL(string: self) else {
            return URL(string : "www.google.co.in")!
        }
        return url
    }
    
    // Call Number Setup
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    struct CustomDateFormat {
        let date: String!
        let time: String!
    }
    
    func getBookingDateTime() -> CustomDateFormat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let strDate = dateFormatter.string(from: date!)
        
        dateFormatter.dateFormat = "HH:mm"
        let strTime = dateFormatter.string(from: date!)
        
        return CustomDateFormat(date: strDate, time: strTime)
    }
    
    func calculateHours(_ division: Bool = false) -> Int {
        var hours = (self.range(of: " ") != nil) ? Int(self.components(separatedBy: " ")[0])! : Int(self)!
        
        if (self.range(of: "Days") != nil) {
            hours = hours*24
        }
        
        if (self.range(of: "Weeks") != nil) {
            hours = hours*24*7
        }
        return division == false ? hours : hours/6
    }
    
    func INT() -> Int {
        return Int(self) != nil ? Int(self)! : 0
    }
    
    func DOUBLE() -> Double {
        return Double(self) != nil ? Double(self)! : 0
    }
    
    
    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"){
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }else{
                    AlertManager.shared.showPopup(GPAlert(title: "", message: "Calling feature not available"), forTime: 2.0, completionBlock: { (Int) in
                    })
                }
            }
        }else{
            AlertManager.shared.showPopup(GPAlert(title: "", message: "Phone number not valid"), forTime: 2.0, completionBlock: { (Int) in
            })
        }
    }
}

//MARK:- Date

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension Date {
 
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func to13digitMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 / 1000)
    }
    
    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
//        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    
    func convertToString(customFormat: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = customFormat
        let strDate = dateFormatter.string(from: self)
        return strDate
    }
    
    //MARK: - convert date to local
    
    func convertToLocal(sourceDate : Date)-> Date{
        
        let sourceTimeZone                                     = NSTimeZone(abbreviation: "UTC")//NSTimeZone(name: "America/Los_Angeles") EDT
        let destinationTimeZone                                = NSTimeZone.system
        
        //calc time difference
        let sourceGMTOffset         : NSInteger                = (sourceTimeZone?.secondsFromGMT(for: sourceDate as Date))!
        let destinationGMTOffset    : NSInteger                = destinationTimeZone.secondsFromGMT(for:sourceDate as Date)
        let interval                : TimeInterval             = TimeInterval(destinationGMTOffset-sourceGMTOffset)
        
        //set currunt date
        let date: Date                                          = Date(timeInterval: interval, since: sourceDate as Date)
        return date
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - convert date to utc
    
    func convertToUTC(sourceDate : Date)-> Date{
        
        let sourceTimeZone                                      = NSTimeZone.system
        let destinationTimeZone                                 = NSTimeZone(abbreviation: "UTC") //NSTimeZone(name: "America/Los_Angeles") EDT
        
        //calc time difference
        let sourceGMTOffset         : NSInteger                 = (sourceTimeZone.secondsFromGMT(for:sourceDate as Date))
        let destinationGMTOffset    : NSInteger                 = destinationTimeZone!.secondsFromGMT(for: sourceDate as Date)
        let interval                : TimeInterval              = TimeInterval(destinationGMTOffset-sourceGMTOffset)
        
        //set currunt date
        let date: Date                                        = Date(timeInterval: interval, since: sourceDate as Date)
        return date
    }
    
    //------------------------------------------------------
    
    //MARK: - DateFormat
    
    func formatdateLOCAL(dt: String,dateFormat: String,formatChange: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = self.convertToLocal(sourceDate: dateFormatter.date(from: dt)! as Date)
        dateFormatter.dateFormat = formatChange
        return dateFormatter.string(from: date as Date)
    }
    
    func formatdateUTC(dt: String,dateFormat: String,formatChange: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = self.convertToUTC(sourceDate: dateFormatter.date(from: dt)! as Date)
        dateFormatter.dateFormat = formatChange
        return dateFormatter.string(from: date as Date)
    }
    
    func getTimeStampFromDate() -> (double : Double,string : String) {
        let timeStamp = self.timeIntervalSince1970
        return (timeStamp,String(format: "%f", timeStamp))
    }
    
    // MARK:- Date comparsion
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
}

// MARK:- Navigation Controller
extension UINavigationController{
    func customize(isTransparent: Bool = false, isPicker: Bool? = false){
        
        let navigationFont               = UIFont.applyRegular(fontSize: 15.5)
        let navigationBarAppearace       = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = GConstant.AppColor.lightSkyBlue
        
        if isTransparent {
            navigationBarAppearace.backgroundColor = .clear
        }
        
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font:navigationFont, NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layer.masksToBounds = false
        
        if isTransparent {
            self.navigationBar.isTranslucent       = true
        }else{
            self.navigationBar.isTranslucent       = false
            self.navigationBar.isOpaque = true
        }
        
    }
    
}

class BarButton : NSObject {
    var title : String?
    var image : UIImage?
    var color : UIColor?
    var tintColor : UIColor?
    var isLeftMenu : Bool?
    var fontSize : CGFloat?
    
    init(title : String? = nil, image: UIImage? = nil , color : UIColor? = nil, fontSize: CGFloat? = nil , tintColor : UIColor? = nil, isLeftMenu : Bool? = nil) {
        self.title = title == nil ? "" : title
        self.image = image == nil ? UIImage() : image
        self.color = color == nil ? GConstant.AppColor.primary : color
        self.tintColor = tintColor == nil ? GConstant.AppColor.primary : tintColor
        self.isLeftMenu = isLeftMenu == nil ? true : isLeftMenu
        self.fontSize = fontSize == nil ? 13.0 : fontSize
    }
    
}

//MARK:- UIViewController
extension UIViewController {
    
    func toolBarDoneButtonClicked() {
        self.view.endEditing(true)
    }
    
    // add BarButton
    func addBarButtons(btnLeft : BarButton? , btnRight : BarButton? , title : String? , isShowLogo : Bool = false) -> [UIButton] {
        
        var arrButtons : [UIButton] = [UIButton(),UIButton()]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)]
        
        // setup for left button
        if btnLeft != nil {
            
            let leftButton = UIButton(type: .custom)
            leftButton.contentHorizontalAlignment = .left
            
            if btnLeft?.title == String() {
                
                if btnLeft?.image != UIImage() {
                    leftButton.setImage(btnLeft?.image, for: .normal)
                    leftButton.imageView?.contentMode = .scaleAspectFit
                }
                
            }else
            {
                leftButton.setTitleColor(btnLeft?.color, for: .normal)
                leftButton.setTitleColor(GConstant.AppColor.primary, for: .disabled)
                leftButton.setTitle(btnLeft?.title, for: .normal)
                let btnFont = UIFont.applyRegular(fontSize: (btnLeft?.fontSize)!, isAspectRasio: false)
                leftButton.titleLabel?.font = btnFont
            }
            
            leftButton.adjustsImageWhenHighlighted = false
            leftButton.tintColor = btnLeft?.tintColor
            leftButton.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(44), height: 44)
            
            if (btnLeft?.isLeftMenu)! {
                if (self.revealViewController() != nil)
                {
                    leftButton.addTarget(self.revealViewController(), action: Selector("revealToggle:"), for: .touchUpInside)
                    self.view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
                }
            }else{
                let leftBtnSelector: Selector = NSSelectorFromString("leftButtonClicked")
                if responds(to: leftBtnSelector) {
                    leftButton.addTarget(self, action: leftBtnSelector, for: .touchUpInside)
                }
            }
            
            let leftItem = UIBarButtonItem(customView: leftButton)
            navigationItem.leftBarButtonItems = [leftItem]
            arrButtons.removeFirst()
            arrButtons.insert(leftButton, at:0)
            
        }
        
        // setup for right button
        
        if btnRight != nil {
            let rightButton = UIButton(type: .custom)
            rightButton.contentHorizontalAlignment = .right
            rightButton.tintColor = UIColor.darkGray
            
            if btnRight?.title == String() {
                if btnRight?.image != UIImage() {
                    rightButton.setImage(btnRight?.image, for: .normal)
                    rightButton.imageView?.contentMode = .scaleAspectFit
                }
            }else
            {
                rightButton.setTitleColor(btnRight?.color, for: .normal)
                rightButton.setTitleColor(GConstant.AppColor.primary, for: .disabled)
                if btnRight?.image != UIImage() {
                    rightButton.setImage(btnRight?.image, for: .normal)
                    rightButton.imageView?.contentMode = .scaleAspectFit
                    rightButton.setTitle(" \(btnRight?.title ?? "")", for: .normal)
                }else{
                    rightButton.setTitle(btnRight?.title, for: .normal)
                }
                
                let btnFont = UIFont.applyRegular(fontSize: (btnRight?.fontSize)!, isAspectRasio: false)
                rightButton.titleLabel?.font = btnFont
            }
            
            rightButton.adjustsImageWhenHighlighted = false
            rightButton.tintColor = btnRight?.tintColor
            rightButton.frame = CGRect(x: 0, y: CGFloat(0), width: CGFloat(44), height: 44)
            let rightBtnSelector: Selector = NSSelectorFromString("rightButtonClicked")
            if responds(to: rightBtnSelector) {
                rightButton.addTarget(self, action: rightBtnSelector, for: .touchUpInside)
            }
            let rightItem = UIBarButtonItem(customView: rightButton)
            navigationItem.rightBarButtonItems = [rightItem]
            arrButtons.removeLast()
            arrButtons.append(rightButton)
            
        }
        
        if (title!.isEmpty) {
            if isShowLogo {
                navigationTitleImage(sender: self)
            }else{
                self.navigationItem.title = ""
            }
        }else{
            self.navigationItem.title = title
        }
        
        return arrButtons
    }
    
    func navigationTitleImage(sender: UIViewController){
        let logo = UIImage(named: "location_pin")
        let imageView = UIImageView(image:logo)
        sender.navigationItem.titleView = imageView
    }
    
}

//MARK: -
extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

//MARK: - DOUBLE
extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class InstaTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}


public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
