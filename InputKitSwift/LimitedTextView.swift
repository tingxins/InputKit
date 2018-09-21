//
//  LimitedTextView.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

open class LimitedTextView: UITextView {
  
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
  
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
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
  
  private var limitedDelegate: LimitedTextViewDelegate?
  override open var delegate: UITextViewDelegate? {
    get {
      return limitedDelegate
    }
    set {
      limitedDelegate = LimitedTextViewDelegate(realDelegate: newValue)
      super.delegate = limitedDelegate
    }
  }
  
  //MARK: - Deinitialized
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

extension LimitedTextView {
  //MARK: - Config Methods
  private func addNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textViewTextDidChange(notification:)),
                                           name: UITextView.textDidChangeNotification,
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
extension LimitedTextView {
  
  //MARK: - Notifications
  @objc private func textViewTextDidChange(notification: Notification) {
    let textView = notification.object as? UITextView
    if self != textView { return }
    
    let currentText = textView?.text
    let maxLength = self.limitedNumber
    
    var position: UITextPosition?
    if let markedTextRange = textView?.markedTextRange {
      position = textView?.position(from: markedTextRange.start, offset: 0)
    }
    
    var isMatch = true
    switch self.limitedType {
    case .normal: break
    case .price:
      isMatch = MatchManager.matchLimitedTextTypePrice(component: textView!, value: currentText!)
    case .custom:
      isMatch = MatchManager.matchLimitedTextTypeCustom(regExs: self.limitedRegExs, component: textView!, value: currentText!)
    }
    
    if isMatch {
      self.historyText = textView?.text
    }
    
    if position == nil {
      var flag = false
      if let count = currentText?.count, count > maxLength {
        textView?.text = String(currentText!.dropLast(count - maxLength))
        flag = true
      }
      
      if self.isTextSelecting && !isMatch {
        flag = true
        if let hisText = self.historyText,
          let curText = textView?.text,
          hisText.count <= curText.count {
          textView?.text = hisText
        }else {
          textView?.text = ""
        }
      }
      let text: NSString = currentText! as NSString
      if ((self.selectionRange.length > 0) && !isMatch && (self.selectionRange.length + self.selectionRange.location <= text.length)) {
        let limitedText = text.substring(with: self.selectionRange)
        textView?.text = textView?.text.replacingOccurrences(of: limitedText, with: "")
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
      guard let markedTextRange = textView?.markedTextRange else { return }
      self.selectionRange = range(from: markedTextRange)
    }
    sendDidChangeMsgToObject()
  }
}

extension LimitedTextView {
  
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

fileprivate class LimitedTextViewDelegate: LimitedDelegate, UITextViewDelegate  {
  
  @available(iOS 2.0, *)
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool  {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldBeginEditing = realDelegate.textViewShouldBeginEditing?(textView) else {
        return true
    }
    return shouldBeginEditing
  }
  
  @available(iOS 2.0, *)
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldEndEditing = realDelegate.textViewShouldEndEditing?(textView) else {
        return true
    }
    return shouldEndEditing
  }
  
  @available(iOS 2.0, *)
  func textViewDidBeginEditing(_ textView: UITextView) {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate else { return }
    realDelegate.textViewDidBeginEditing?(textView)
  }
  
  @available(iOS 2.0, *)
  func textViewDidEndEditing(_ textView: UITextView) {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate else { return }
    realDelegate.textViewDidEndEditing?(textView)
  }
  
  @available(iOS 2.0, *)
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    var flag = true
    if let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldChange = realDelegate.textView?(textView, shouldChangeTextIn: range, replacementText: text) {
      flag = shouldChange
    }
    
    var matchResult = true
    let limitedTextView = textView as! LimitedTextView
    if textView.isKind(of: LimitedTextView.self) {
      limitedTextView.resetSelectionTextRange()
      let matchStr = MatchManager.getMatchContentWithOriginalText(originalText: textView.text!, replaceText: text, range: range)
      
      let isDeleteOperation = (range.length > 0 && text.count == 0) ? true : false
      
      switch limitedTextView.limitedType {
      case .normal: break
      case .price: matchResult = MatchManager.matchLimitedTextTypePrice(component: textView, value: matchStr)
      case .custom:
        if limitedTextView.isTextSelecting {
          matchResult = true
        } else {
          matchResult = MatchManager.matchLimitedTextTypeCustom(regExs: limitedTextView.limitedRegExs, component: textView, value: matchStr)
        }
      }
      let result = flag && (matchResult || isDeleteOperation)
      if !result {
        limitedTextView.sendIllegalMsgToObject()
      }
      limitedTextView.sendDidChangeMsgToObject()
      return result
    }
    limitedTextView.sendDidChangeMsgToObject()
    return matchResult && flag
  }
  
  @available(iOS 2.0, *)
  func textViewDidChange(_ textView: UITextView) {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate else { return }
    realDelegate.textViewDidChange?(textView)
  }
  
  @available(iOS 2.0, *)
  func textViewDidChangeSelection(_ textView: UITextView) {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate else { return }
    realDelegate.textViewDidChangeSelection?(textView)
  }
  
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldInteract = realDelegate.textView?(textView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange,
                                                  interaction: interaction) else {
                                                    return true
    }
    return shouldInteract
  }
  
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldInteract = realDelegate.textView?(textView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange,
                                                  interaction: interaction) else {
                                                    return true
    }
    return shouldInteract
  }
  
  @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead")
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldInteract = realDelegate.textView?(textView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange) else {
                                                    return true
    }
    return shouldInteract
  }
  
  @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead")
  func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
    guard let realDelegate = self.realDelegate as? UITextViewDelegate,
      let shouldInteract = realDelegate.textView?(textView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange) else {
                                                    return true
    }
    return shouldInteract
  }
}
