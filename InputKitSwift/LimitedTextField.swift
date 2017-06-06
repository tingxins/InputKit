//
//  LimitedTextField.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

class LimitedTextField: UITextField {
    
    #if TARGET_INTERFACE_BUILDER
    @IBInspectable var limitedType: Int?
    #else
    var limitedType: LimitedType = .normal(Int(MAX_INPUT)) {
        willSet {
            switch newValue {
            case .normal(let limitedNumber):
                self.limitedNumber = limitedNumber > 0 ? limitedNumber : Int(MAX_INPUT)
            case .price(let limitedPrefix, let limitedSuffix, let limitedNumber):
                self.limitedPrefix = limitedPrefix
                self.limitedSuffix = limitedSuffix
                self.limitedNumber = limitedNumber
            case .custom(let regEx, let isTextSelecting, let limitedNumber):
                self.limitedRegEx = regEx
                self.isTextSelecting = isTextSelecting
                self.limitedNumber = limitedNumber
            }
        }
        
        didSet {
        }
    }
    #endif
    
    @IBInspectable var limitedPrefix: Int?
    
    @IBInspectable var limitedSuffix: Int?
    
    @IBInspectable var limitedNumber: Int?
    
    @IBInspectable var limitedRegEx: String?
    
    @IBInspectable var isTextSelecting: Bool = false
    
    var limitedRegExs: [String]?
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
