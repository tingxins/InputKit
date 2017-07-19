//
//  LimitedTextField.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

open class LimitedTextField: UITextField {
    
    //MARK: - Property defines
    fileprivate var selectionRange: NSRange = NSMakeRange(0, 0)
    
    fileprivate var historyText: String?
    
    open var limitedType: LimitedType = .normal
    @IBInspectable var _limitedType: Int {
        get {
            return limitedType.rawValue
        }
        set {
            limitedType = LimitedType(rawValue: newValue) ?? .normal
        }
    }
    
    @IBInspectable open var limitedNumber: Int = Int(MAX_INPUT)
    
    @objc @IBInspectable open var limitedPrefix: Int = Int(MAX_INPUT)
    
    @objc @IBInspectable open var limitedSuffix: Int = Int(MAX_INPUT)
    
    @IBInspectable open var isTextSelecting: Bool = false
    
    @IBInspectable open var limitedRegEx: String? {
        didSet {
            if let regEx = limitedRegEx, regEx.count > 0 {
                limitedRegExs = [regEx]
            }
        }
    }
    
    open var limitedRegExs: [String]? {
        didSet {
            var realRegEx: String = ""
            var realRegExs: [String] = []
            limitedRegExs?.forEach({ (regEx) in
                realRegEx = regEx.replacingOccurrences(of: "\\\\", with: "\\")
                if realRegEx.count != 0 {
                    realRegExs.append(realRegEx)
                }
            })
            limitedRegExs = realRegExs
            clearCache()
        }
    }
    
    //MARK: - initial Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addNotifications()
        addConfigs()
        if self.delegate == nil { addDelegate() }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        addNotifications()
        addConfigs()
        if self.delegate == nil { addDelegate() }
    }
    
    fileprivate var limitedDelegate: LimitedTextFieldDelegate?
    override open var delegate: UITextFieldDelegate? {
        get {
            return limitedDelegate
        }
        set {
            if let value = newValue {
                limitedDelegate = LimitedTextFieldDelegate(realDelegate: value)
            }else {
                limitedDelegate = nil
            }
            super.delegate = limitedDelegate
        }
    }
    
    //MARK: - Deinitialized
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LimitedTextField {
    //MARK: - Config Methods
    fileprivate func addNotifications() {
        print(#function, Notification.Name.UITextFieldTextDidChange)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(notification:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        //        self.addTarget(self, action: #selector(textFieldTextDidChange(textField:)), for: .editingChanged)
    }
    
    fileprivate func addDelegate() {
        delegate = nil;
    }
    
    fileprivate func addConfigs() {
        autocorrectionType = .no;
    }
    
    fileprivate func clearCache() {
        historyText = nil;
    }
}

//MARK: - @objc Methods
extension LimitedTextField {
    
    //MARK: - Target
//    @objc private func textFieldTextDidChange(textField: LimitedTextField) {
//
//        print(self, #function)
//    }
    
    //MARK: - Notifications
    @objc fileprivate func textFieldTextDidChange(notification: Notification) {
        let textField = notification.object as? UITextField
        if self != textField { return }
        
        let currentText = textField?.text
        let maxLength = self.limitedNumber
        
        var position: UITextPosition?
        if let markedTextRange = textField?.markedTextRange {
            position = textField?.position(from: markedTextRange.start, offset: 0)
        }
        
        var isMatch = true
        switch self.limitedType {
        case .normal: break
        case .price:
            isMatch = MatchManager.matchLimitedTextTypePrice(component: textField!, value: currentText!)
        case .custom:
            isMatch = MatchManager.matchLimitedTextTypeCustom(regExs: self.limitedRegExs, component: textField!, value: currentText!)
        }
        
        if isMatch {
            self.historyText = textField?.text
        }
        
        if position == nil {
            var flag = false
            if let count = currentText?.count, count > maxLength {
                textField?.text = String(currentText!.dropLast(count - maxLength))
                flag = true
            }
            
            if self.isTextSelecting && !isMatch {
                flag = true
                if let hisText = self.historyText,
                    let curText = textField?.text,
                    hisText.count <= curText.count {
                    textField?.text = hisText
                }else {
                    textField?.text = ""
                }
            }
            
            let text: NSString = currentText! as NSString
            if ((self.selectionRange.length > 0) && !isMatch && (self.selectionRange.length + self.selectionRange.location <= text.length)) {
                let limitedText = text.substring(with: self.selectionRange)
                textField?.text = (textField?.text as NSString!).replacingOccurrences(of: limitedText, with: "")
                self.selectionRange = NSMakeRange(0, 0)
            }
            
            if flag {
                // Send limits msg
                sendIllegalMsgToObject();
            }
        }else {
            guard let markedTextRange = textField?.markedTextRange else { return }
            self.selectionRange = range(from: markedTextRange)
        }
    }
}

extension LimitedTextField {
    
    fileprivate func range(from textRange: UITextRange) -> NSRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }
    
    fileprivate func sendIllegalMsgToObject() {
        guard let delegate = self.limitedDelegate
            , let realDelegate = delegate.realDelegate else {
            return
        }
        delegate.sendMsgTo(obj: realDelegate, with: self, sel: InputKitMessage.Name.inputKitDidLimitedIllegalInputText)
    }
}

fileprivate class LimitedTextFieldDelegate: LimitedDelegate, UITextFieldDelegate {
    
    @available(iOS 2.0, *)
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldShouldBeginEditing(_:))) {
            flag = realDelegate.textFieldShouldBeginEditing(textField)
        }
        return flag
    } // return NO to disallow editing.
    
    @available(iOS 2.0, *)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldDidBeginEditing(_:))) {
            realDelegate.textFieldDidBeginEditing(textField)
        }
    }// became first responder
    
    @available(iOS 2.0, *)
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldShouldEndEditing(_:))) {
            flag = realDelegate.textFieldShouldEndEditing(textField)
        }
        return flag
    } // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    @available(iOS 2.0, *)
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldDidEndEditing(_:))) {
            realDelegate.textFieldDidEndEditing(textField)
        }
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldDidEndEditing(_:reason:))) {
            realDelegate.textFieldDidEndEditing(textField, reason: reason)
        }else if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldDidEndEditing(_:))) {
            self.textFieldDidEndEditing(textField)
        }
    } // if implemented, called in place of textFieldDidEndEditing:
    
    @available(iOS 2.0, *)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(self, #function)
        var flag = true
        
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textField(_:shouldChangeCharactersIn:replacementString:))) {
            flag = realDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        
        var matchResult = true
        if textField.isKind(of: LimitedTextField.self) {
            let limitedTextField = textField as! LimitedTextField
            
            let matchStr = MatchManager.getMatchContentWithOriginalText(originalText: textField.text!, replaceText: string, range: range)
            
            let isDeleteOperation = (range.length > 0 && string.characters.count == 0) ? true : false;
            
            switch limitedTextField.limitedType {
            case .normal:
                break
            case .price:
                matchResult = MatchManager.matchLimitedTextTypePrice(component: textField, value: matchStr)
            case .custom:
                if limitedTextField.isTextSelecting {
                    matchResult = true
                }else {
                    matchResult = MatchManager.matchLimitedTextTypeCustom(regExs: limitedTextField.limitedRegExs, component: textField, value: matchStr)
                }
            }
            let result = flag && (matchResult || isDeleteOperation);
            if !result {
                limitedTextField.sendIllegalMsgToObject();
            }
            return result
        }
        return matchResult && flag
    }// return NO to not change text
    
    
    @available(iOS 2.0, *)
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldShouldClear(_:))) {
            flag = realDelegate.textFieldShouldClear(textField)
        }
        return flag
    }
    
    @available(iOS 2.0, *)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textFieldShouldClear(_:))) {
            flag = realDelegate.textFieldShouldClear(textField)
        }
        return flag
    }// called when 'return' key pressed. return NO to ignore.
    
}
