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
  private var selectionRange: NSRange = NSMakeRange(0, 0)
  
  private var historyText: String?
  
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
  
  private var limitedDelegate: LimitedTextFieldDelegate?
  override open var delegate: UITextFieldDelegate? {
    get {
      return limitedDelegate
    }
    set {
      limitedDelegate = LimitedTextFieldDelegate(realDelegate: newValue)
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
  private func addNotifications() {
    print(#function, Notification.Name.UITextFieldTextDidChange)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textFieldTextDidChange(notification:)),
                                           name: Notification.Name.UITextFieldTextDidChange,
                                           object: nil)
  }
  
  private func addDelegate() {
    delegate = nil
  }
  
  private func addConfigs() {
    autocorrectionType = .no
  }
  
  private func clearCache() {
    historyText = nil
  }
}

//MARK: - @objc Methods
extension LimitedTextField {
  //MARK: - Notifications
  @objc private func textFieldTextDidChange(notification: Notification) {
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
        } else {
          textField?.text = ""
        }
      }
      
      let text: NSString = currentText! as NSString
      if ((self.selectionRange.length > 0) && !isMatch && (self.selectionRange.length + self.selectionRange.location <= text.length)) {
        let limitedText = text.substring(with: self.selectionRange)
        textField?.text = textField?.text?.replacingOccurrences(of: limitedText, with: "")
        self.selectionRange = NSMakeRange(0, 0)
        
        if limitedText.count > 0 {
          flag = true
        }
      }
      
      if flag {
        // Send limits msg
        sendIllegalMsgToObject()
      }
    } else {
      guard let markedTextRange = textField?.markedTextRange else { return }
      self.selectionRange = range(from: markedTextRange)
    }
    sendDidChangeMsgToObject()
  }
}

extension LimitedTextField {
  
  fileprivate func range(from textRange: UITextRange) -> NSRange {
    let location = offset(from: beginningOfDocument, to: textRange.start)
    let length = offset(from: textRange.start, to: textRange.end)
    return NSMakeRange(location, length)
  }
  
  fileprivate func sendIllegalMsgToObject() {
    guard let delegate = self.limitedDelegate,
      let realDelegate = delegate.realDelegate else {
        return
    }
    delegate.sendMsgTo(obj: realDelegate, with: self, sel: InputKitMessage.Name.inputKitDidLimitedIllegalInputText)
  }
  
  fileprivate func sendDidChangeMsgToObject() {
    guard let delegate = self.limitedDelegate,
      let realDelegate = delegate.realDelegate else {
        return
    }
    delegate.sendMsgTo(obj: realDelegate, with: self, sel: InputKitMessage.Name.inputKitDidChangeInputText)
  }
  
  fileprivate func resetSelectionTextRange() {
    selectionRange = NSMakeRange(0, 0)
  }
}

fileprivate class LimitedTextFieldDelegate: LimitedDelegate, UITextFieldDelegate {
  @available(iOS 2.0, *)
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate,
      let shouldBeginEditing = textFieldDelegate.textFieldShouldBeginEditing?(textField) else {
        return true
    }
    return shouldBeginEditing
  } // return NO to forbid editing.
  
  @available(iOS 2.0, *)
  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate else { return }
    textFieldDelegate.textFieldDidBeginEditing?(textField)
  }// became first responder
  
  @available(iOS 2.0, *)
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate,
      let shouldEndEditing = textFieldDelegate.textFieldShouldEndEditing?(textField) else {
        return true
    }
    return shouldEndEditing
  } // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
  
  @available(iOS 2.0, *)
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate else { return }
    textFieldDelegate.textFieldDidEndEditing?(textField)
  } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
  
  @available(iOS 10.0, *)
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    (self.realDelegate as? UITextFieldDelegate)?.textFieldDidEndEditing?(textField, reason: reason)
  } // try call textFieldDidEndEditing:
  
  @available(iOS 2.0, *)
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var flag = true
    
    if let textFieldDelegate = self.realDelegate as? UITextFieldDelegate,
      let shouldChange = textFieldDelegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
      flag = shouldChange
    }
    
    var matchResult = true
    let limitedTextField = textField as! LimitedTextField
    if textField.isKind(of: LimitedTextField.self) {
      // 重置 Mark Range. (即 候选文本)
      limitedTextField.resetSelectionTextRange()
      let matchStr = MatchManager.getMatchContentWithOriginalText(originalText: textField.text!, replaceText: string, range: range)
      
      let isDeleteOperation = (range.length > 0 && string.count == 0)
      
      switch limitedTextField.limitedType {
      case .normal:
        break
      case .price:
        matchResult = MatchManager.matchLimitedTextTypePrice(component: textField, value: matchStr)
      case .custom:
        if limitedTextField.isTextSelecting {
          matchResult = true
        } else {
          matchResult = MatchManager.matchLimitedTextTypeCustom(regExs: limitedTextField.limitedRegExs, component: textField, value: matchStr)
        }
      }
      let result = flag && (matchResult || isDeleteOperation)
      if !result {
        limitedTextField.sendIllegalMsgToObject()
      }
      limitedTextField.sendDidChangeMsgToObject()
      return result
    }
    limitedTextField.sendDidChangeMsgToObject()
    return matchResult && flag
  }// return NO to not change text
  
  @available(iOS 2.0, *)
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate,
      let shouldClear = textFieldDelegate.textFieldShouldClear?(textField) else {
        return true
    }
    return shouldClear
  }
  
  @available(iOS 2.0, *)
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let textFieldDelegate = self.realDelegate as? UITextFieldDelegate,
      let shouldReturn = textFieldDelegate.textFieldShouldReturn?(textField) else {
        return true
    }
    return shouldReturn
  }// called when 'return' key pressed. return NO to ignore.
}
