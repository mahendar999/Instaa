
import Foundation
import UIKit
import IQKeyboardManagerSwift

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "", comment: "")
    }
}

final class UILocalizedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        let title = self.title(for: .normal)?.localized()
        setTitle(title, for: .normal)
    }
}

final class UILocalizedLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
    }
}

final class UILocalizedTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholder = placeholder?.localized()
    }
}

final class UILocalizedTLFloatTextField: TLFloatLabelTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholder = placeholder?.localized()
        if self.placeHolderColor == .black {
            self.placeHolderColor = .black
        }else{
            self.placeHolderColor = .white
        }
    }
}

final class UILocalizedTextView: IQTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholder = placeholder?.localized()
    }
}

final class UILocalizedSegmentedControl: UISegmentedControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setTitle("Locations".localized(), forSegmentAt: 0)
        self.setTitle("Events".localized(), forSegmentAt: 1)
        
    }
}


/*
// We can use when we have different table for each components
@IBDesignable final class UILocalizedLabel: UILabel {
    @IBInspectable var tableName: String? {
        didSet {
            guard let tableName = tableName else { return }
            text = text?.localized(tableName: tableName)
        }
    }
}
*/
